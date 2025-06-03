//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/1/25.
//

import Foundation

/// Describes the counting of a round of Instant Runoff Voting
///
///
struct IRVRound<BallotID: BallotIdentifiable, CandidateID: CandidateIdentifiable> {
    typealias Ballot = RankedBallot<BallotID, CandidateID>
    
    /// The ballots used to count the round
    let ballots: Set<Ballot>
    
    /// The candidates used in the counting of this round
    ///
    /// - note: Only candidates in this set will be counted in the round
    let candidates: Set<CandidateID>
    
    let voteCount: [CandidateID: Int]
    
    init(ballots: Set<Ballot>, candidates: Set<CandidateID>) throws {
        self.ballots = ballots
        self.candidates = candidates
        
        func tally(forNumPositions num: Int = 1) throws -> [CandidateID: Int] {
            try candidates.reduce(into: [:]) { output, candidate in
                try output[candidate] = ballots.count(where: {
                    let orderedCandidates = try $0.candidatesOrderedByRank(using: Array(candidates))
                    return orderedCandidates[0..<num].contains(where: { $0.candidate == candidate })
                })
            }
        }
        
        voteCount = try tally()
    }
    
    subscript(_ candidate: CandidateID) -> Int? {
        return voteCount[candidate]
    }
}
