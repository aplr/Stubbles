//
//  URL+RemovingQuery.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

extension URL {
    
    func removingQuery() -> URL {
        guard var components = URLComponents(string: absoluteString) else { return self }
        components.query = nil
        return components.url ?? self
    }
    
}
