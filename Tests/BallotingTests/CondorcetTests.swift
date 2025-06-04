//
//  CondorcetTests.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/3/25.
//

import Testing
import Foundation
@testable import Balloting

struct CondorcetTests {
    typealias Election = RankedElection<Date, Int>
    let election = try! loadDessertElection()
    
    @Test
    func condorcetResult() async throws {
        election.condorcetResult()
    }
}
