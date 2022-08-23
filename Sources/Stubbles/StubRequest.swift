//
//  StubRequest.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

/// A type that represents a closure that returns a stub response for a given stub request.
public typealias ResponseFactory = (StubRequest) -> StubResponse

/// A struct that is used to define a stub request. It provides declarative initialization with a fluent DSL.
public struct StubRequest {
    
    /// The URL template of the request.
    let url: UrlTemplate?
    
    /// The HTTP request method.
    let method: HttpMethod?
    
    /// A dictionary containing all of the HTTP header fields for a request.
    let headers: HttpHeader?
    
    /// The data sent as the message body of a request or over a stream.
    let body: RequestBody?
    
    /// A closure that creates a stub response from the current request.
    let responseFactory: ResponseFactory?
    
    /// A reference to the internal call storage.
    private let storage: Storage
    
    /// Creates a stub request.
    ///
    /// - Parameters:
    ///   - url: The URL template of the request.
    ///   - method: The HTTP request method.
    ///   - headers: A dictionary containing all of the HTTP header fields for a request.
    ///   - body: The data sent as the message body of a request or over a stream.
    ///   - responseFactory: A closure that creates a stub response from the current request.
    public init(
        url: UrlTemplate? = nil,
        method: HttpMethod? = nil,
        headers: HttpHeader? = nil,
        body: RequestBody? = nil,
        responseFactory: ResponseFactory? = nil
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.responseFactory = responseFactory
        self.storage = Storage()
    }
    
    /// Creates a stub request.
    ///
    /// - Parameters:
    ///   - url: The URL template of the request.
    ///   - method: The HTTP request method.
    ///   - headers: A dictionary containing all of the HTTP header fields for a request.
    ///   - body: The data sent as the message body of a request or over a stream.
    ///   - response: The stub response of the request.
    public init(
        url: UrlTemplate,
        method: HttpMethod? = nil,
        headers: HttpHeader? = nil,
        body: RequestBody? = nil,
        response: StubResponse? = nil
    ) {
        self.init(
            url: url,
            method: method,
            headers: headers,
            body: body,
            responseFactory: response.map({ response in { _ in response } })
        )
    }
    
    /// Matches the given request with all attributes of the stub. If the request matches,
    /// a new `Call` is create from the given request, and the response factory is used
    /// to build a response. If no response factory is given, a empty stub response with
    /// status `200 OK` is returned.
    ///
    /// - Parameter request: The intercepted HTTP request.
    /// - Returns: A stub response if the request was matched, `nil` otherwise.
    func handle(request: HttpRequest) -> StubResponse? {
        guard matches(request: request) else { return nil }
        
        storage.calls.append(Call(date: Date(), request: request))

        guard let response = responseFactory?(self) else {
            return StubResponse(200)
        }
        
        return response
    }
    
    /// A list containing all matched calls to the stub request.
    public var calls: [Call] {
        storage.calls
    }
    
    /// Matches the given request with all stub request attributes.
    ///
    /// - Parameter request: The HTTP request.
    /// - Returns: `true` if all attributes match, `false` otherwise.
    private func matches(request: HttpRequest) -> Bool {
        [
            matchesMethod(request.method),
            matchesUrl(request.url),
            matchesHeaders(request.headers),
            matchesBody(request.body)
        ].allSatisfy()
    }
    
    private func matchesMethod(_ other: HttpMethod?) -> Bool {
        // If no method to match is specified, it's considered "don't care"
        guard let method = method else { return true }
        // If the request has no method, it's no match
        guard let other = other else { return false }
        // If both request method and match method are set, compare
        return method == other
    }
    
    private func matchesUrl(_ other: URL?) -> Bool {
        // If no url to match is specified, it's considered "don't care"
        guard let url = url else { return true }
        // If the request has no url, it's no match
        guard let other = other else { return false }
        // If both request url and match url are set, compare
        return url.matches(url: other)
    }
    
    private func matchesHeaders(_ other: HttpHeader?) -> Bool {
        // If no headers to match are specified, it's considered "don't care"
        guard let headers = headers?.mapKeys({ $0.lowercased() }) else { return true }
        // If the request has no headers, it's no match
        guard let other = other?.mapKeys({ $0.lowercased() }) else { return false }
        // If both request header and match header are set, compare
        return headers.keys.allSatisfy({ headers[$0] == other[$0] })
    }
    
    private func matchesBody(_ other: Data?) -> Bool {
        // If no body to match is specified, it's considered "don't care"
        guard let body = body else { return true }
        // Forward to the matcher
        return body.matches(data: other)
    }
}

extension StubRequest {
    
    /// A struct that represents a single call to a stub request.
    public struct Call {
        /// A timestamp when the call happened.
        public let date: Date
        
        /// The underlying request that was matched.
        public let request: HttpRequest
    }
    
}

extension StubRequest {
    
    class Storage {
        var calls: [Call] = []
    }
    
}

/// A type that represents the body a stub request.
public protocol RequestBody: Body {
    
    /// Matches the given data with the body of the stub request.
    ///
    /// - Parameter data: The data to match with the body.
    /// - Returns: `true` if the data matches the stub request body, `false` otherwise.
    func matches(data: Data?) -> Bool

}

extension EmptyBody: RequestBody {
    
    /// Matches the given data with an empty body.
    ///
    /// - Parameter data: The data to match with the body.
    /// - Returns: `true` if data is `nil` or `Data.isEmpty` is `true`, `false` otherwise.
    public func matches(data: Data?) -> Bool {
        guard let data = data else { return true }
        return data.isEmpty
    }

}

extension JsonBody: RequestBody {
    
    /// Matches the given data with the json body.
    ///
    /// - Parameter data: The data to match with the body.
    /// - Returns: `true` if the data matches the encoded json, `false` otherwise.
    public func matches(data: Data?) -> Bool {
        do {
            // If we don't have data to compare to, let's don't match
            guard let otherData = data else { return false }
            // If we don't have data to match, let's don't match
            guard let data = self.data else { return false }
            // Create dict from incoming data
            let otherDict = try JSONSerialization.jsonObject(with: otherData)
            // Create dict from match data
            let dict = try JSONSerialization.jsonObject(with: data)
            // Compare both dicts
            return Json(dict) == Json(otherDict)
        } catch {
            return false
        }
    }
    
}

extension DataBody: RequestBody {
    
    /// Matches the given data with the data body.
    ///
    /// - Parameter data: The data to match with the body.
    /// - Returns: `true` if the given data matches the stub request body, `false` otherwise.
    public func matches(data: Data?) -> Bool {
        guard let matchData = self.data else { return true }
        guard let otherData = data else { return false }
        return matchData == otherData
    }
    
}
