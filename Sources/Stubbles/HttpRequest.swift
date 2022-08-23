//
//  HttpRequest.swift
//  Stubble
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

public protocol HttpRequest {
    var url: URL? { get }
    var method: HttpMethod? { get }
    var headers: HttpHeader? { get }
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
