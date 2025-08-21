//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 8/21/25.
//

import Foundation
import Balloting

public struct TestCandidate: Candidate {
    public var id: UUID
    public var name: String
    
    public init() {
        self.init(name: "New Candidate")
    }
    
    public init(name: String) {
        self.init(id: UUID(), name: name)
    }
    
    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}

extension TestCandidate: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.name < rhs.name
    }
}

extension TestCandidate: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = Self(name: value)
    }
}
