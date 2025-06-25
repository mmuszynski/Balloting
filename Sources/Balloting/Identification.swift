//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 5/29/25.
//

import Foundation

public protocol BallotIdentifiable: Hashable & Comparable & Codable & Sendable {}

extension String: BallotIdentifiable {}
extension Int: BallotIdentifiable {}
extension Date: BallotIdentifiable {}
extension UUID: BallotIdentifiable {}
