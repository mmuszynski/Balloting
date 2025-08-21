//
//  IRVCountTests.swift
//  Balloting
//
//  Created by Mike Muszynski on 8/21/25.
//

import Testing
import Foundation
@testable import Balloting

struct IRVResultsTest {
    @Test func emptyRankedBallot() async throws {
        let candidate: TestCandidate = "Butthead"
        let ballot = RankedBallot(id: 1, rankings: [CandidateRanking(candidate: candidate, rank: nil)])
        let round = try IRVRound(ballots: [ballot], candidates: [candidate], ignoring: [])
        #expect(round[candidate] == 0)
    }
}
