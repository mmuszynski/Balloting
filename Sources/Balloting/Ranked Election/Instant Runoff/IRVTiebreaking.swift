//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/25/25.
//

import Foundation

public enum IRVTiebreakingStrategy {
    case random
    case failure
    
    func generateEliminatedCandidates<C: Candidate>(from eliminationCandidates: [C]) -> [C] {
        switch self {
        case .random:
            //selects a random candidate to eliminate
            return [eliminationCandidates.randomElement()].compactMap(\.self)
        case .failure:
            //represents that a failure should occur, and that election counting should be halted
            return eliminationCandidates
        }
    }
}
