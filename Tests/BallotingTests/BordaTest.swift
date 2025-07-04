//
//  BordaTest.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/29/25.
//

import Testing
import Foundation
@testable import Balloting

//The results of these elections comes from the google form with results at  https://docs.google.com/spreadsheets/d/1PB8zEAj1a-JXScfxqcZd-tM29HOzKN1lE4oOmerUZlw/edit?gid=1301572243#gid=1301572243

struct BordaTest {
    let election: RankedElection<Date, String>
    init() throws {
        election = try loadDessertElection()
    }
    
    @Test
    func bordaCount() throws {
        let count = BordaCount(using: Set(election.ballots), ignoring: [])
        #expect(count["Chocolate Cake"] == 99)
        #expect(count["Cheesecake"] == 109)
        #expect(count["Apple Pie"] == 100)
        #expect(count["Carrot Cake"] == 109)
        #expect(count["Pumpkin Pie"] == 73)
        #expect(count["Angelfood Cake"] == 49)
        
        #expect(count.last?.candidate == "Angelfood Cake")
        #expect(count.last?.value == 49)
    }
    
    @Test
    func lowestCanddiates() throws {
        let results = ["Bob" : 5, "John" : 10, "Steve" : 5, "Harry" : 12]
        #expect(Set(results.lowestRankingCandidates(among: results.map(\.key)).map(\.0)) == Set(["Bob", "Steve"]))
    }
}
