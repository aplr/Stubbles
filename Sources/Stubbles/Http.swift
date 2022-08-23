//
//  Http.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation


/// The HTTP method of a stub request.
public enum HttpMethod: String {
    case get, head, post, put, delete, connect, options, trace, patch
}

/// The HTTP headers for both a stub request and stub response.
public typealias HttpHeader = [String: String]


/// A type that represents a URL template which can be matched with a given URL.
public protocol UrlTemplate {
    
    /// Matches the url template with the given URL.
    ///
    /// - Parameter url: The URL to match with the template.
    /// - Returns: `true` if the given URL matches the template, `false` otherwise.
    func matches(url: URL) -> Bool
    
}

extension NSRegularExpression: UrlTemplate {
    
    /// Matches the regular expression with the given URL.
    ///
    /// - Parameter url: The URL to match with the regex.
    /// - Returns: `true` if the given URL matches the regex, `false` otherwise.
    public func matches(url: URL) -> Bool {
        let urlString = url.absoluteString
        return numberOfMatches(
            in: urlString,
            range: NSRange(urlString.startIndex..., in: urlString)
        ) > 0
    }
    
}

extension String: UrlTemplate {
    
    /// Matches the string to the given URL.
    ///
    /// - Parameter url: The URL to match with the string.
    /// - Returns: `true` if the given URL is equal to the string, `false` otherwise.
    public func matches(url: URL) -> Bool {
        guard let other = URL(string: self) else { return false }
        return other.matches(url: url)
    }
    
}

extension URL: UrlTemplate {
    
    /// Matches the current URL to the given URL.
    ///
    /// - Parameter url: The URL to match with the URL.
    /// - Returns: `true` if the given URL is equal to the current URL, `false` otherwise.
    public func matches(url: URL) -> Bool {
        url.removingQuery() == self.removingQuery()
    }
    
}

/// A request attribute that is used to define a URL template and a request method.
public struct Endpoint {
    
    /// The endpoint's url template.
    let url: UrlTemplate
    
    /// The endpoint's request method.
    let method: HttpMethod
    
    /// Creates an endpoint.
    ///
    /// - Parameters:
    ///   - url: The url template.
    ///   - method: The request method.
    public init(_ url: UrlTemplate, method: HttpMethod = .get) {
        self.url = url
        self.method = method
    }
}

/// An attribute that is used to define a single header for stub request and stub response.
public struct Header {
    /// The header key.
    let key: String
    
    /// The header value.
    let value: String
    
    /// Creates a header entry.
    ///
    /// - Parameters:
    ///   - value: The header value.
    ///   - key: The header key.
    public init(_ value: String, forKey key: String) {
        self.key = key
        self.value = value
    }
}

/// An attribute that is used to define headers for stub request and stub response.
public struct Headers {
    /// The underlying headers
    let headers: HttpHeader
    
    /// Creates a headers struct.
    ///
    /// - Parameter headers: The request headers.
    public init(_ headers: HttpHeader) {
        self.headers = headers
    }
}

/// A type that represents the body of either a stub request or a stub response.
public protocol Body {
    
    /// The underlying raw data of the body.
    var data: Data? { get }
}

/// An attribute that is used to define an empty body with no data.
public struct EmptyBody: Body {
    public var data: Data? { nil }
    
    /// Creates an empty body.
    public init() {}
}

/// An attribute that is used to define a json-encoded body given a value conforming to `Encodable`.
public struct JsonBody<E: Encodable>: Body {
    /// The encodable object.
    let body: E
    
    /// The encoded data.
    public var data: Data? {
        try? JSONEncoder().encode(body)
    }
    
    /// Create a json body from the given encodable value.
    ///
    /// - Parameter body: The encodable value.
    public init(_ body: E) {
        self.body = body
    }
}

/// An attribute that is used to define a body with raw `Data`.
public struct DataBody: Body {
    
    /// The underlying raw data of the body.
    public let data: Data?
    
    /// Create a data body with the given data.
    ///
    /// - Parameter data: The data.
    public init(_ data: Data?) {
        self.data = data
    }
}

/// A request attribute that is used to define a HTTP status code.
public struct StatusCode {
    
    /// The HTTP status code.
    let statusCode: Int
    
    /// Create a status code.
    ///
    /// - Parameter statusCode: The status code.
    public init(_ statusCode: Int) {
        self.statusCode = statusCode
    }
}
