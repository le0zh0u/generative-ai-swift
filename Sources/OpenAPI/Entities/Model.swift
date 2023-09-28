// Generated by Create API
// https://github.com/CreateAPI/CreateAPI
//
// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// Information about a Generative Language Model.
public struct Model: Codable {
  /// Maximum number of input tokens allowed for this model.
  public var inputTokenLimit: Int32?
  /// For Top-k sampling. Top-k sampling considers the set of `top_k` most probable tokens. This value specifies default to be used by the backend while making the call to the model.
  public var topK: Int32?
  /// For Nucleus sampling. Nucleus sampling considers the smallest set of tokens whose probability sum is at least `top_p`. This value specifies default to be used by the backend while making the call to the model.
  public var topP: Float?
  /// Required. The resource name of the `Model`. Format: `models/{model}` with a `{model}` naming convention of: * "{base_model_id}-{version}" Examples: * `models/chat-bison-001`
  public var name: String?
  /// Maximum number of output tokens available for this model.
  public var outputTokenLimit: Int32?
  /// The human-readable name of the model. E.g. "Chat Bison". The name can be up to 128 characters long and can consist of any UTF-8 characters.
  public var displayName: String?
  /// Required. The name of the base model, pass this to the generation request. Examples: * `chat-bison`
  public var baseModelID: String?
  /// Required. The version number of the model. This represents the major version
  public var version: String?
  /// The model's supported generation methods. The method names are defined as Pascal case strings, such as `generateMessage` which correspond to API methods.
  public var supportedGenerationMethods: [String]?
  /// A short description of the model.
  public var description: String?
  /// Controls the randomness of the output. Values can range over `[0.0,1.0]`, inclusive. A value closer to `1.0` will produce responses that are more varied, while a value closer to `0.0` will typically result in less surprising responses from the model. This value specifies default to be used by the backend while making the call to the model.
  public var temperature: Float?

  public init(inputTokenLimit: Int32? = nil, topK: Int32? = nil, topP: Float? = nil, name: String? = nil, outputTokenLimit: Int32? = nil, displayName: String? = nil, baseModelID: String? = nil, version: String? = nil, supportedGenerationMethods: [String]? = nil, description: String? = nil, temperature: Float? = nil) {
    self.inputTokenLimit = inputTokenLimit
    self.topK = topK
    self.topP = topP
    self.name = name
    self.outputTokenLimit = outputTokenLimit
    self.displayName = displayName
    self.baseModelID = baseModelID
    self.version = version
    self.supportedGenerationMethods = supportedGenerationMethods
    self.description = description
    self.temperature = temperature
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: StringCodingKey.self)
    self.inputTokenLimit = try values.decodeIfPresent(Int32.self, forKey: "inputTokenLimit")
    self.topK = try values.decodeIfPresent(Int32.self, forKey: "topK")
    self.topP = try values.decodeIfPresent(Float.self, forKey: "topP")
    self.name = try values.decodeIfPresent(String.self, forKey: "name")
    self.outputTokenLimit = try values.decodeIfPresent(Int32.self, forKey: "outputTokenLimit")
    self.displayName = try values.decodeIfPresent(String.self, forKey: "displayName")
    self.baseModelID = try values.decodeIfPresent(String.self, forKey: "baseModelId")
    self.version = try values.decodeIfPresent(String.self, forKey: "version")
    self.supportedGenerationMethods = try values.decodeIfPresent([String].self, forKey: "supportedGenerationMethods")
    self.description = try values.decodeIfPresent(String.self, forKey: "description")
    self.temperature = try values.decodeIfPresent(Float.self, forKey: "temperature")
  }

  public func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: StringCodingKey.self)
    try values.encodeIfPresent(inputTokenLimit, forKey: "inputTokenLimit")
    try values.encodeIfPresent(topK, forKey: "topK")
    try values.encodeIfPresent(topP, forKey: "topP")
    try values.encodeIfPresent(name, forKey: "name")
    try values.encodeIfPresent(outputTokenLimit, forKey: "outputTokenLimit")
    try values.encodeIfPresent(displayName, forKey: "displayName")
    try values.encodeIfPresent(baseModelID, forKey: "baseModelId")
    try values.encodeIfPresent(version, forKey: "version")
    try values.encodeIfPresent(supportedGenerationMethods, forKey: "supportedGenerationMethods")
    try values.encodeIfPresent(description, forKey: "description")
    try values.encodeIfPresent(temperature, forKey: "temperature")
  }
}
