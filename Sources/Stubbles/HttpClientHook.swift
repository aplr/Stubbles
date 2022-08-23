//
//  HttpClientHook.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

protocol HttpClientHook {
    func load()
    func unload()
    func isEqual(to other: HttpClientHook) -> Bool
}

extension HttpClientHook where Self: Equatable {
    
    func isEqual(to other: HttpClientHook) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
    
}

func ==(lhs: HttpClientHook, rhs: HttpClientHook) -> Bool {
    lhs.isEqual(to: rhs)
}
