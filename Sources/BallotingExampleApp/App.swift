//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/5/25.
//

import SwiftUI
import Balloting

//@main
//struct Profile {
//    static func main() async throws {
//        try await Profile().minneapolisMayor()
//    }
//    
//    typealias Election = RankedElection<Int, String>
//    let election: Election
//    
//    init() throws {
//        let url = Bundle.module.url(forResource: "Minneapolis 2009 Mayor", withExtension: "csv")!
//        let string = try String(contentsOf: url, encoding: .utf8)
//        
//        let lines = string.components(separatedBy: .newlines).dropFirst().filter { !$0.isEmpty }
//        let ballots = lines.enumerated().map { offset, line in
//            let rankings: [Election.Ballot.CandidateRanking] = line.components(separatedBy: ",")[0..<4].dropFirst().compactMap { name in
//                if name == "XXX" { return nil }
//                return Election.Ballot.CandidateRanking(candidate: name, rank: 0)
//            }
//            return Election.Ballot(id: offset, rankings: rankings)
//        }
//        
//        election = Election(ballots: Set(ballots))
//    }
//    
//    func minneapolisMayor() async throws {
//        guard let url = Bundle.module.url(forResource: "Minneapolis 2009 Mayor", withExtension: "csv") else {
//            fatalError("Could not find data file.")
//        }
//        
//        let firstRoundResults = try election.irvRound()
//    }
//}

@main
struct BallotingExampleApp: App {
    init() {
      DispatchQueue.main.async {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
      }
    }
        
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
