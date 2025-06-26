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
public struct IRVRound<BallotID: BallotIdentifiable, C: Candidate> {
    typealias Ballot = RankedBallot<BallotID, C>
    
    let ballotCount: Int
    
    struct Tally {
        var candidate: C
        var votes: Int
    }
    
    let finalTally: [Tally]
    
    typealias TiebreakResult = (IRVTiebreakingStrategy, [C])
    let tiebreakingHistory: [TiebreakResult]
    let majorityCandidate: C?
    var eliminatedCandidate: C? {
        if tiebreakingHistory.isEmpty { return finalTally.last?.candidate }
        return tiebreakingHistory.last?.1.first
    }
        
    init(election: RankedElection<BallotID, C>,
         ignoring eliminatedCandidates: Set<C>,
         breakingTiesWith tiebreakProcedure: [IRVTiebreakingStrategy] = [.failure]) throws
    {
        try self.init(ballots:  Set(election.ballots),
                      candidates: Set(election.candidates),
                      ignoring: eliminatedCandidates,
                      breakingTiesWith: tiebreakProcedure)
    }
    
    init(ballots: Set<RankedBallot<BallotID, C>>,
         candidates: Set<C>,
         ignoring eliminatedCandidates: Set<C>,
         breakingTiesWith tiebreakProcedure: [IRVTiebreakingStrategy] = [.failure]) throws
    {
        self.ballotCount = ballots.count
        let tally = try IRVRound.tally(ballots: ballots, using: candidates, ignoring: eliminatedCandidates)
        self.finalTally = tally
                
        let majorityCandidates = finalTally.filter { $0.votes > ballots.count / 2 }.sorted(by: { $0.votes > $1.votes }).map(\.candidate)
        self.majorityCandidate = majorityCandidates.first
        
        
        /// Candidates who receive the fewest number of votes are candidates for elimination from the remaining rounds of the election. Assumes that the final tally is ordered by vote count.
        func breakTies(using tiebreakingProcedure: [IRVTiebreakingStrategy]) -> [TiebreakResult] {
            var tiebreakHistory: [TiebreakResult] = []

            //Get the lowest vote count
            guard let lowestVoteCount = tally.last?.votes else { return [] }
            
            //Select for the candidates that have that lowest vote count
            var potentialCanidatesForElimination = tally.filter { $0.votes == lowestVoteCount }.map { $0.candidate }
            
            //Using each of the strategies in the tiebreaking procedure
            //1. run their algorithm to select potential candidates for elimination
            //2. see if there is only one candidate, and return if so
            //3. run the next strategy with the same potential candidates
            for strategy in tiebreakingProcedure {
                if candidates.count == 1 { break }
                let candidates = strategy.generateEliminatedCandidates(from: potentialCanidatesForElimination)
                tiebreakHistory.append((strategy, candidates))
                potentialCanidatesForElimination = candidates
            }
            
            return tiebreakHistory
        }
        
        //break any ties
        tiebreakingHistory = breakTies(using: tiebreakProcedure)
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
    
    /// Returns the vote count for a given candidate
    subscript(_ candidate: C) -> Int? {
        return finalTally.first(where: { $0.candidate.id == candidate.id })?.votes
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
