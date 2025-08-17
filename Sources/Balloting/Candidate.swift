//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/24/25.
//

import Foundation

public protocol Candidate: Sendable, Hashable, Comparable, Codable, Identifiable where ID: CandidateIdentifiable {
    var id: ID { get set }
    var name: String { get set }
    init()
    init(name: String)
}

extension Candidate {
    public var id: Self {
        self
    }
    
    public var name: String {
        String(describing: self)
    }
}

public protocol CandidateIdentifiable: Equatable & Hashable & Comparable & Codable & Sendable {
    init?(csvString: String)
}

extension String: CandidateIdentifiable {}
extension Int: CandidateIdentifiable {}
extension UUID: CandidateIdentifiable {}
