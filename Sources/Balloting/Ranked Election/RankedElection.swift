//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 5/31/25.
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

public protocol RankedElectionProtocol: Election, Codable {
    associatedtype Ballot: RankedBallotProtocol
    associatedtype Candidate
    
    var ballots: [Ballot] { get set }
    var isRunning: Bool { get }
    var candidates: [Candidate] { get set }
    mutating func addEmptyBallot(id: Ballot.ID, with candidates: [Candidate])
}

/// Describes an election using a ranked ballot
///
/// This struct describes the parts of an election that uses a ranked, unweighted balloting system. In this type of election, a slate of candidates is given a ranking from most preferred to least preferred on a given number of ballots. This struct is generic across a number of dimensions, including the way candidates are identified (see `CandidateIdentifiable`) and the way ballots are identified (see `BallotIdentifiable`). This should allow ballots and candidates to conform to the Identifiable protocol required of most SwiftUI views.
///
/// Further, `RankedElection` conforms to the `Codable` protocol, allowing it to be serialized and unserialized. There is a custom application of `Decodable` and `Encodable` in order to pack the information tighter than the standard syntesized conformance.
public struct RankedElection<BallotID: BallotIdentifiable, C: Candidate>: RankedElectionProtocol, Sendable {
    public typealias Ballot = RankedBallot<BallotID, C>
    
    public var candidates: Array<C>
    public var ballots: Array<Ballot>
    
    public var configuration: ElectionConfiguration = .init()
    
    public var isRunning: Bool {
        return Date() >= configuration.beginDate
    }
    
    /// Initalizes a `RankedElection` with the provided candidates and ballots. Generates a candidate list if none is provided.
    ///
    /// - Parameters:
    ///   - candidates: The ID for each candidate in the election. This value is generated if it is not set at initialization time.
    ///   - ballots: The ballots for the election.
    public init(candidates: Array<C> = [], ballots: Array<Ballot>) {
        self.candidates = candidates
        self.ballots = ballots
        
        if candidates.isEmpty {
            var candidateSet = Set<C>()
            ballots.forEach { ballot in
                candidateSet.formUnion(ballot.rankings.map(\.candidate))
            }
            self.candidates = Array(candidateSet.sorted())
        }
    }
    
    public func irvRound<S>(ignoring eliminated: S, breakingTiesWith tiebreakProcedure: [IRVTiebreakingStrategy] = [.failure]) throws -> IRVRound<BallotID, C> where S: Sequence, S.Element == C {
        return try IRVRound(election: self, ignoring: Set(eliminated), breakingTiesWith: tiebreakProcedure)
    }
    
    public func condorcetResult() throws -> CondorcetResult<BallotID, C> {
        try CondorcetResult(ballots: Array(ballots))
    }
    
    mutating public func addEmptyBallot(id: BallotID, with candidates: [C]) {
        let ballot = Ballot(id: id, rankings: candidates.map { Ballot.Ranking(candidate: $0, rank: nil) })
        self.ballots.append(ballot)
    }

}

/*
 The synthesized encoding process resulted in a lot of duplicate information (for example, the ID of every candidate was included in every ballot). This implementation packs the information into a tighter form, but requires that a few more steps happen. In the end, there will be two main parts encoded: the list of canidates (sorted by their default), and the rankings provided on each ballot, sorted in the same order as the candidates.
 */
extension RankedElection: Codable {
    typealias EncodedBallots = [BallotID: [Int?]]
    
    enum CodingKeys: CodingKey {
        case candidates
        case encodedBallots
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(candidates, forKey: .candidates)
        
        var encodedBallots = EncodedBallots()
        try ballots.forEach { ballot in
            encodedBallots[ballot.id] = try ballot.orderedRankings(by: candidates.sorted()).map(\.rank)
        }

        try container.encode(encodedBallots, forKey: .encodedBallots)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let candidates = try container.decode(Array<C>.self, forKey: .candidates).sorted()
        let encodedBallots = try container.decode(EncodedBallots.self, forKey: .encodedBallots)
        
        let ballots = try encodedBallots.map { (ballotID, rankings) in
            try Ballot(id: ballotID, rankings: rankings.enumerated().map { (index, rank) in
                guard index < candidates.count else {
                    throw CandidateError.couldNotFindCandidate
                }
                let candidateID = candidates[index]
                return Ballot.Ranking(candidate: candidateID, rank: rank)
            })
        }
        
        self.candidates = candidates
        self.ballots = ballots
    }
}

extension RankedElection: CustomStringConvertible {
    public var description: String {
        var returnValue = "Election\r"
        
        //append Candidate IDs
        let candidatesHeader = candidates.map(String.init(describing:)).sorted().joined(separator: ", ")
        returnValue += "ID, " + " " + candidatesHeader + "\r"
        
        do {
            //append ballots
            returnValue += try ballots
                .sorted(by: { $0.id < $1.id })
                .map { theBallot in
                    let id = String(describing: theBallot.id)
                    let ballot = try theBallot.orderedRankings(by: candidates.sorted()).map(\.rank).map(String.init(describingAndUnwrapping:)).joined(separator: ", ")
                    return id + ": " + ballot
                }
                .joined(separator: "\r")
        } catch {
            return "Could not describe election with \(error)"
        }
        
        return returnValue
    }
}

extension RankedElection: Equatable {
    public static func ==(lhs: RankedElection, rhs: RankedElection) -> Bool {
        return lhs.description == rhs.description
    }
}
