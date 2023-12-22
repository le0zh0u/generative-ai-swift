// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// A type that represents a remote multimodal model (like Gemini), with the ability to generate
/// content based on various input types.
public final class GenerativeModel {
  // The prefix for a model resource in the Gemini API.
  private static let modelResourcePrefix = "models/"

  /// The resource name of the model in the backend; has the format "models/model-name".
  private let modelResourceName: String

  /// The backing service responsible for sending and receiving model requests to the backend.
  let generativeAIService: GenerativeAIService

  /// Configuration parameters used for the MultiModalModel.
  let generationConfig: GenerationConfig?

  /// The safety settings to be used for prompts.
  let safetySettings: [SafetySetting]?

  /// Initializes a new remote model with the given parameters.
  ///
  /// - Parameter name: The name of the model to be used, e.g., "gemini-pro" or "models/gemini-pro".
  /// - Parameter apiKey: The API key for your project.
  /// - Parameter generationConfig: A value containing the content generation parameters your model
  ///     should use.
  /// - Parameter safetySettings: A value describing what types of harmful content your model
  ///     should allow.
  public convenience init(name: String,
                          apiKey: String,
                          baseURL: String? = nil,
                          generationConfig: GenerationConfig? = nil,
                          safetySettings: [SafetySetting]? = nil) {
    self.init(
      name: name,
      apiKey: apiKey,
      baseURL: baseURL,
      generationConfig: generationConfig,
      safetySettings: safetySettings,
      urlSession: .shared
    )
  }

  /// The designated initializer for this class.
  init(name: String,
       apiKey: String,
       baseURL: String? = nil,
       generationConfig: GenerationConfig? = nil,
       safetySettings: [SafetySetting]? = nil,
       urlSession: URLSession) {
    modelResourceName = GenerativeModel.modelResourceName(name: name)
      generativeAIService = GenerativeAIService(apiKey: apiKey, baseURL:baseURL, urlSession: urlSession)
    self.generationConfig = generationConfig
    self.safetySettings = safetySettings

    Logging.default.info("""
    [GoogleGenerativeAI] Model \(
      name,
      privacy: .public
    ) initialized. To enable additional logging, add \
    `\(Logging.enableArgumentKey, privacy: .public)` as a launch argument in Xcode.
    """)
    Logging.verbose.debug("[GoogleGenerativeAI] Verbose logging enabled.")
  }

  /// Generates content from String and/or image inputs, given to the model as a prompt, that are
  /// representable as one or more ``ModelContent/Part``s.
  ///
  /// Since ``ModelContent/Part``s do not specify a role, this method is intended for generating
  /// content from
  /// [zero-shot](https://developers.google.com/machine-learning/glossary/generative#zero-shot-prompting)
  /// or "direct" prompts. For
  /// [few-shot](https://developers.google.com/machine-learning/glossary/generative#few-shot-prompting)
  /// prompts, see ``generateContent(_:)-58rm0``.
  ///
  /// - Parameter content: The input(s) given to the model as a prompt (see ``PartsRepresentable``
  /// for conforming types).
  /// - Returns: The content generated by the model.
  /// - Throws: A ``GenerateContentError`` if the request failed.
  public func generateContent(_ parts: PartsRepresentable...)
    async throws -> GenerateContentResponse {
    return try await generateContent([ModelContent(parts: parts)])
  }

  /// Generates new content from input content given to the model as a prompt.
  ///
  /// - Parameter content: The input(s) given to the model as a prompt.
  /// - Returns: The generated content response from the model.
  /// - Throws: A ``GenerateContentError`` if the request failed.
  public func generateContent(_ content: [ModelContent]) async throws -> GenerateContentResponse {
    let generateContentRequest = GenerateContentRequest(model: modelResourceName,
                                                        contents: content,
                                                        generationConfig: generationConfig,
                                                        safetySettings: safetySettings,
                                                        isStreaming: false)
    let response: GenerateContentResponse
    do {
      response = try await generativeAIService.loadRequest(request: generateContentRequest)
    } catch {
      throw GenerateContentError.internalError(underlying: error)
    }

    // Check the prompt feedback to see if the prompt was blocked.
    if response.promptFeedback?.blockReason != nil {
      throw GenerateContentError.promptBlocked(response: response)
    }

    // Check to see if an error should be thrown for stop reason.
    if let reason = response.candidates.first?.finishReason, reason != .stop {
      throw GenerateContentError.responseStoppedEarly(reason: reason, response: response)
    }

    return response
  }

  /// Generates content from String and/or image inputs, given to the model as a prompt, that are
  /// representable as one or more ``ModelContent/Part``s.
  ///
  /// Since ``ModelContent/Part``s do not specify a role, this method is intended for generating
  /// content from
  /// [zero-shot](https://developers.google.com/machine-learning/glossary/generative#zero-shot-prompting)
  /// or "direct" prompts. For
  /// [few-shot](https://developers.google.com/machine-learning/glossary/generative#few-shot-prompting)
  /// prompts, see ``generateContent(_:)-58rm0``.
  ///
  /// - Parameter content: The input(s) given to the model as a prompt (see ``PartsRepresentable``
  /// for conforming types).
  /// - Returns: A stream wrapping content generated by the model or a ``GenerateContentError``
  ///     error if an error occurred.
  public func generateContentStream(_ parts: PartsRepresentable...)
    -> AsyncThrowingStream<GenerateContentResponse, Error> {
    return generateContentStream([ModelContent(parts: parts)])
  }

  /// Generates new content from input content given to the model as a prompt.
  ///
  /// - Parameter content: The input(s) given to the model as a prompt.
  /// - Returns: A stream wrapping content generated by the model or a ``GenerateContentError``
  ///     error if an error occurred.
  public func generateContentStream(_ content: [ModelContent])
    -> AsyncThrowingStream<GenerateContentResponse, Error> {
    let generateContentRequest = GenerateContentRequest(model: modelResourceName,
                                                        contents: content,
                                                        generationConfig: generationConfig,
                                                        safetySettings: safetySettings,
                                                        isStreaming: true)

    var responseIterator = generativeAIService.loadRequestStream(request: generateContentRequest)
      .makeAsyncIterator()
    return AsyncThrowingStream {
      let response: GenerateContentResponse?
      do {
        response = try await responseIterator.next()
      } catch {
        throw GenerateContentError.internalError(underlying: error)
      }

      // The responseIterator will return `nil` when it's done.
      guard let response = response else {
        // This is the end of the stream! Signal it by sending `nil`.
        return nil
      }

      // Check the prompt feedback to see if the prompt was blocked.
      if response.promptFeedback?.blockReason != nil {
        throw GenerateContentError.promptBlocked(response: response)
      }

      // If the stream ended early unexpectedly, throw an error.
      if let finishReason = response.candidates.first?.finishReason, finishReason != .stop {
        throw GenerateContentError.responseStoppedEarly(reason: finishReason, response: response)
      } else {
        // Response was valid content, pass it along and continue.
        return response
      }
    }
  }

  /// Creates a new chat conversation using this model with the provided history.
  public func startChat(history: [ModelContent] = []) -> Chat {
    return Chat(model: self, history: history)
  }

  /// Runs the model's tokenizer on String and/or image inputs that are representable as one or more
  /// ``ModelContent/Part``s.
  ///
  /// Since ``ModelContent/Part``s do not specify a role, this method is intended for tokenizing
  /// [zero-shot](https://developers.google.com/machine-learning/glossary/generative#zero-shot-prompting)
  /// or "direct" prompts. For
  /// [few-shot](https://developers.google.com/machine-learning/glossary/generative#few-shot-prompting)
  /// input, see ``countTokens(_:)-9spwl``.
  ///
  /// - Parameter content: The input(s) given to the model as a prompt (see ``PartsRepresentable``
  /// for conforming types).
  /// - Returns: The results of running the model's tokenizer on the input; contains
  /// ``CountTokensResponse/totalTokens``.
  /// - Throws: A ``CountTokensError`` if the tokenization request failed.
  public func countTokens(_ parts: PartsRepresentable...) async throws -> CountTokensResponse {
    return try await countTokens([ModelContent(parts: parts)])
  }

  /// Runs the model's tokenizer on the input content and returns the token count.
  ///
  /// - Parameter content: The input given to the model as a prompt.
  /// - Returns: The results of running the model's tokenizer on the input; contains
  /// ``CountTokensResponse/totalTokens``.
  /// - Throws: A ``CountTokensError`` if the tokenization request failed.
  public func countTokens(_ content: [ModelContent]) async throws
    -> CountTokensResponse {
    let countTokensRequest = CountTokensRequest(model: modelResourceName, contents: content)

    do {
      return try await generativeAIService.loadRequest(request: countTokensRequest)
    } catch {
      throw CountTokensError.internalError(underlying: error)
    }
  }

  /// Returns a model resource name of the form "models/model-name" based on `name`.
  private static func modelResourceName(name: String) -> String {
    if name.hasPrefix(modelResourcePrefix) {
      return name
    } else {
      return modelResourcePrefix + name
    }
  }
}

/// See ``GenerativeModel/countTokens(_:)-9spwl``.
public enum CountTokensError: Error {
  case internalError(underlying: Error)
}
