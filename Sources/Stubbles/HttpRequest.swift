//
//  HttpRequest.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

/// A type that represents a HTTP request.
public protocol HttpRequest {
    /// The URL of the request.
    var url: URL? { get }
    
    /// The HTTP request method.
    var method: HttpMethod? { get }
    
    /// A dictionary containing all of the HTTP header fields for a request.
    var headers: HttpHeader? { get }
    
    /// The data sent as the message body of a request or over a stream.
    var body: Data? { get }
}

extension URLRequest: HttpRequest {
    
    public var method: HttpMethod? {
        guard let method = httpMethod else { return nil }
        return HttpMethod(rawValue: method.lowercased())
    }
    
    public var headers: HttpHeader? {
        allHTTPHeaderFields
    }
    
    public var body: Data? {
        guard let stream = httpBodyStream else { return httpBody }
        
        return Data(reading: stream)
    }
    
}
