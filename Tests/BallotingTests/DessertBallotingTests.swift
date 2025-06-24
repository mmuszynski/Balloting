import Testing
import Foundation
@testable import Balloting

let candidates = ["Chocolate Cake", "Cheesecake", "Apple Pie", "Carrot Cake", "Pumpkin Pie", "Angelfood Cake"]

let rawRankings = [
    "0, 2, 4, 1, 3, 5",
    "0, 4, 2, 1, 3, 0",
    "3, 1, 4, 2, 6, 5",
    "1, 2, 0, 3, 4, 0",
    "1, 2, 3, 4, 0, 0",
    "1, 2, 0, 0, 3, 4",
    "4, 1, 2, 3, 0, 0",
    "4, 2, 3, 1, 0, 0",
    "1, 4, 6, 3, 5, 2",
    "1, 2, 3, 5, 4, 6",
    "3, 4, 1, 2, 0, 0",
    "1, 4, 3, 5, 6, 2",
    "5, 4, 6, 3, 1, 2",
    "6, 3, 4, 1, 2, 5",
    "1, 6, 3, 5, 4, 2",
    "1, 3, 4, 2, 0, 0",
    "3, 1, 4, 2, 0, 0",
    "0, 3, 1, 4, 0, 2",
    "5, 3, 4, 1, 2, 6",
    "4, 1, 2, 5, 3, 6",
    "4, 5, 2, 3, 1, 6",
    "6, 5, 2, 3, 1, 4",
    "0, 0, 3, 2, 1, 0",
    "3, 5, 2, 1, 4, 6",
    "0, 2, 0, 1, 4, 3",
    "0, 3, 1, 0, 0, 4",
    "1, 4, 2, 3, 0, 0",
    "1, 2, 4, 0, 3, 0"
]

@MainActor let ballots = rawRankings.enumerated().map { (index, rankings) in
    let ranks = rankings.components(separatedBy: ", ").enumerated().map { (index, rank) in
        let rank = Int(rank)!
        return RankedBallot<Int, String>.CandidateRanking(candidate: candidates[index], rank: rank == 0 ? nil : rank)
    }
    return RankedBallot(id: index, rankings: ranks)
}

@MainActor let election = RankedElection(candidates: candidates, ballots: ballots)


@Test func example() async throws {
    await #expect(throws: Never.self) {
        let _ = try await CondorcetResult(ballots: ballots)
        //print(results.description)
    }
}

@Test func drawBallot() async throws {
    let first = RankedBallot<Int, String>.CandidateRanking(candidate: "Chocolate Cake", rank: nil)
    let second = RankedBallot<Int, String>.CandidateRanking(candidate: "Cheesecake", rank: nil)
    #expect(RankedBallot.CandidateComparison(candidate1Ranking: first, candidate2Ranking: second).winner == nil)
}

@MainActor
@Test func codable() async throws {
    let encoder = JSONEncoder()
    #expect(throws: Never.self) {
        let _ = try encoder.encode(election)
        //print(String(data: data, encoding: .utf8)!)
    }
}

@MainActor
@Test func description() async throws {
    //print(election)
}

@MainActor
@Test func codableRoundTrip() async throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    let data = try encoder.encode(election)
    let roundTripElection = try decoder.decode(RankedElection<Int, String>.self, from: data)
    
    #expect(election == roundTripElection)
    
    //output data if necessary
    print(String(data: data, encoding: .utf8))
}
