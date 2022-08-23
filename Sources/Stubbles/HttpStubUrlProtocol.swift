//
//  HttpStubUrlProtocol.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

final class HttpStubUrlProtocol: URLProtocol {
    
    private var urlSessionTask: URLSessionTask?
    
    override var task: URLSessionTask? {
        urlSessionTask
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard let scheme = request.url?.scheme else { return false }
        return ["http", "https"].contains(scheme)
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        false
    }
    
    init(task: URLSessionTask, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: task.currentRequest!, cachedResponse: cachedResponse, client: client)
        self.urlSessionTask = task
    }
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }
    
    override func startLoading() {
        var request = request
        
        var cookieStorage = HTTPCookieStorage.shared
        
        if let session = task?.value(forKey: "session") as? URLSession,
           let configurationCookieStorage = session.configuration.httpCookieStorage {
            cookieStorage = configurationCookieStorage
        }
        
        if let url = request.url, let cookies = cookieStorage.cookies(for: url) {
            request.allHTTPHeaderFields = (request.allHTTPHeaderFields ?? [String: String]()).merging(HTTPCookie.requestHeaderFields(with: cookies)) { (key, _) in key }
        }
        
        guard let stubbedResponse = try? Stubbles.shared.handle(request: request),
              let url = request.url else {
            client?.urlProtocol(self, didFailWithError: Stubbles.Error.noMatch(request))
            return
        }
        
        cookieStorage.setCookies(
            HTTPCookie.cookies(withResponseHeaderFields: stubbedResponse.headers ?? [:], for: url),
            for: url,
            mainDocumentURL: url
        )
        
        if let error = stubbedResponse.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        guard let statusCode = stubbedResponse.statusCode else {
            client?.urlProtocol(self, didFailWithError: Stubbles.Error.noStatus)
            return
        }

        guard let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: stubbedResponse.headers
        ) else {
            client?.urlProtocol(self, didFailWithError: Stubbles.Error.invalidResponse)
            return
        }
        
        if 300...399 ~= statusCode && ![304, 305].contains(statusCode) {
            guard let location = stubbedResponse.headers?["Location"],
                  let url = URL(string: location),
                  let cookies = cookieStorage.cookies(for: url) else {
              return
            }
            var redirect = URLRequest(url: url)
            redirect.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
            client?.urlProtocol(self, wasRedirectedTo: redirect, redirectResponse: response)
        }

        guard let data = stubbedResponse.body?.data else {
            client?.urlProtocol(self, didFailWithError: Stubbles.Error.noData)
            return
        }
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        // Intentionally left blank.
    }
    
}
