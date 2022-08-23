//
//  Dictionary+Append.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation


func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
}
