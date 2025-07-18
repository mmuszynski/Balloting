//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/24/25.
//

import Foundation

public protocol Candidate: Sendable, Hashable, Comparable, Codable, Identifiable {
    associatedtype ID: CandidateIdentifiable
    var id: ID { get }
    var name: String { get }
}

extension Candidate {
    public var id: Self {
        self
    }
    
    public var name: String {
        String(describing: self)
    }
}

extension String: Candidate {}
extension Int: Candidate {}

public protocol CandidateIdentifiable: Equatable & Hashable & Comparable & Codable & Sendable {
    init(csvString: String)
}

extension String: CandidateIdentifiable {}
extension Int: CandidateIdentifiable {}
extension UUID: CandidateIdentifiable {}
