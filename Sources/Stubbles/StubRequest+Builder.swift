//
//  StubRequest+Builder.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

/// A type that represents request attributes.
public protocol RequestAttribute {
    
    /// Adds the attribute to the given request builder.
    ///
    /// - Parameter builder: The request builder.
    func add(to builder: inout StubRequest.Builder)
    
}

extension UrlTemplate where Self: RequestAttribute {
    
    /// Adds the url template to the given request builder.
    ///
    /// - Parameter builder: The request builder.
    func add(to builder: inout StubRequest.Builder) {
        builder.url = self
    }

}

extension Endpoint: RequestAttribute {
    
    /// Adds the endpoint's parameters to the given request builder.
    ///
    /// - Parameter builder: The request builder.
    public func add(to builder: inout StubRequest.Builder) {
        builder.url = url
        builder.method = method
    }
    
}

extension Header: RequestAttribute {
    
    /// Adds the header to the given request builder.
    ///
    /// - Parameter builder: The request builder.
    public func add(to builder: inout StubRequest.Builder) {
        builder.headers[key] = value
    }
    
}

extension Headers: RequestAttribute {
    
    /// Adds the headers to the given request builder.
    ///
    /// - Parameter builder: The request builder.
    public func add(to builder: inout StubRequest.Builder) {
        builder.headers += headers
    }
    
}

extension JsonBody: RequestAttribute {
    
    /// Adds the json body to the given request builder and set the
    /// `Content-Type` header to `application/json`.
    ///
    /// - Parameter builder: The request builder.
    public func add(to builder: inout StubRequest.Builder) {
        builder.body = self
        builder.headers["Content-Type"] = "application/json"
    }
    
}

extension EmptyBody: RequestAttribute {}

extension DataBody: RequestAttribute {}

extension RequestBody where Self: RequestAttribute {
    
    /// Adds the request body to the given request builder.
    ///
    /// - Parameter builder: The request builder.
    public func add(to builder: inout StubRequest.Builder) {
        builder.body = self
    }

}

/// A request attribute that is used to define dynamic ``StubResponse``s from incoming requests.
public struct Serve {
    /// The response factory used to create responses from incoming requests.
    let factory: ResponseFactory

    public init(@Serve.Builder _ factory: @escaping ResponseFactory) {
        self.factory = factory
    }
    
    /// A custom parameter attribute that constructs the serve attribute from closures.
    @resultBuilder public struct Builder {
        
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

extension Serve: RequestAttribute {
    
    /// Adds the response factory to the given request builder.
    ///
    /// - Parameter builder: The request builder.
    public func add(to builder: inout StubRequest.Builder) {
        builder.responseFactory = factory
    }
    
}

extension StubResponse: RequestAttribute {
    
    /// Adds a static response factory to the given reqeust builder.
    ///
    /// - Parameter builder: The request builder.
    public func add(to builder: inout StubRequest.Builder) {
        builder.responseFactory = { _ in self }
    }
    
}

extension StubRequest {
    
    /// Creates a stub request.
    ///
    /// - Parameter attributes: A stub request builder that defines the request attributes.
    public init(@StubRequest.Builder attributes builder: () -> StubRequest) {
        self = builder()
    }
    
    /// A custom parameter attribute that constructs stub requests from closures.
    @resultBuilder public struct Builder {
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
        
        public static func buildFinalResult(_ components: [RequestAttribute]) -> StubRequest {
            var builder = Builder()
            
            for block in components {
                block.add(to: &builder)
            }
            
            return builder.request
        }
        
        public static func buildBlock(_ components: RequestAttribute...) -> [RequestAttribute] {
            components
        }
        
        public static func buildEither(first component: [RequestAttribute]) -> [RequestAttribute] {
            component
        }
        
        public static func buildEither(second component: [RequestAttribute]) -> [RequestAttribute] {
            component
        }
        
    }
    
}
