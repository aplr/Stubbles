//
//  Http.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation


public enum HttpMethod: String {
    case get, head, post, put, delete, connect, options, trace, patch
}

public typealias HttpHeader = [String: String]

public protocol UrlTemplate {
    
    func matches(url: URL) -> Bool
    
}

public struct UrlExpression {
    let pattern: String
    
    public init(_ pattern: String) {
        self.pattern = pattern
    }
}

extension UrlExpression: UrlTemplate {

    public func matches(url: URL) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            preconditionFailure("Invalid URL regex.")
        }
        let urlString = url.absoluteString
        return regex.numberOfMatches(
            in: urlString,
            range: NSRange(urlString.startIndex..., in: urlString)
        ) > 0
    }
    
}

extension String: UrlTemplate {
    
    public func matches(url: URL) -> Bool {
        guard let other = URL(string: self) else { return false }
        return other.matches(url: url)
    }
    
}

extension URL: UrlTemplate {
    
    public func matches(url: URL) -> Bool {
        url.removingQuery() == self.removingQuery()
    }
    
}

public struct Endpoint {
    let url: UrlTemplate
    let method: HttpMethod
    
    public init(_ url: UrlTemplate, method: HttpMethod = .get) {
        self.url = url
        self.method = method
    }
}

public struct Header {
    let key: String
    let value: String
    
    public init(_ value: String, forKey key: String) {
        self.key = key
        self.value = value
    }
}

public struct Headers {
    let headers: HttpHeader
    
    public init(_ headers: HttpHeader) {
        self.headers = headers
    }
}

public protocol Body {
    var data: Data? { get }
}

public struct EmptyBody: Body {
    public var data: Data? { nil }
    
    public init() {}
}

public struct JsonBody<E: Encodable>: Body {
    let body: E
    
    public var data: Data? {
        try? JSONEncoder().encode(body)
    }
    
    public init(_ body: E) {
        self.body = body
    }
}

public struct DataBody: Body {
    public let data: Data?
    
    public init(_ data: Data?) {
        self.data = data
    }
}

public struct StatusCode {
    let statusCode: Int
    
    public init(_ statusCode: Int) {
        self.statusCode = statusCode
    }
}
