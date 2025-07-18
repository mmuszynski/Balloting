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
    
    return RankedElection(candidates: candidates, ballots: ballots)
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
        let roundOne = try election.irvRound(ignoring: [])
        #expect(roundOne["Chocolate Cake"] == 10)
        #expect(roundOne["Carrot Cake"] == 7)
        #expect(roundOne["Cheesecake"] == 4)
        #expect(roundOne["Pumpkin Pie"] == 4)
        #expect(roundOne["Apple Pie"] == 3)
        #expect(roundOne["Angelfood Cake"] == 0)
        #expect(roundOne.description == "Chocolate Cake: 10, Carrot Cake: 7, Cheesecake: 4, Pumpkin Pie: 4, Apple Pie: 3, Angelfood Cake: 0")
        
        //This round should produce no winner
        //It should also produce one eliminated candidate, Angelfood Cake
        //No tiebreakers are used, so the tiebreaking history should be empty
        #expect(roundOne.majorityCandidate == nil)
        #expect(roundOne.tiebreakingHistory.isEmpty)
        #expect(roundOne.eliminatedCandidate == "Angelfood Cake")
        
        let roundTwo = try election.irvRound(ignoring: ["Angelfood Cake"])
        #expect(roundTwo["Chocolate Cake"] == 10)
        #expect(roundTwo["Carrot Cake"] == 7)
        #expect(roundTwo["Cheesecake"] == 4)
        #expect(roundTwo["Pumpkin Pie"] == 4)
        #expect(roundTwo["Apple Pie"] == 3)
        #expect(roundTwo["Angelfood Cake"] == nil)
        
        let roundThree = try election.irvRound(ignoring: ["Angelfood Cake", "Apple Pie"])
        #expect(roundThree["Chocolate Cake"] == 11)
        #expect(roundThree["Carrot Cake"] == 8)
        #expect(roundThree["Cheesecake"] == 5)
        #expect(roundThree["Pumpkin Pie"] == 4)
        #expect(roundThree["Apple Pie"] == nil)
        #expect(roundThree["Angelfood Cake"] == nil)
        
        let roundFour = try election.irvRound(ignoring: ["Angelfood Cake", "Apple Pie", "Pumpkin Pie"])
        #expect(roundFour["Chocolate Cake"] == 11)
        #expect(roundFour["Carrot Cake"] == 12)
        #expect(roundFour["Cheesecake"] == 5)
        #expect(roundFour["Pumpkin Pie"] == nil)
        #expect(roundFour["Apple Pie"] == nil)
        #expect(roundFour["Angelfood Cake"] == nil)
        
        let roundFive = try election.irvRound(ignoring: ["Angelfood Cake", "Apple Pie", "Pumpkin Pie", "Cheesecake"])
        #expect(roundFive["Chocolate Cake"] == 12)
        #expect(roundFive["Carrot Cake"] == 16)
        #expect(roundFive["Cheesecake"] == nil)
        #expect(roundFive["Pumpkin Pie"] == nil)
        #expect(roundFive["Apple Pie"] == nil)
        #expect(roundFive["Angelfood Cake"] == nil)
    }
    
    @Test
    func autoIRV() async throws {
        var winner: String? = nil
        var eliminated: Set<String> = []
        
        let tiebreakerStrategy = [IRVTiebreakingStrategy.failure]
        
        while winner == nil {
            let round = try election.irvRound(ignoring: eliminated, breakingTiesWith: tiebreakerStrategy)
            winner = round.majorityCandidate
            
            if let eliminationCandidate = round.eliminatedCandidate {
                eliminated.insert(eliminationCandidate)
            } else {
                print("Could not get lowest candidate")
                break
            }
        }
        #expect(winner == "Carrot Cake")
    }
    
    @Test
    func csvOutput() async throws {
        let csvString = election.csvRepresentation()
        print(csvString)
    }
}
