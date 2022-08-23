//
//  StubResponse.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

public struct StubResponse {
    public let statusCode: Int?
    public let body: ResponseBody?
    public let headers: HttpHeader?
    public let error: Error?
    
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
    
    public init(_ error: Error) {
        self.init(nil, body: nil, headers: nil, error: error)
    }
}


public protocol ResponseBody: Body {}

extension EmptyBody: ResponseBody {}

extension JsonBody: ResponseBody {}

extension DataBody: ResponseBody {}

