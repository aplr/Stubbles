//
//  Dictionary+MapKeys.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

extension Dictionary {
    
    func mapKeys<T: Hashable>(_ transform: (Key) throws -> T) rethrows -> Dictionary<T, Value> {
        Dictionary<T, Value>(uniqueKeysWithValues: try map({ (key, value) in
            (try transform(key), value)
        }))
    }
    
}
