//
//  StubResponse+Builder.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

/// A type that represents response attributes.
public protocol ResponseAttribute {
    
    /// Adds the attribute to the given response builder.
    ///
    /// - Parameter builder: The response builder.
    func add(to builder: inout StubResponse.Builder)
    
}

/// A response attribute that is used to define a failing response.
/// If defined, other attributes will be ignored and the response will fail.
public struct Fail {
    
    /// The underlying error causing the response to fail.
    let error: Error
    
    /// Creates the fail attribute.
    ///
    /// - Parameter error: The underlying error.
    init(with error: Error) {
        self.error = error
    }
}

extension Fail: ResponseAttribute {
    
    /// Adds the error to the given response builder.
    ///
    /// - Parameter builder: The response builder.
    public func add(to builder: inout StubResponse.Builder) {
        builder.error = error
    }
    
}

extension StatusCode: ResponseAttribute {
    
    /// Adds the status code to the given response builder.
    ///
    /// - Parameter builder: The response builder.
    public func add(to builder: inout StubResponse.Builder) {
        builder.statusCode = statusCode
    }
    
}

extension Header: ResponseAttribute {
    
    /// Adds the header to the given response builder.
    ///
    /// - Parameter builder: The response builder.
    public func add(to builder: inout StubResponse.Builder) {
        builder.headers[key] = value
    }
    
}

extension Headers: ResponseAttribute {
    
    /// Adds the headers to the given response builder.
    ///
    /// - Parameter builder: The response builder.
    public func add(to builder: inout StubResponse.Builder) {
        builder.headers += headers
    }
    
}

extension JsonBody: ResponseAttribute {
    
    /// Adds the json body to the given response builder and set the
    /// `Content-Type` header to `application/json`.
    ///
    /// - Parameter builder: The response builder.
    public func add(to builder: inout StubResponse.Builder) {
        builder.body = self
        builder.headers["Content-Type"] = "application/json"
    }
    
}

extension EmptyBody: ResponseAttribute {}

extension DataBody: ResponseAttribute {}

extension ResponseBody where Self: ResponseAttribute {
    
    /// Adds the response body to the given response builder.
    ///
    /// - Parameter builder: The response builder.
    public func add(to builder: inout StubResponse.Builder) {
        builder.body = self
    }

}

extension StubResponse {
    
    /// Creates a stub response.
    ///
    /// - Parameter attributes: A stub response builder that defines the response attributes.
    public init(@StubResponse.Builder attributes builder: () -> StubResponse) {
        self = builder()
    }
    
    /// A custom parameter attribute that constructs stub responses from closures.
    @resultBuilder public struct Builder {
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
        
        public static func buildFinalResult(_ components: [ResponseAttribute]) -> StubResponse {
            var builder = Builder()
            
            for block in components {
                block.add(to: &builder)
            }
            
            return builder.response
        }
        
        public static func buildBlock(_ components: ResponseAttribute...) -> [ResponseAttribute] {
            components
        }
        
        public static func buildEither(first component: [ResponseAttribute]) -> [ResponseAttribute] {
            component
        }
        
        public static func buildEither(second component: [ResponseAttribute]) -> [ResponseAttribute] {
            component
        }
    }
    
}
