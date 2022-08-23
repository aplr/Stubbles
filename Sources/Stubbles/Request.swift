//
//  Request.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

public typealias ResponseFactory = (StubRequest) -> StubResponse

public struct StubRequest {
    private let url: UrlTemplate?
    private let method: HttpMethod?
    private let headers: HttpHeader?
    private let body: RequestBody?
    
    private let responseFactory: ResponseFactory?
    
    private let storage: Storage
    
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
    
    func handle(request: HttpRequest) -> StubResponse? {
        guard matches(request: request) else { return nil }
        
        storage.calls.append(Call(date: Date(), request: request))

        guard let response = responseFactory?(self) else {
            return StubResponse(200)
        }
        
        return response
    }
    
    public var calls: [Call] {
        storage.calls
    }
    
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
    
    class Storage {
        var calls: [Call] = []
    }
    
    public struct Call {
        public let date: Date
        public let request: HttpRequest
    }
    
}

public protocol RequestBody: Body {
    
    func matches(data: Data?) -> Bool

}

extension EmptyBody: RequestBody {

    public func matches(data: Data?) -> Bool {
        guard let data = data else { return true }
        return data.isEmpty
    }

}

extension JsonBody: RequestBody {
    
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
    
    public func matches(data: Data?) -> Bool {
        guard let matchData = self.data else { return true }
        guard let otherData = data else { return false }
        return matchData == otherData
    }
    
}
