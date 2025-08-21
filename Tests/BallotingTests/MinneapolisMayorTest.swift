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
    typealias Election = RankedElection<UUID, TestCandidate>
    let election: Election
    
    init() throws {
        let url = Bundle.module.url(forResource: "Minneapolis 2009 Mayor", withExtension: "csv")!
        let string = try String(contentsOf: url, encoding: .utf8)
        
        let lines = string.components(separatedBy: .newlines).dropFirst().filter { !$0.isEmpty }
        var candidates: [String: TestCandidate] = [:]
        
        var ballots: Set<Election.Ballot> = []
        lines.enumerated().forEach { offset, line in
            let components = line.components(separatedBy: ",")
            let rankings: [Election.Ballot.Ranking] = components[0..<4].dropFirst().enumerated().compactMap { index, name in
                if name == "XXX" { return nil }
                
                if candidates[name] == nil {
                    candidates[name] = TestCandidate(name: name)
                }
                
                let candidate = candidates[name]!
                return Election.Ballot.Ranking(candidate: candidate, rank: 3 - index)
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
        
        var winner: TestCandidate? = nil
        var eliminated: Set<TestCandidate> = []
        
        let candidates = election.candidates
        print(candidates.count)
        
        let round = try IRVRound(election: election, ignoring: eliminated)
        winner = round.majorityCandidate
        
        while winner == nil || eliminated.count < candidates.count {
            let round = try IRVRound(election: election, ignoring: eliminated)
            winner = round.majorityCandidate
            if let eliminatedCandidate = round.eliminatedCandidate {
                eliminated.insert(eliminatedCandidate)
            } else {
                break
            }
        }
        
        #expect(winner?.name == "RYB")
    }
}
