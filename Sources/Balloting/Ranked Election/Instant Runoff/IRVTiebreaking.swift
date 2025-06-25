//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/25/25.
//

import Foundation

enum IRVTiebreakingStrategy {
    case random
    
    func calculateVictor<C: Candidate>(between candidate1: C, and candidate2: C) throws -> C {
        return [candidate1, candidate1].randomElement()!
    }
}
