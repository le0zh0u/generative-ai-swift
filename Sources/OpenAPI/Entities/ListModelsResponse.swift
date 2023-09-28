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

/// Response from `ListModel` containing a paginated list of Models.
public struct ListModelsResponse: Codable {
  /// A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no more pages.
  public var nextPageToken: String?
  /// The returned Models.
  public var models: [Model]?

  public init(nextPageToken: String? = nil, models: [Model]? = nil) {
    self.nextPageToken = nextPageToken
    self.models = models
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: StringCodingKey.self)
    self.nextPageToken = try values.decodeIfPresent(String.self, forKey: "nextPageToken")
    self.models = try values.decodeIfPresent([Model].self, forKey: "models")
  }

  public func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: StringCodingKey.self)
    try values.encodeIfPresent(nextPageToken, forKey: "nextPageToken")
    try values.encodeIfPresent(models, forKey: "models")
  }
}
