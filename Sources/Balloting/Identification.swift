//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 5/29/25.
//

import Foundation

protocol CandidateIdentifiable: Equatable & Hashable & Comparable & Codable {}

extension String: CandidateIdentifiable {}
extension Int: CandidateIdentifiable {}

protocol BallotIdentifiable: Hashable & Comparable & Codable {}

extension String: BallotIdentifiable {}
extension Int: BallotIdentifiable {}
