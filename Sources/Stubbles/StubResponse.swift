//
//  StubResponse.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

/// A struct that is used to define a stub response. It provides declarative initialization with a fluent DSL.
public struct StubResponse {
    
    /// The response’s HTTP status code.
    public let statusCode: Int?
    
    /// The data sent as the message body of a response or over a stream.
    public let body: ResponseBody?
    
    /// All HTTP header fields of the response.
    public let headers: HttpHeader?
    
    /// The underlying error of the response.
    public let error: Error?
    
    /// Creates a stub response.
    ///
    /// - Parameters:
    ///   - statusCode: The response’s HTTP status code.
    ///   - body: The data sent as the message body of a response or over a stream.
    ///   - headers: All HTTP header fields of the response.
    ///   - error: The underlying error of the response.
    public init(
        _ statusCode: Int? = 200,
        body: ResponseBody? = nil,
        headers: HttpHeader? = nil,
        error: Error? = nil
    ) {
        self.statusCode = statusCode
        self.body = body
        self.headers = headers
        self.error = error
    }
    
    /// Creates a error stub response.
    ///
    /// - Parameter error: The underlying error of the response.
    public init(_ error: Error) {
        self.init(nil, body: nil, headers: nil, error: error)
    }
}


/// A type that represents the body a stub response.
public protocol ResponseBody: Body {}

extension EmptyBody: ResponseBody {}

extension JsonBody: ResponseBody {}

extension DataBody: ResponseBody {}

