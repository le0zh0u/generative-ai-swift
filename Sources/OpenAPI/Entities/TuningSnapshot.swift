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

/// Record for a single tuning step.
public struct TuningSnapshot: Codable {
  /// Output only. The timestamp when this metric was computed.
  public var computeTime: String?
  /// Output only. The mean loss of the training examples for this step.
  public var meanLoss: Float?
  /// Output only. The tuning step.
  public var step: Int32?
  /// Output only. The epoch this step was part of.
  public var epoch: Int32?

  public init(computeTime: String? = nil, meanLoss: Float? = nil, step: Int32? = nil, epoch: Int32? = nil) {
    self.computeTime = computeTime
    self.meanLoss = meanLoss
    self.step = step
    self.epoch = epoch
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: StringCodingKey.self)
    self.computeTime = try values.decodeIfPresent(String.self, forKey: "computeTime")
    self.meanLoss = try values.decodeIfPresent(Float.self, forKey: "meanLoss")
    self.step = try values.decodeIfPresent(Int32.self, forKey: "step")
    self.epoch = try values.decodeIfPresent(Int32.self, forKey: "epoch")
  }

  public func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: StringCodingKey.self)
    try values.encodeIfPresent(computeTime, forKey: "computeTime")
    try values.encodeIfPresent(meanLoss, forKey: "meanLoss")
    try values.encodeIfPresent(step, forKey: "step")
    try values.encodeIfPresent(epoch, forKey: "epoch")
  }
}
