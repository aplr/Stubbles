//
//  NSNumber+IsBool.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

extension NSNumber {
    
    var isBool: Bool {
        type(of: self) == type(of: NSNumber(value: true))
    }
    
}
