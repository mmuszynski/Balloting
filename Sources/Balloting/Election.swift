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

struct RankedElection<CandidateID: CandidateIdentifiable, BallotID: BallotIdentifiable> {
    typealias Ballot = RankedBallot<BallotID, CandidateID>
    
    var candidates: [CandidateID]
    var ballots: [Ballot]
}

extension RankedElection: Codable {
    enum CodingKeys: CodingKey {
        case candidates
        case encodedBallots
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(candidates, forKey: .candidates)
        
        var encodedBallots = [BallotID: [Int?]]()
        try ballots.forEach { ballot in
            encodedBallots[ballot.id] = try ballot.orderedRankings(by: candidates).map(\.rank)
        }

        try container.encode(encodedBallots, forKey: .encodedBallots)
    }
    
    init(from decoder: any Decoder) throws {
        fatalError()
    }
}

extension RankedElection: CustomStringConvertible {
    var description: String {
        var returnValue = "Election\r"
        
        //append Candidate IDs
        let candidatesHeader = candidates.map(String.init(describing:)).joined(separator: ", ")
        returnValue += "ID, " + " " + candidatesHeader + "\r"
        
        do {
            //append ballots
            returnValue += try ballots
                .sorted(by: { $0.id < $1.id })
                .map { theBallot in
                    let id = String(describing: theBallot.id)
                    let ballot = try theBallot.orderedRankings(by: candidates).map(\.rank).map(String.init(describingAndUnwrapping:)).joined(separator: ", ")
                    return id + ": " + ballot
                }
                .joined(separator: "\r")
        } catch {
            return "Could not describe election with \(error)"
        }
        
        return returnValue
    }
}
