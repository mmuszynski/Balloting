//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/8/25.
//

import Foundation

public protocol Election: Sendable, Codable {
    var beginDate: Date? { get }
    var endDate: Date? { get }
    
    var name: String { get }
    var detailDescription: String { get }
}
