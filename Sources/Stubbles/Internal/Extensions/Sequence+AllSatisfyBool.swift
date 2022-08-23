//
//  Sequence+AllSatisfyBool.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

extension Sequence where Element == Bool {
    
    func allSatisfy() -> Bool {
        allSatisfy({ $0 })
    }
    
}
