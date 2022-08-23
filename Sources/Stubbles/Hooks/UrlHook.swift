//
//  UrlHook.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

final class UrlHook: HttpClientHook {
    
    func load() {
        URLProtocol.registerClass(HttpStubUrlProtocol.self)
    }
    
    func unload() {
        URLProtocol.unregisterClass(HttpStubUrlProtocol.self)
    }
    
    func isEqual(to other: HttpClientHook) -> Bool {
        guard let other = other as? UrlHook else { return false }
        return other == self
    }
}
