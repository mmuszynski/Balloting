//
//  MinneapolisMayorTest.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/4/25.
//

import Testing
import Foundation
@testable import Balloting

struct MinneapolisMayorTest {
    typealias Election = RankedElection<UUID, String>
    let election: Election
    
    init() throws {
        let url = Bundle.module.url(forResource: "Minneapolis 2009 Mayor", withExtension: "csv")!
        let string = try String(contentsOf: url, encoding: .utf8)
        
        let lines = string.components(separatedBy: .newlines).dropFirst().filter { !$0.isEmpty }
        var ballots: Set<Election.Ballot> = []
        lines.enumerated().forEach { offset, line in
            let components = line.components(separatedBy: ",")
            let rankings: [Election.Ballot.CandidateRanking] = components[0..<4].dropFirst().compactMap { name in
                if name == "XXX" { return nil }
                return Election.Ballot.CandidateRanking(candidate: name, rank: 0)
            }
            
            for _ in 0..<(Int(components[4]) ?? 1) {
                ballots.insert(Election.Ballot(id: UUID(), rankings: rankings))
            }
        }
        
        election = Election(ballots: Array(ballots))
    }
    
    @Test
    func minneapolis2009() async throws {
        #expect(throws: Never.self) { try Self.init() }
        
        var winner: String? = nil
        let eliminated: Set<String> = []
        let round = try election.irvRound(ignoring: eliminated)
        winner = round.majorityCandidate
        #expect(winner == "RYB")
    }
}
