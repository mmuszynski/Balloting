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

let prompt =
"""
Please rank the choices for dessert [Chocolate Cake]    Please rank the choices for dessert [Cheesecake]    Please rank the choices for dessert [Apple Pie]    Please rank the choices for dessert [Carrot Cake]    Please rank the choices for dessert [Pumpkin Pie]    Please rank the choices for dessert [Angelfood Cake]
"""

let rawCSV =
"""
2/24/2025 20:39:34, , 2nd, 4th, 1st, 3rd, 5th
2/24/2025 20:44:11, , 4th, 2nd, 1st, 3rd
2/24/2025 20:52:01, 3rd, 1st, 4th, 2nd, 6th, 5th
2/24/2025 21:27:13, 1st, 2nd, , 3rd, 4th
2/24/2025 21:31:58, 1st, 2nd, 3rd, 4th
2/24/2025 22:12:31, 1st, 2nd, , , 3rd, 4th
2/24/2025 23:12:19, 4th, 1st, 2nd, 3rd
2/25/2025 0:05:27, 4th, 2nd, 3rd, 1st
2/25/2025 0:55:54, 1st, 4th, 6th, 3rd, 5th, 2nd
2/25/2025 1:02:42, 1st, 2nd, 3rd, 5th, 4th, 6th
2/25/2025 4:45:44, 3rd, 4th, 1st, 2nd
2/25/2025 13:39:17, 1st, 4th, 3rd, 5th, 6th, 2nd
2/25/2025 17:03:09, 5th, 4th, 6th, 3rd, 1st, 2nd
2/25/2025 17:03:24, 6th, 3rd, 4th, 1st, 2nd, 5th
2/25/2025 17:38:39, 1st, 6th, 3rd, 5th, 4th, 2nd
2/25/2025 20:03:06, 1st, 3rd, 4th, 2nd
2/25/2025 21:30:30, 3rd, 1st, 4th, 2nd
2/25/2025 22:16:17, , 3rd, 1st, 4th, , 2nd
2/26/2025 1:25:10, 5th, 3rd, 4th, 1st, 2nd, 6th
2/26/2025 3:03:53, 4th, 1st, 2nd, 5th, 3rd, 6th
2/26/2025 8:36:57, 4th, 5th, 2nd, 3rd, 1st, 6th
2/26/2025 11:38:13, 6th, 5th, 2nd, 3rd, 1st, 4th
2/26/2025 22:19:12, , , 3rd, 2nd, 1st
2/26/2025 22:44:00, 3rd, 5th, 2nd, 1st, 4th, 6th
2/26/2025 23:06:20, , 2nd, , 1st, 4th, 3rd
2/27/2025 6:58:18, 2nd, 3rd, 1st, , , 4th
2/27/2025 8:11:41, 1st, 4th, 2nd, 3rd
2/28/2025 21:48:53, 1st, 2nd, 4th, , 3rd
"""

struct GoogleFormResultsTest {
    let election: RankedElection<String, String>
    
    init() async throws {
        typealias Ballot = RankedBallot<String, String>
        
        let dateFormatter = {
           let df = DateFormatter()
           //2/24/2025 20:39:34
           df.dateFormat = "M/d/yyyy HH:mm:ss"
           return df
       }()
        
        let candidates: [String] = prompt
            .replacingOccurrences(of: "]    ", with: ",")
            .replacingOccurrences(of: "Please rank the choices for dessert [", with: "")
            .replacingOccurrences(of: "]", with: "")
            .components(separatedBy: ",")
        
        let ballotLines = rawCSV.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        let ballots: [RankedBallot<String, String>] = ballotLines.map { line in
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
            
            return RankedBallot(id: dateString, rankings: choices)
        }
        
        election = RankedElection(candidates: candidates, ballots: ballots)
    }
    
    @Test func setup() {
        #expect(throws: Never.self) { election }
    }
}
