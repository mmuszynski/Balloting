//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/25/25.
//

import Foundation

struct IRVResult<BallotID: BallotIdentifiable, C: Candidate> {
//    typealias Round = IRVRound<BallotID, C>
//    let rounds: [Round]
//    let winner: C?
//    
//    init(election: RankedElection<BallotID, C>) throws {
//        //prepare storage for the winner
//        var winner: C? = nil
//        
//        //keep a list of the eliminated candidates
//        var eliminated: Set<C> = []
//        
//        //keep going while there isn't a winner or we have run out of candidates to eliminate
//        while winner == nil && eliminated.count == election.candidates.count {
//            //calculate the round
//            let round = try election.irvRound(ignoring: eliminated)
//            winner = round.majorityCandidate
//            
//            if let eliminationCandidate = round.eliminationCandidate(using: .random) {
//                eliminated.insert(eliminationCandidate)
//            } else {
//                print("Could not get lowest candidate")
//            }
//        }
//    }
}
