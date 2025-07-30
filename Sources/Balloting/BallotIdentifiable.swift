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
}

extension String: BallotIdentifiable {
    public init?(csvString: String) {
        self = csvString
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
