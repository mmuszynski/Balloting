//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 5/24/25.
//

import Foundation

/// Represents a ranking of candidates. No error checking takes place to make sure that the ballot uses the correct number of rankings.
struct RankedBallot<BallotID: BallotIdentifiable, CandidateID: CandidateIdentifiable>: Identifiable, Sendable {
    /// Contains a ranking and a candidate ID. If a candidate is unranked, the ranking will be nil.
    struct CandidateRanking: Codable {
        var candidate: CandidateID        
        var rank: Int?
    }
    
    let id: BallotID
    let rankings: [CandidateRanking]
    
    subscript(_ candidate: CandidateID) -> CandidateRanking? {
        rankings.first { $0.candidate == candidate }
    }
    
    /// Calculates a preference for a given candidate on this ballot
    ///
    /// Given that rankings are listed in order from 1 to the number of candidates, the preference for a given candidate must be calculated
    ///
    /// - Parameter candidateID: The identifier for the given candidate
    /// - Returns: A preference for the candidate identified by the candidateID
    func preference(for candidateID: CandidateID) throws -> Int {
        let count = rankings.count
        guard let rank = self[candidateID] else {
            throw CandidateError.couldNotFindCandidate
        }
        
        guard let ranking = rank.rank else { return 0 }
        
        return count - ranking + 1
    }
    
    func preference(between candidate1: CandidateID, and candidate2: CandidateID) throws -> CandidateID? {
        let ranking = try comparison(between: candidate1, and: candidate2)
        if ranking.result == .orderedAscending { return candidate1 }
        if ranking.result == .orderedDescending { return candidate2 }
        return nil
    }
    
    func comparison(between candidate1: CandidateID, and candidate2: CandidateID) throws -> CandidateComparison {
        guard let firstRanking = self[candidate1] else { throw CandidateError.couldNotFindCandidate }
        guard let secondRanking = self[candidate2] else { throw CandidateError.couldNotFindCandidate }
        return CandidateComparison(candidate1Ranking: firstRanking, candidate2Ranking: secondRanking)
    }
    
    func orderedRankings(by candidateIDs: [CandidateID]) throws -> [CandidateRanking] {
        try rankings.sorted { (ranking1, ranking2) -> Bool in
            guard let firstIndex = candidateIDs.firstIndex(where: { $0 == ranking1.candidate }) else {
                throw CandidateError.couldNotFindCandidate
            }
            guard let secondIndex = candidateIDs.firstIndex(where: { $0 == ranking2.candidate }) else {
                throw CandidateError.couldNotFindCandidate
            }
            return firstIndex < secondIndex
        }
    }
    
    /// The candidate with the highest ranking on this ballot
    /// - Parameter candidates: An array of candidates to use in the ranking (all others will be ignored)
    /// - Returns: The `CandidateID` for the candidate who is ranked highest, or nil if no such candidate exists
    func highestRankedCandidate(using candidates: [CandidateID]) throws -> CandidateID? {
        try candidatesOrderedByRank(using: candidates).first?.candidate
    }
    
    /// Orders the candidates by rank, ignoring unranked candidates on the ballot and removing candidates who belong to the eliminated array
    /// - Parameter candidates: An array of candidates to use in the ranking (all others will be ignored)
    /// - Returns: A list of candidate rankings, ordered by preference and ignoring candidates that are not in the candidates array
    func candidatesOrderedByRank(using candidates: [CandidateID]) throws -> [CandidateRanking] {
        if candidates.isEmpty { throw CandidateError.noCandidatesProvided }
        return Array(rankings.filter { $0.rank != nil }.filter { candidates.contains($0.candidate) }.sorted { $0.rank! < $1.rank! })
    }
}

extension RankedBallot: CustomStringConvertible {
    var description: String {
        "Ballot (\(id))\r" + rankings.reduce("", { partialResult, ranking in
            partialResult + "\(ranking.candidate),\(ranking.rank == nil ? "unranked" : String(describing: ranking.rank!))\r"
        })
    }
}

extension RankedBallot: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension RankedBallot: Equatable {
    static func == (lhs: RankedBallot, rhs: RankedBallot) -> Bool {
        return lhs.id == rhs.id
    }
}
