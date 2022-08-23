//
//  Stubbles.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

/// A class that manages stub requests and handles intercepted HTTP requests.
public class Stubbles {
    
    /// An error that occurs while interacting with Stubbles.
    public enum Error: Swift.Error {
        case noMatch(HttpRequest)
        case noStatus
        case invalidResponse
        case noData
    }
    
    /// The shared stubbles instance.
    public static let shared = Stubbles()
    
    /// The list of all registered stub requests.
    private var stubs: [StubRequest] = []
    
    /// Indicates if Stubbles is intercepting requests.
    private(set) var isRunning: Bool = false
    
    /// The list of all registered HTTP client hooks.
    private var hooks: [HttpClientHook] = []
    
    /// Creates a new Stubbles instance.
    private init() {
        registerHook(UrlHook())
        registerHook(UrlSessionHook())
    }
    
    /// Start intercepting requests.
    public func start() {
        guard !isRunning else { return }
        loadHooks()
        isRunning = true
    }
    
    /// Stop intercepting requests, but don't reset stubs.
    public func pause() {
        guard isRunning else { return }
        unloadHooks()
        isRunning = false
    }
    
    /// Stop intercepting requests and reset stubs.
    public func stop() {
        pause()
        reset()
    }
    
    /// Registers a given stub request.
    ///
    /// - Parameter request: The stub request to register.
    public func register(stub request: StubRequest) {
        self.stubs.append(request)
    }
    
    /// Creates a stub request from the given attributes and registers it with Stubbles.
    ///
    /// - Parameter attributes: The request attributes.
    /// - Returns: The stub request.
    @discardableResult public func stub(
        @StubRequest.Builder attributes builder: () -> StubRequest
    ) -> StubRequest {
        let request = builder()
        self.register(stub: request)
        return request
    }
    
    /// Resets all stubs.
    public func reset() {
        stubs.removeAll()
    }
    
    /// Matches the incoming request with every registered stub request until a response is received.
    ///
    /// - Parameter request: The intercepted request.
    /// - Returns: The stub response.
    /// - Throws: ``Error/noMatch(_:)`` if no matching stub request was found.
    func handle(request: HttpRequest) throws -> StubResponse {
        for stubbedRequest in stubs {
            if let stubbedResponse = stubbedRequest.handle(request: request) {
                return stubbedResponse
            }
        }
        
        throw Error.noMatch(request)
    }
    
    /// Registers the given HTTP client hook.
    ///
    /// - Parameter hook: The HTTP client hook.
    private func registerHook(_ hook: HttpClientHook) {
        guard !hooks.contains(where: { $0 == hook }) else { return }
        hooks.append(hook)
    }
    
    /// Load all registered HTTP client hooks.
    private func loadHooks() {
        hooks.forEach { $0.load() }
    }
    
    /// Unload all registered HTTP client hooks.
    private func unloadHooks() {
        hooks.forEach { $0.unload() }
    }
}
