//
//  UrlSessionHook.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

final class UrlSessionHook: HttpClientHook {
    
    func load() {
        guard let method = class_getInstanceMethod(originalClass, originalSelector),
              let stub = class_getInstanceMethod(UrlSessionHook.self, #selector(protocolClasses)) else {
            fatalError("Could not load UrlSessionHook")
        }
        method_exchangeImplementations(method, stub)
    }
    
    private var originalClass: AnyClass? {
        NSClassFromString("__NSCFURLSessionConfiguration") ?? NSClassFromString("NSURLSessionConfiguration")
    }
    
    private var originalSelector: Selector {
        #selector(getter: URLSessionConfiguration.protocolClasses)
    }
    
    @objc private func protocolClasses() -> [AnyClass] {
        [HttpStubUrlProtocol.self]
    }
    
    func unload() {
        load()
    }
    
    func isEqual(to other: HttpClientHook) -> Bool {
        guard let other = other as? UrlSessionHook else { return false }
        return self == other
    }
    
}
