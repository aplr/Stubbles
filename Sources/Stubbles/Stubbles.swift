//
//  Stubbles.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

public class Stubbles {
    
    public enum Error: Swift.Error {
        case noMatch(HttpRequest)
        case noStatus
        case invalidResponse
        case noData
    }
    
    public static let shared = Stubbles()
    
    private var stubs: [StubRequest] = []
    private var isRunning: Bool = false
    
    private var hooks: [HttpClientHook] = []
    
    private init() {
        registerHook(UrlHook())
        registerHook(UrlSessionHook())
    }
    
    public func start() {
        guard !isRunning else { return }
        loadHooks()
        isRunning = true
    }
    
    public func pause() {
        guard isRunning else { return }
        unloadHooks()
        isRunning = false
    }
    
    public func stop() {
        pause()
        reset()
    }
    
    public func add(stub request: StubRequest) {
        self.stubs.append(request)
    }
    
    @discardableResult
    public func stub(@StubRequest.Builder _ builder: () -> StubRequest) -> StubRequest {
        let request = builder()
        self.add(stub: request)
        return request
    }
    
    public func reset() {
        stubs.removeAll()
    }
    
    func handle(request: HttpRequest) throws -> StubResponse {
        for stubbedRequest in stubs {
            if let stubbedResponse = stubbedRequest.handle(request: request) {
                return stubbedResponse
            }
        }
        
        throw Error.noMatch(request)
    }
    
    private func registerHook(_ hook: HttpClientHook) {
        guard !hooks.contains(where: { $0 == hook }) else { return }
        hooks.append(hook)
    }
    
    private func loadHooks() {
        hooks.forEach { $0.load() }
    }
    
    private func unloadHooks() {
        hooks.forEach { $0.unload() }
    }
}
