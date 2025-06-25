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
public struct IRVRound<BallotID: BallotIdentifiable, C: Candidate> {
    typealias Ballot = RankedBallot<BallotID, C>
    
    let ballotCount: Int
    
    struct Tally {
        var candidate: C
        var votes: Int
    }
    
    var finalTally: [Tally] = []
    
    init(election: RankedElection<BallotID, C>, ignoring eliminatedCandidates: Set<C>) throws {
        try self.init(ballots:  Set(election.ballots), candidates: Set(election.candidates), ignoring: eliminatedCandidates)
    }
    
    init(ballots: Set<RankedBallot<BallotID, C>>, candidates: Set<C>, ignoring eliminatedCandidates: Set<C>) throws {
        self.ballotCount = ballots.count
        let tally = try IRVRound.tally(ballots: ballots, using: candidates, ignoring: eliminatedCandidates)
        self.finalTally = tally
    }
    
    /// The function that does the actual counting. Will initally sort the ballot by rank.
    static func tally(forNumPositions num: Int = 1, ballots: Set<RankedBallot<BallotID, C>>, using candidates: Set<C>, ignoring eliminatedCandidates: Set<C>) throws -> [Tally] {
        var voteCount: [C: Int] = [:]
        let candidates = candidates.subtracting(eliminatedCandidates)
        
        func incrementVote(for candidate: C) {
            if let count = voteCount[candidate] {
                voteCount[candidate] = count + 1
            } else {
                voteCount[candidate] = 1
            }
        }

        for candidate in candidates {
            voteCount[candidate] = 0
        }
        
        for ballot in ballots {
            let rankings = ballot.sortedByRank()
            if let candidate = rankings.first(where: { candidates.contains($0.candidate) } )?.candidate {
                incrementVote(for: candidate)
            }
        }
        
        return voteCount.map { Tally(candidate: $0.key, votes: $0.value) }.sorted(by: { $0.votes > $1.votes })
    }
    
    /// A helper to return the vote count for a given candidate
    subscript(_ candidate: C) -> Int? {
        return finalTally.first(where: { $0.candidate.id == candidate.id })?.votes
    }
    
    /// The candidate who has received a majority. Returns nil if no candidate has received a majority
    var majorityCandidate: C? {
        let candidates = finalTally.filter { $0.votes > ballotCount / 2 }.map(\.candidate)
        return candidates.first
    }
    
    func eliminationCandidate(using tiebreakerScheme: IRVTiebreakingStrategy) -> C? {
        switch tiebreakerScheme {
        case .random:
            guard let lowestMark = finalTally.last?.votes else { return nil }
            return self.finalTally.filter { $0.votes == lowestMark }.randomElement()?.candidate
        }
    }
}

extension IRVRound: CustomStringConvertible {
    public var description: String {
        finalTally.sorted(by: {
            $0.votes == $1.votes ? $0.candidate < $1.candidate : $0.votes > $1.votes
        }).map {
            String(describingAndUnwrapping: $0.candidate) + ": " + String(describingAndUnwrapping: $0.votes)
        }.joined(separator: ", ")
    }
}
