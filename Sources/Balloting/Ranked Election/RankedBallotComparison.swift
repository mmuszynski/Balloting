//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 5/29/25.
//

import Foundation

extension RankedBallot {
    struct CandidateComparison: CustomStringConvertible {
        var candidate1Ranking: CandidateRanking
        var candidate2Ranking: CandidateRanking
        
        var result: ComparisonResult {
            let candidate1Ranking = candidate1Ranking.rank ?? .max
            let candidate2Ranking = candidate2Ranking.rank ?? .max
            
            if candidate1Ranking < candidate2Ranking { return .orderedAscending }
            if candidate2Ranking < candidate1Ranking { return .orderedDescending }
            
            return .orderedSame
        }
        
        var winner: CandidateID? {
            let result = result
            switch result {
            case .orderedSame:
                return nil
            case .orderedAscending:
                return candidate1Ranking.candidate
            case .orderedDescending:
                return candidate2Ranking.candidate
            }
        }
        
        var description: String {
            var returnValue = ""
            if let ranking = candidate1Ranking.rank {
                returnValue += "\(ranking)"
            } else {
                returnValue += "(unranked)"
            }
            
            if let ranking2 = candidate2Ranking.rank {
                returnValue += "-\(ranking2)"
            } else {
                returnValue += "-(unranked)"
            }
            
            return returnValue
        }
    }
}
