//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/8/25.
//

import Foundation

public protocol Election: Sendable, Codable {
    var configuration: ElectionConfiguration { get set }
}

public protocol ElectionResult: Sendable, Codable {
}

public struct ElectionConfiguration: Sendable, Codable {
    public var name: String = ""
    public var detailDescription: String = ""
    
    public var beginDate: Date = .distantFuture
    public var endDate: Date = .distantFuture
}


