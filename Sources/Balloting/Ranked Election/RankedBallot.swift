//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 5/24/25.
//

import Foundation

/// Represents a ranking of candidates. No error checking takes place to make sure that the ballot uses the correct number of rankings.
public struct RankedBallot<BallotID: BallotIdentifiable, C: Candidate>: Ballot, Identifiable, Sendable {
    /// Contains a ranking and a candidate ID. If a candidate is unranked, the ranking will be nil.
    public struct CandidateRanking: Codable, Sendable, Identifiable {
        public var id: C.ID { candidate.id }
        
        public var candidate: C
        public var rank: Int?
        
        public init(candidate: C, rank: Int? = nil) {
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
    static func blank(id: BallotID, candidates: [C]) -> Ballot {
        RankedBallot<BallotID, C>(id: id, rankings: candidates.map { CandidateRanking(candidate: $0) })
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
    func preference(for candidateID: C) throws -> Int {
        let count = rankings.count
        guard let rank = self[candidateID] else {
            throw CandidateError.couldNotFindCandidate
        }
        
        guard let ranking = rank.rank else { return 0 }
        
        return count - ranking + 1
    }
    
    func preference(between candidate1: C, and candidate2: C) throws -> C? {
        let ranking = try comparison(between: candidate1, and: candidate2)
        if ranking.result == .orderedAscending { return candidate1 }
        if ranking.result == .orderedDescending { return candidate2 }
        return nil
    }
    
    func comparison(between candidate1: C, and candidate2: C) throws -> CandidateComparison {
        let firstRanking = self[candidate1] ?? CandidateRanking(candidate: candidate1, rank: nil)
        let secondRanking = self[candidate2] ?? CandidateRanking(candidate: candidate2, rank: nil)
        return CandidateComparison(candidate1Ranking: firstRanking, candidate2Ranking: secondRanking)
    }
    
    func orderedRankings(by candidateIDs: [C]) throws -> [CandidateRanking] {
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
    func highestRankedCandidate(using candidates: [C]) throws -> C? {
        try candidatesOrderedByRank(using: candidates).first?.candidate
    }
    
    /// Orders the candidates by rank, ignoring unranked candidates on the ballot and removing candidates who belong to the eliminated array
    /// - Parameter candidates: An array of candidates to use in the ranking (all others will be ignored)
    /// - Returns: A list of candidate rankings, ordered by preference and ignoring candidates that are not in the candidates array
    func candidatesOrderedByRank(using candidates: [C]) throws -> [CandidateRanking] {
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
    public func undervoteCount(using candidates: [C]) -> Int {
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
    
    public subscript(_ candidate: C) -> CandidateRanking? {
        rankings.first { $0.candidate == candidate }
    }
}

extension RankedBallot: Comparable {
    public static func < (lhs: RankedBallot, rhs: RankedBallot) -> Bool {
        lhs.id < rhs.id
    }
}

/*
 ==================================================================================================
 MARK: CSV Import/Export
 ==================================================================================================
 */

extension RankedBallot {
    
    func csvLineRepresentation(withCandidateOrder candidateOrder: [C] = []) -> String {
        let candidateOrder = candidateOrder.isEmpty ? self.rankings.map(\.candidate).sorted() : candidateOrder
        let idString = String(describing: self.id)
        
        let rankings = candidateOrder
            .map { self[$0]?.rank ?? 0 }
            .map(String.init)
        
        return ([idString] + rankings).joined(separator: ",")
    }
    
    public init(csvRepresentation: String, with candidateOrder: [C]) {
        
        //Separate components by commas
        var components = csvRepresentation.components(separatedBy: ",")
        
        //Use the first of these as the id string
        let idString = components.removeFirst()
        
        //Translate that ID string to the actual ID type
        let id = BallotID(csvString: idString)
        
        let rankings = components.enumerated().map { offset, rank in
            guard let rank = Int(rank) else { fatalError() }
            return CandidateRanking(candidate: candidateOrder[offset], rank: rank == 0 ? nil : rank)
        }
        
        self.id = id
        self.rankings = rankings
    }
    
}

extension RankedElection {
    
    public func csvRepresentation(withCandidateOrder order: [C] = []) -> String {
        let order = order.isEmpty ? self.candidates : order
        
        var header = order.map(\.id).map(String.init(describing:))
        header.insert("Ballot ID", at: 0)
        let csvData = self.ballots.map { $0.csvLineRepresentation(withCandidateOrder: order) }
        
        return ([header.joined(separator: ",")] + csvData).joined(separator: "\n")
    }
    
    mutating func loadBallots(from csvString: String, with candidates: [C]) throws {
        var lines = csvString.components(separatedBy: .newlines)
        
        let headers = lines.remove(at: 0).components(separatedBy: ",").dropFirst().map { C.ID(csvString: $0) }
        
        let candidateLookup = candidates.reduce(into: Dictionary<C.ID, C>()) { result, next in
            result[next.id] = next
        }
        
        let candidates = headers.compactMap { candidateLookup[$0] }
        
        self.ballots = lines.map { RankedBallot<BallotID, C>(csvRepresentation: $0, with: candidates) }
    }
    
    public init(csvRepresentation: String, with candidates: [C] = []) throws {
        var election = Self.init(ballots: [])
        try election.loadBallots(from: csvRepresentation, with: candidates)
        self = election
    }
    
}
