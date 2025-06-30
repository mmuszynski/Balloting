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
        let count = RankedElection.bordaCount(using: election.ballots, ignoring: [])
        #expect(count["Chocolate Cake"] == 99)
        #expect(count["Cheesecake"] == 109)
        #expect(count["Apple Pie"] == 100)
        #expect(count["Carrot Cake"] == 109)
        #expect(count["Pumpkin Pie"] == 73)
        #expect(count["Angelfood Cake"] == 49)
    }
}
