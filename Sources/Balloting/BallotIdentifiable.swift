//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 5/29/25.
//

import Foundation

public protocol BallotIdentifiable: Hashable & Comparable & Codable & Sendable {
    //This is a requirement to translate to and from string for the CSV representation
    init?(csvString: String)
    
    //This is a requirement to create a new ballot
    static var new: Self { get }
    init()
}

extension BallotIdentifiable {
    public static var new: Self {
        Self.init()
    }
}

extension String: BallotIdentifiable {
    public init?(csvString: String) {
        self = csvString
    }
    
    public static var new: String {
        "New Candidate"
    }
}

extension Int: BallotIdentifiable {
    public init?(csvString: String) {
        guard let id = Int(csvString) else { return nil }
        self = id
    }
}

extension Date: BallotIdentifiable {
    public init?(csvString: String) {
        let dateFormatter = ISO8601DateFormatter()
        guard let id = dateFormatter.date(from: csvString) else { return nil }
        self = id
    }
}

extension UUID: BallotIdentifiable {
    public init?(csvString: String) {
        guard let id = UUID(uuidString: csvString) else { return nil }
        self = id
    }
}
