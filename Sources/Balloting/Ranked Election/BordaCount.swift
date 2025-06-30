//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/26/25.
//

import Foundation

extension RankedElection {
    func bordaCount(ignoring eliminatedCandidates: Set<C>, maxRank: Int? = nil) -> [C : Int] {
        //some elections have a maximum rank, others allow voters to select from any candidate, including ones written-in
        //if a max rank is not supplied, this will assume that all candidates of an election are available for ranking
        func maxRankAssumingAllCandidatesAreIncluded() -> Int {
            let candidates = Set(candidates).subtracting(eliminatedCandidates)
            return candidates.count
        }
        
        let maxRank = maxRank ?? maxRankAssumingAllCandidatesAreIncluded()
        var bordaCount = Dictionary(uniqueKeysWithValues: candidates.map { ($0, 0) } )
        
        func bordaValue(for rank: Int?) -> Int {
            guard let rank else {
                return 0
            }
            return maxRank - rank + 1
        }

        //rankings now need to get turned around into point values
        for ballot in self.ballots {
            ballot.rankings.forEach { ranking in
                bordaCount[ranking.candidate] = (bordaCount[ranking.candidate] ?? 0) + bordaValue(for: ranking.rank)
            }
        }
        
        return bordaCount
    }
}
