//
//  GoogleFormResultsTest.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/1/25.
//

import Testing
import Foundation
@testable import Balloting

//The results of these elections comes from the google form with results at  https://docs.google.com/spreadsheets/d/1PB8zEAj1a-JXScfxqcZd-tM29HOzKN1lE4oOmerUZlw/edit?gid=1301572243#gid=1301572243


func loadDessertElection() throws -> RankedElection<Date, String> {
    typealias Ballot = RankedBallot<Date, String>

    let dateFormatter = {
       let df = DateFormatter()
       //2/24/2025 20:39:34
       df.dateFormat = "M/d/yyyy HH:mm:ss"
       return df
   }()
    
    let url = Bundle.module.url(forResource: "Dessert", withExtension: "txt")!
    let text = try String(contentsOf: url, encoding: .utf8)
    let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
    
    let candidates: [String] = lines.first!
        .replacingOccurrences(of: "]    ", with: ",")
        .replacingOccurrences(of: "Please rank the choices for dessert [", with: "")
        .replacingOccurrences(of: "]", with: "")
        .components(separatedBy: ",")
            
    let ballots: [Ballot] = lines.dropFirst().map { line in
        let components = line.components(separatedBy: ", ")
        
        let dateString = components.first!
        let date = dateFormatter.date(from: dateString)!
        
        let choices = components.dropFirst().enumerated().map {
            let candidate = candidates[$0.offset]
            
            switch $0.element {
            case "1st":
                return Ballot.CandidateRanking(candidate: candidate, rank: 1)
            case "2nd":
                return Ballot.CandidateRanking(candidate: candidate, rank: 2)
            case "3rd":
                return Ballot.CandidateRanking(candidate: candidate, rank: 3)
            case "4th":
                return Ballot.CandidateRanking(candidate: candidate, rank: 4)
            case "5th":
                return Ballot.CandidateRanking(candidate: candidate, rank: 5)
            case "6th":
                return Ballot.CandidateRanking(candidate: candidate, rank: 6)
            default:
                return Ballot.CandidateRanking(candidate: candidate, rank: nil)
            }
        }
        
        return RankedBallot(id: date, rankings: choices)
    }
    
    return RankedElection(candidates: Set(candidates), ballots: Set(ballots))
}

struct GoogleFormResultsTest {
    let election: RankedElection<Date, String>
        
    init() async throws {
        election = try loadDessertElection()
    }
    
    @Test func setup() async throws {
        #expect(throws: Never.self) { election }
    }
    
    @Test func irv() async throws {
        let firstResult = try election.irvRound(ingoring: [])
    }
}
