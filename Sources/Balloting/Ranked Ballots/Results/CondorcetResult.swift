//
//  Condorcet.swift
//  Balloting
//
//  Created by Mike Muszynski on 5/24/25.
//

import Foundation

struct CondorcetResult<CandidateID: CandidateIdentifiable, BallotID: BallotIdentifiable> {
    typealias Ballot = RankedBallot<BallotID, CandidateID>
    
    let ballots: [Ballot]
    let candidates: Set<CandidateID>
    var victories: [String: ResultCouple] = [:]
    
    init(ballots: [Ballot]) throws {
        var set = Set<CandidateID>()
        
        for ballot in ballots {
            let ids = ballot.rankings.map(\.candidate)
            set.formUnion(ids)
        }
        
        self.candidates = set
        self.ballots = ballots
        
        self.victories = try self.calculate()
    }
    
    typealias ResultCouple = (wins1: Int, wins2: Int, draws: Int)
    
    mutating func calculate() throws -> [String: ResultCouple] {
        var results: [String: ResultCouple] = [:]
        
        let candidates = candidates.sorted(by: <)
        for candidate1 in candidates {
            for candidate2 in candidates {
                if candidate1 == candidate2 { continue }
                
                let preferences = try ballotPreferences(for: candidate1, against: candidate2)
                
                let candidate1Wins = preferences.count(where: { $0.winner == candidate1 })
                let candidate2Wins = preferences.count(where: { $0.winner == candidate2 })
                let draws = preferences.filter { $0.winner == nil }

                if !draws.isEmpty {
                    print(draws)
                }
                
                let theResult = (wins1: candidate1Wins, wins2: candidate2Wins, draws: draws.count)
                results["\(candidate1):\(candidate2)"] = theResult
            }
        }
        
        return results
    }
    
    func ballotPreferences(for candidate1: CandidateID, against candidate2: CandidateID) throws -> [Ballot.CandidateComparison] {
        return try ballots.map { try $0.comparison(between: candidate1, and: candidate2) }
    }
    
    func preferredCandidate(for candidate1: CandidateID, against candidate2: CandidateID) throws -> [CandidateID?] {
        try ballotPreferences(for: candidate1, against: candidate2).map(\.winner)
    }
    
    func wins(for candidate1: CandidateID, against candidate2: CandidateID) throws -> Int {
        try preferredCandidate(for: candidate1, against: candidate2).count { $0 == candidate1 }
    }
}

extension CondorcetResult: CustomStringConvertible {
    var description: String {
        let candidates = candidates.sorted(by: <)
        
        var returnValue = "\t"
        
        for canidate in candidates {
            returnValue += "\(canidate)\t"
        }
        for candidate2 in candidates {
            returnValue += "\n\(candidate2)\t"
            for candidate1 in candidates {
                if let result = victories["\(candidate1):\(candidate2)"] {
                    returnValue += "\(result.wins1)–\(result.wins2)-\(result.draws)\t"
                } else {
                    returnValue += "––\t"
                }
            }
        }
        
        return returnValue
    }
}
