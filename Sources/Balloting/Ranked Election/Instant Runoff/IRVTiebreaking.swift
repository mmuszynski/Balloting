//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/25/25.
//

import Foundation

extension Dictionary where Key: Candidate, Value == Int {
    func sortedByValue() -> [(Key, Value)] {
        let sorted = self
        .sorted { first, second in
            first.value > second.value
        }
        
        guard let lowest = sorted.last?.value else { return [] }
        return sorted.filter({ $0.value == lowest }).map { ($0.key, $0.value) }
    }
    
    func lowestRankingCandidates(among eliminationCandidates: [Key]) -> [(Key, Value)] {
        self.sortedByValue()
            .filter { element in
                let key = element.0
                return eliminationCandidates.contains(key)
            }
    }
}

public enum IRVTiebreakingStrategy {
    case borda
    case initialHighestOrderPreference
    case currentNextHighestOrderPreference
    case random
    case failure
    
    func generateEliminatedCandidates<BallotID: BallotIdentifiable, C: Candidate>(using ballots: Set<RankedElection<BallotID, C>.Ballot>, from eliminationCandidates: [C]) -> [C] {
        switch self {
        case .borda:
            fatalError()
            //return RankedElection.bordaCount(using: ballots, ignoring: []).lowestRankingCandidates(among: eliminationCandidates)
        case .random:
            //selects a random candidate to eliminate
            return [eliminationCandidates.randomElement()].compactMap(\.self)
        case .failure:
            //represents that a failure should occur, and that election counting should be halted
            return eliminationCandidates
        default:
            fatalError("Unimplemented")
        }
    }
}
