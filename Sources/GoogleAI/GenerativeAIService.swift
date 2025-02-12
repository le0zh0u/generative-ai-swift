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

struct GenerativeAIService {
  /// Gives permission to talk to the backend.
  private let apiKey: String
    
    private let baseURL: String?

  private let urlSession: URLSession

    init(apiKey: String, baseURL: String? = nil, urlSession: URLSession) {
    self.apiKey = apiKey
        self.baseURL = baseURL
    self.urlSession = urlSession
  }

  func loadRequest<T: GenerativeAIRequest>(request: T) async throws -> T.Response {
    let urlRequest = try urlRequest(request: request)

    #if DEBUG
      printCURLCommand(from: urlRequest)
    #endif

    let data: Data
    let rawResponse: URLResponse
    (data, rawResponse) = try await urlSession.data(for: urlRequest)

    let response = try httpResponse(urlResponse: rawResponse)

    // Verify the status code is 200
    guard response.statusCode == 200 else {
      Logging.default.error("[GoogleGenerativeAI] The server responded with an error: \(response)")
      if let responseString = String(data: data, encoding: .utf8) {
        Logging.network.error("[GoogleGenerativeAI] Response payload: \(responseString)")
      }

      throw try JSONDecoder().decode(RPCError.self, from: data)
    }

    return try parseResponse(T.Response.self, from: data)
  }

  @available(macOS 12.0, *)
  func loadRequestStream<T: GenerativeAIRequest>(request: T)
    -> AsyncThrowingStream<T.Response, Error> {
    return AsyncThrowingStream { continuation in
      Task {
        let urlRequest: URLRequest
        do {
          urlRequest = try self.urlRequest(request: request)
        } catch {
          continuation.finish(throwing: error)
          return
        }

        #if DEBUG
          printCURLCommand(from: urlRequest)
        #endif

        let stream: URLSession.AsyncBytes
        let rawResponse: URLResponse
        do {
          (stream, rawResponse) = try await urlSession.bytes(for: urlRequest)
        } catch {
          continuation.finish(throwing: error)
          return
        }

        // Verify the status code is 200
        let response: HTTPURLResponse
        do {
          response = try httpResponse(urlResponse: rawResponse)
        } catch {
          continuation.finish(throwing: error)
          return
        }

        // Verify the status code is 200
        guard response.statusCode == 200 else {
          Logging.default
            .error("[GoogleGenerativeAI] The server responded with an error: \(response)")
          var responseBody = ""
          for try await line in stream.lines {
            responseBody += line + "\n"
          }

          Logging.network.error("[GoogleGenerativeAI] Response payload: \(responseBody)")
          do {
            try parseError(responseBody: responseBody)
          } catch {
            continuation.finish(throwing: error)
          }

          return
        }

        // Received lines that are not server-sent events (SSE); these are not prefixed with "data:"
        var extraLines: String = ""

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        for try await line in stream.lines {
          Logging.network.debug("[GoogleGenerativeAI] Stream response: \(line)")

          if line.hasPrefix("data:") {
            // We can assume 5 characters since it's utf-8 encoded, removing `data:`.
            let jsonText = String(line.dropFirst(5))
            let data: Data
            do {
              data = try jsonData(jsonText: jsonText)
            } catch {
              continuation.finish(throwing: error)
              return
            }

            // Handle the content.
            do {
              let content = try parseResponse(T.Response.self, from: data)
              continuation.yield(content)
            } catch {
              continuation.finish(throwing: error)
              return
            }
          } else {
            extraLines += line
          }
        }

        if extraLines.count > 0 {
          do {
            try parseError(responseBody: extraLines)
          } catch {
            continuation.finish(throwing: error)
          }

          return
        }

        continuation.finish(throwing: nil)
      }
    }
  }

  // MARK: - Private Helpers
  private func urlRequest<T: GenerativeAIRequest>(request: T) throws -> URLRequest {
      // replase baseURL with Default base url in GenerativeAIService enum
      var requestURL = request.url
      if let baseURL = baseURL, !baseURL.isEmpty {
          //GenerativeAISwift.baseURL
          let newUrl = requestURL.absoluteString.replacingOccurrences(of: "generativelanguage.googleapis.com", with: baseURL)
          requestURL = URL(string: newUrl)!
      }
    var urlRequest = URLRequest(url: requestURL)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
    urlRequest.setValue("genai-swift/\(GenerativeAISwift.version)",
                        forHTTPHeaderField: "x-goog-api-client")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    urlRequest.httpBody = try encoder.encode(request)

    return urlRequest
  }

  private func httpResponse(urlResponse: URLResponse) throws -> HTTPURLResponse {
    // Verify the status code is 200
    guard let response = urlResponse as? HTTPURLResponse else {
      Logging.default
        .error(
          "[GoogleGenerativeAI] Response wasn't an HTTP response, internal error \(urlResponse)"
        )
      throw NSError(
        domain: "com.google.generative-ai",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Response was not an HTTP response."]
      )
    }

    return response
  }

  private func jsonData(jsonText: String) throws -> Data {
    guard let data = jsonText.data(using: .utf8) else {
      let error = NSError(
        domain: "com.google.generative-ai",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Could not parse response as UTF8."]
      )
      throw error
    }

    return data
  }

  private func parseError(responseBody: String) throws {
    let data = try jsonData(jsonText: responseBody)

    do {
      let rpcError = try JSONDecoder().decode(RPCError.self, from: data)
      throw rpcError
    } catch {
      // TODO: Throw an error about an unrecognized error payload with the response body
      throw error
    }
  }

  private func parseResponse<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    do {
      return try JSONDecoder().decode(type, from: data)
    } catch {
      if let json = String(data: data, encoding: .utf8) {
        Logging.network.error("[GoogleGenerativeAI] JSON response: \(json)")
      }
      Logging.default.error("[GoogleGenerativeAI] Error decoding server JSON: \(error)")
      throw error
    }
  }

  #if DEBUG
    private func cURLCommand(from request: URLRequest) -> String {
      var returnValue = "curl "
      if let allHeaders = request.allHTTPHeaderFields {
        for (key, value) in allHeaders {
          returnValue += "-H '\(key): \(value)' "
        }
      }

      guard let url = request.url else { return "" }
      returnValue += "'\(url.absoluteString)' "

      guard let body = request.httpBody,
            let jsonStr = String(bytes: body, encoding: .utf8) else { return "" }
      let escapedJSON = jsonStr.replacingOccurrences(of: "'", with: "'\\''")
      returnValue += "-d '\(escapedJSON)'"

      return returnValue
    }

    private func printCURLCommand(from request: URLRequest) {
      let command = cURLCommand(from: request)
      Logging.verbose.debug("""
      [GoogleGenerativeAI] Creating request with the equivalent cURL command:
      ----- cURL command -----
      \(command, privacy: .private)
      ------------------------
      """)
    }
  #endif // DEBUG
}
