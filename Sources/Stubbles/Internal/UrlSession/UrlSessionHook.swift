//
//  UrlSessionHook.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

final class UrlSessionHook: HttpClientHook {
    
    private var originalClass: AnyClass? {
        NSClassFromString("__NSCFURLSessionConfiguration") ?? NSClassFromString("NSURLSessionConfiguration")
    }
    
    private var originalSelector: Selector {
        #selector(getter: URLSessionConfiguration.protocolClasses)
    }
    
    @objc private func protocolClasses() -> [AnyClass] {
        [UrlProtocolStub.self]
    }
    
    func load() {
        guard let originalMethod = class_getInstanceMethod(originalClass, originalSelector),
              let stubMethod = class_getInstanceMethod(UrlSessionHook.self, #selector(protocolClasses)) else {
            fatalError("Could not load UrlSessionHook")
        }
        method_exchangeImplementations(originalMethod, stubMethod)
    }
    
    func unload() {
        load()
    }
    
    func isEqual(to other: HttpClientHook) -> Bool {
        guard let other = other as? UrlSessionHook else { return false }
        return self == other
    }
    
}
