//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/1/25.
//

import Foundation

fileprivate extension String {
    init<T>(describingAndUnwrapping optional: T?) {
        if let optional {
            self = String(describing: optional)
        } else {
            self = String(describing: optional)
        }
    }
}

/// Describes the counting of a round of Instant Runoff Voting
///
///
public struct IRVRound<BallotID: BallotIdentifiable, CandidateID: CandidateIdentifiable> {
    typealias Ballot = RankedBallot<BallotID, CandidateID>
    
    /// The ballots used to count the round
    let ballots: Set<Ballot>
    
    /// The candidates used in the counting of this round
    ///
    /// - note: Only candidates in this set will be counted in the round
    let candidates: Set<CandidateID>
    
    /// The number of votes counted for each candidate
    ///
    /// Candidates will only receive votes if they are included in the set of candidates. This is useful for when a candidate has been eliminated as part of a previous round of voting. Thus, there may be instances where a candidate appears in the set of ballots but does not appear in the set of candiates. In this case, the candidate will not appear in the voteCount and will return nil.
    var voteCount: [CandidateID: Int] = [:]
    
    struct Tally {
        var candidate: CandidateID
        var votes: Int
    }
    
    var finalTally: [Tally] = []
    
    /// Initalizes the round results with a given set of ballots and a given set of candidates
    /// - Parameters:
    ///   - ballots: The ballots to be counted
    ///   - candidates: The candidates that should be used for counting. Any candidates that exist in the ballot, but not in the candidate set will not be counted.
    init(ballots: Set<Ballot>, candidates: Set<CandidateID>) throws {
        self.ballots = ballots
        self.candidates = candidates
        
        try tally()
    }
    
    /// The function that does the actual counting. Assumes that the choices on the ballot are sorted by rank.
    /// - Parameter num: The number of positions to be filled by the election
    mutating func tally(forNumPositions num: Int = 1) throws {
        for candidate in candidates {
            voteCount[candidate] = 0
        }
        
        for ballot in ballots {
            if let candidate = ballot.rankings.first(where: { candidates.contains($0.candidate) } )?.candidate {
                self.incrementVote(for: candidate)
            }
        }
        
        finalTally = voteCount.map { Tally(candidate: $0.key, votes: $0.value) }.sorted(by: { $0.votes > $1.votes })
    }
    
    /// A function to increment the vote for a given candidate by one.
    /// - Parameter candidate: The candidate whose vote should be incremented.
    private mutating func incrementVote(for candidate: CandidateID) {
        if let count = voteCount[candidate] {
            voteCount[candidate] = count + 1
        } else {
            voteCount[candidate] = 1
        }
    }
    
    /// A helper to return the vote count for a given candidate
    subscript(_ candidate: CandidateID) -> Int? {
        return voteCount[candidate]
    }
    
    /// The candidate who has received a majority. Returns nil if no candidate has received a majority
    var majorityCandidate: CandidateID? {
        let totalBallots = self.ballots.count
        let candidates = voteCount.filter { $0.value > totalBallots / 2 }.map(\.key)
        return candidates.first
    }
    
    enum Tiebreaker {
        case random
    }
    
    func eliminationCandidate(using tiebreakerScheme: Tiebreaker) -> CandidateID? {
        switch tiebreakerScheme {
        case .random:
            guard let lowestMark = finalTally.last?.votes else { return nil }
            return self.finalTally.filter { $0.votes == lowestMark }.randomElement()?.candidate
        }
    }
}

extension IRVRound: CustomStringConvertible {
    public var description: String {
        voteCount.sorted(by: {
            $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value
        }).map {
            String(describingAndUnwrapping: $0.key) + ": " + String(describingAndUnwrapping: $0.value)
        }.joined(separator: ", ")
    }
}
