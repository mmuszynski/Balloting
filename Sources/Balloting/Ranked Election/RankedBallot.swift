//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 5/24/25.
//

import Foundation

/// Represents a ranking of candidates. No error checking takes place to make sure that the ballot uses the correct number of rankings.
public struct RankedBallot<BallotID: BallotIdentifiable, CandidateID: CandidateIdentifiable>: Ballot, Identifiable, Sendable {
    /// Contains a ranking and a candidate ID. If a candidate is unranked, the ranking will be nil.
    public struct CandidateRanking: Codable, Sendable, Identifiable {
        public var id: CandidateID { candidate }
        
        public var candidate: CandidateID
        public var rank: Int?
        
        public init(candidate: CandidateID, rank: Int? = nil) {
            self.candidate = candidate
            self.rank = rank
        }
    }
    
    public let id: BallotID
    public var rankings: [CandidateRanking]
    
    /// Initializes a ballot with a given set of candidates and their rankings all set to nil.
    /// - Parameters:
    ///   - id: The unique identifier for the ballot
    ///   - candidates: The list of candidates
    static func blank(id: BallotID, candidates: [CandidateID]) -> Ballot {
        RankedBallot<BallotID, CandidateID>(id: id, rankings: candidates.map { CandidateRanking(candidate: $0) })
    }
    
    public init(id: BallotID, rankings: [CandidateRanking]) {
        self.id = id
        self.rankings = rankings
    }
    
    public mutating func sortByCandidate() {
        self.rankings.sort { $0.candidate < $1.candidate }
    }
    
    public mutating func sortByRanking() {
        self.rankings = self.sortedByRank()
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
        let firstRanking = self[candidate1] ?? CandidateRanking(candidate: candidate1, rank: nil)
        let secondRanking = self[candidate2] ?? CandidateRanking(candidate: candidate2, rank: nil)
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
        //return rankings.filter { $0.rank != nil }.filter { candidates.contains($0.candidate) }.sorted { $0.rank! < $1.rank! }
        return rankings.filter { candidates.contains($0.candidate) }
    }
    
    public func sortedByRank() -> [CandidateRanking] {
        self.rankings.sorted(by: { $0.rank ?? Int.max < $1.rank ?? Int.max })
    }
    
    /// Counts the number of vote rankings that are ignored
    /// - Parameter candidates: The candidates to use for counting
    /// - Returns: The number of candidates that were not selected in the ranking process
    public func undervoteCount(using candidates: [CandidateID]) -> Int {
        self.rankings.count(where: { $0.rank == nil && candidates.contains($0.candidate) })
    }
    
    public var textualDescription: String {
        rankings.sorted { $0.candidate < $1.candidate }.map { String($0.rank ?? 0) }.joined(separator: " ")
    }
}

extension RankedBallot: CustomStringConvertible {
    public var description: String {
        "Ballot (\(id))\r" + rankings.reduce("", { partialResult, ranking in
            partialResult + "\(ranking.candidate),\(ranking.rank == nil ? "unranked" : String(describing: ranking.rank!))\r"
        })
    }
}

extension RankedBallot: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension RankedBallot: Equatable {
    public static func == (lhs: RankedBallot, rhs: RankedBallot) -> Bool {
        return lhs.id == rhs.id
    }
}

extension RankedBallot: Collection {
    public typealias Index = Array<CandidateRanking>.Index
    
    public func index(after i: Index) -> Index {
        rankings.index(after: i)
    }
    
    public var startIndex: Index {
        rankings.startIndex
    }
    
    public var endIndex: Index {
        rankings.endIndex
    }
    
    public subscript(index: Index) -> CandidateRanking {
        rankings[index]
    }
    
    public subscript(_ candidate: CandidateID) -> CandidateRanking? {
        rankings.first { $0.candidate == candidate }
    }
}

extension RankedBallot: Comparable {
    public static func < (lhs: RankedBallot, rhs: RankedBallot) -> Bool {
        lhs.id < rhs.id
    }
}
