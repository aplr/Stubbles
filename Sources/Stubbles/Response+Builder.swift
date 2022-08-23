//
//  Response+Builder.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

public protocol ResponseBuilderBlock {
    
    func add(to builder: inout StubResponse.Builder)
    
}

public struct Fail {
    let error: Error
    
    init(with error: Error) {
        self.error = error
    }
}

extension Fail: ResponseBuilderBlock {
    
    public func add(to builder: inout StubResponse.Builder) {
        builder.error = error
    }
    
}

extension StatusCode: ResponseBuilderBlock {
    
    public func add(to builder: inout StubResponse.Builder) {
        builder.statusCode = statusCode
    }
    
}

extension Header: ResponseBuilderBlock {
    
    public func add(to builder: inout StubResponse.Builder) {
        builder.headers[key] = value
    }
    
}

extension Headers: ResponseBuilderBlock {
    
    public func add(to builder: inout StubResponse.Builder) {
        builder.headers += headers
    }
    
}

extension EmptyBody: ResponseBuilderBlock {}

extension JsonBody: ResponseBuilderBlock {
    
    public func add(to builder: inout StubResponse.Builder) {
        builder.body = self
        builder.headers["Content-Type"] = "application/json"
    }
    
}

extension DataBody: ResponseBuilderBlock {}

extension ResponseBody where Self: ResponseBuilderBlock {
    
    public func add(to builder: inout StubResponse.Builder) {
        builder.body = self
    }

}

extension StubResponse {
    
    public init(@StubResponse.Builder _ builder: () -> StubResponse) {
        self = builder()
    }
    
    @resultBuilder
    public struct Builder {
        var statusCode: Int = 200
        var body: ResponseBody? = nil
        var headers = HttpHeader()
        var error: Error? = nil
        
        var response: StubResponse {
            StubResponse(
                statusCode,
                body: body,
                headers: headers.isEmpty ? nil : headers,
                error: error
            )
        }
        
        public static func buildFinalResult(_ components: [ResponseBuilderBlock]) -> StubResponse {
            var builder = Builder()
            
            for block in components {
                block.add(to: &builder)
            }
            
            return builder.response
        }
        
        public static func buildBlock(_ components: ResponseBuilderBlock...) -> [ResponseBuilderBlock] {
            components
        }
        
        public static func buildEither(first component: [ResponseBuilderBlock]) -> [ResponseBuilderBlock] {
            component
        }
        
        public static func buildEither(second component: [ResponseBuilderBlock]) -> [ResponseBuilderBlock] {
            component
        }
    }
    
}
