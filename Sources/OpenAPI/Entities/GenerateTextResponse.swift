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

/// The response from the model, including candidate completions.
public struct GenerateTextResponse: Codable {
  /// Candidate responses from the model.
  public var candidates: [TextCompletion]?
  /// Returns any safety feedback related to content filtering.
  public var safetyFeedback: [SafetyFeedback]?
  /// A set of content filtering metadata for the prompt and response text. This indicates which `SafetyCategory`(s) blocked a candidate from this response, the lowest `HarmProbability` that triggered a block, and the HarmThreshold setting for that category. This indicates the smallest change to the `SafetySettings` that would be necessary to unblock at least 1 response. The blocking is configured by the `SafetySettings` in the request (or the default `SafetySettings` of the API).
  public var filters: [ContentFilter]?

  public init(candidates: [TextCompletion]? = nil, safetyFeedback: [SafetyFeedback]? = nil, filters: [ContentFilter]? = nil) {
    self.candidates = candidates
    self.safetyFeedback = safetyFeedback
    self.filters = filters
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: StringCodingKey.self)
    self.candidates = try values.decodeIfPresent([TextCompletion].self, forKey: "candidates")
    self.safetyFeedback = try values.decodeIfPresent([SafetyFeedback].self, forKey: "safetyFeedback")
    self.filters = try values.decodeIfPresent([ContentFilter].self, forKey: "filters")
  }

  public func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: StringCodingKey.self)
    try values.encodeIfPresent(candidates, forKey: "candidates")
    try values.encodeIfPresent(safetyFeedback, forKey: "safetyFeedback")
    try values.encodeIfPresent(filters, forKey: "filters")
  }
}
