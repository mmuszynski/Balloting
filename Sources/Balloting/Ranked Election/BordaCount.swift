//
//  File.swift
//  Balloting
//
//  Created by Mike Muszynski on 6/26/25.
//

import Foundation

public struct BordaCount<C: Candidate> {
    public typealias Element = (candidate: C, value: Int)
    private let store: [Element]
    
    init(using ballots: Set<RankedBallot<some BallotIdentifiable, C>>, ignoring eliminatedCandidates: Set<C>, maxRank: Int? = nil) {
        //I pulled this out of the election struct. I wonder if it will cause performance issues in the future.
        let candidates = ballots.reduce(into: Set<C>()) { partialResult, ballot in
            partialResult.formUnion(ballot.rankings.map(\.candidate))
        }
        
        //some elections have a maximum rank, others allow voters to select from any candidate, including ones written-in
        //if a max rank is not supplied, this will assume that all candidates of an election are available for ranking
        func maxRankAssumingAllCandidatesAreIncluded() -> Int {
            let candidates = Set(candidates).subtracting(eliminatedCandidates)
            return candidates.count
        }
        
        let maxRank = maxRank ?? maxRankAssumingAllCandidatesAreIncluded()
        var bordaCount = Dictionary(uniqueKeysWithValues: candidates.map { ($0, 0) } )
        
        func bordaValue(for rank: Int?) -> Int {
            guard let rank else {
                return 0
            }
            return maxRank - rank + 1
        }

        //rankings now need to get turned around into point values
        for ballot in ballots {
            ballot.rankings.forEach { ranking in
                bordaCount[ranking.candidate] = (bordaCount[ranking.candidate] ?? 0) + bordaValue(for: ranking.rank)
            }
        }
        
        self.store = bordaCount.sortedByValue()
    }
    
    public subscript(_ candidate: C) -> Int? {
        store.first { $0.candidate == candidate }?.value
    }
}

extension BordaCount: Collection {
    public typealias Index = Array<Element>.Index
    public var startIndex: Index {
        store.startIndex
    }
    
    public var endIndex: Array<Element>.Index {
        store.endIndex
    }
    
    public subscript(position: Int) -> Element {
        store[position]
    }
    
    public func index(after i: Array<Element>.Index) -> Array<Element>.Index {
        store.index(after: i)
    }
    
    public var last: Element? {
        store.last
    }
}

//extension RankedElection {
//    static func bordaCount(using ballots: Set<Self.Ballot>, ignoring eliminatedCandidates: Set<C>, maxRank: Int? = nil) -> [C : Int] {
//        //I pulled this out of the election struct. I wonder if it will cause performance issues in the future.
//        let candidates = ballots.reduce(into: Set<C>()) { partialResult, ballot in
//            partialResult.formUnion(ballot.rankings.map(\.candidate))
//        }
//        
//        //some elections have a maximum rank, others allow voters to select from any candidate, including ones written-in
//        //if a max rank is not supplied, this will assume that all candidates of an election are available for ranking
//        func maxRankAssumingAllCandidatesAreIncluded() -> Int {
//            let candidates = Set(candidates).subtracting(eliminatedCandidates)
//            return candidates.count
//        }
//        
//        let maxRank = maxRank ?? maxRankAssumingAllCandidatesAreIncluded()
//        var bordaCount = Dictionary(uniqueKeysWithValues: candidates.map { ($0, 0) } )
//        
//        func bordaValue(for rank: Int?) -> Int {
//            guard let rank else {
//                return 0
//            }
//            return maxRank - rank + 1
//        }
//
//        //rankings now need to get turned around into point values
//        for ballot in ballots {
//            ballot.rankings.forEach { ranking in
//                bordaCount[ranking.candidate] = (bordaCount[ranking.candidate] ?? 0) + bordaValue(for: ranking.rank)
//            }
//        }
//        
//        return bordaCount
//    }
//}
