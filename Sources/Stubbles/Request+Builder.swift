//
//  Request+Builder.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

public protocol RequestBuilderBlock {
    
    func add(to builder: inout StubRequest.Builder)
    
}

extension UrlTemplate where Self: RequestBuilderBlock {
    
    func add(to builder: inout StubRequest.Builder) {
        builder.url = self
    }

}

extension Endpoint: RequestBuilderBlock {

    public func add(to builder: inout StubRequest.Builder) {
        builder.url = url
        builder.method = method
    }
    
}

extension Header: RequestBuilderBlock {
    
    public func add(to builder: inout StubRequest.Builder) {
        builder.headers[key] = value
    }
    
}

extension Headers: RequestBuilderBlock {
    
    public func add(to builder: inout StubRequest.Builder) {
        builder.headers += headers
    }
    
}

extension EmptyBody: RequestBuilderBlock {}

extension JsonBody: RequestBuilderBlock {
    
    public func add(to builder: inout StubRequest.Builder) {
        builder.body = self
        builder.headers["Content-Type"] = "application/json"
    }
    
}

extension DataBody: RequestBuilderBlock {}

extension RequestBody where Self: RequestBuilderBlock {
    
    public func add(to builder: inout StubRequest.Builder) {
        builder.body = self
    }

}

public struct Serve {
    let factory: ResponseFactory

    public init(@Serve.Builder _ factory: @escaping (StubRequest) -> StubResponse) {
        self.factory = factory
    }
    
    @resultBuilder
    public struct Builder {
        
        public static func buildBlock(_ component: StubResponse) -> StubResponse {
            component
        }
        
        public static func buildEither(first component: StubResponse) -> StubResponse {
            component
        }
        
        public static func buildEither(second component: StubResponse) -> StubResponse {
            component
        }
        
    }
}

extension Serve: RequestBuilderBlock {
    
    public func add(to builder: inout StubRequest.Builder) {
        builder.responseFactory = factory
    }
    
}

extension StubResponse: RequestBuilderBlock {
    
    public func add(to builder: inout StubRequest.Builder) {
        builder.responseFactory = { _ in self }
    }
    
}

extension StubRequest {
    
    public init(@StubRequest.Builder _ builder: () -> StubRequest) {
        self = builder()
    }
    
    @resultBuilder
    public struct Builder {
        var url: UrlTemplate? = nil
        var method: HttpMethod? = nil
        var headers = HttpHeader()
        var body: RequestBody? = nil
        var responseFactory: ResponseFactory? = nil
        
        var request: StubRequest {
            StubRequest(
                url: url,
                method: method,
                headers: headers.isEmpty ? nil : headers,
                body: body,
                responseFactory: responseFactory
            )
        }
        
        public static func buildFinalResult(_ components: [RequestBuilderBlock]) -> StubRequest {
            var builder = Builder()
            
            for block in components {
                block.add(to: &builder)
            }
            
            return builder.request
        }
        
        public static func buildBlock(_ components: RequestBuilderBlock...) -> [RequestBuilderBlock] {
            components
        }
        
        public static func buildEither(first component: [RequestBuilderBlock]) -> [RequestBuilderBlock] {
            component
        }
        
        public static func buildEither(second component: [RequestBuilderBlock]) -> [RequestBuilderBlock] {
            component
        }
        
    }
    
}
