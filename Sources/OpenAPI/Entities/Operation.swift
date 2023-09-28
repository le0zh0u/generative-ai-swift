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

/// This resource represents a long-running operation that is the result of a network API call.
public struct Operation: Codable {
  /// If the value is `false`, it means the operation is still in progress. If `true`, the operation is completed, and either `error` or `response` is available.
  public var isDone: Bool?
  /// The server-assigned name, which is only unique within the same service that originally returns it. If you use the default HTTP mapping, the `name` should be a resource name ending with `operations/{unique_id}`.
  public var name: String?
  /// The normal, successful response of the operation. If the original method returns no data on success, such as `Delete`, the response is `google.protobuf.Empty`. If the original method is standard `Get`/`Create`/`Update`, the response should be the resource. For other methods, the response should have the type `XxxResponse`, where `Xxx` is the original method name. For example, if the original method name is `TakeSnapshot()`, the inferred response type is `TakeSnapshotResponse`.
  public var response: [String: AnyJSON]?
  /// The `Status` type defines a logical error model that is suitable for different programming environments, including REST APIs and RPC APIs. It is used by [gRPC](https://github.com/grpc). Each `Status` message contains three pieces of data: error code, error message, and error details. You can find out more about this error model and how to work with it in the [API Design Guide](https://cloud.google.com/apis/design/errors).
  public var error: Status?
  /// Service-specific metadata associated with the operation. It typically contains progress information and common metadata such as create time. Some services might not provide such metadata. Any method that returns a long-running operation should document the metadata type, if any.
  public var metadata: [String: AnyJSON]?

  public init(isDone: Bool? = nil, name: String? = nil, response: [String: AnyJSON]? = nil, error: Status? = nil, metadata: [String: AnyJSON]? = nil) {
    self.isDone = isDone
    self.name = name
    self.response = response
    self.error = error
    self.metadata = metadata
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: StringCodingKey.self)
    self.isDone = try values.decodeIfPresent(Bool.self, forKey: "done")
    self.name = try values.decodeIfPresent(String.self, forKey: "name")
    self.response = try values.decodeIfPresent([String: AnyJSON].self, forKey: "response")
    self.error = try values.decodeIfPresent(Status.self, forKey: "error")
    self.metadata = try values.decodeIfPresent([String: AnyJSON].self, forKey: "metadata")
  }

  public func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: StringCodingKey.self)
    try values.encodeIfPresent(isDone, forKey: "done")
    try values.encodeIfPresent(name, forKey: "name")
    try values.encodeIfPresent(response, forKey: "response")
    try values.encodeIfPresent(error, forKey: "error")
    try values.encodeIfPresent(metadata, forKey: "metadata")
  }
}
