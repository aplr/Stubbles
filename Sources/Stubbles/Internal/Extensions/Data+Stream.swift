//
//  Data+Stream.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

extension Data {
    
    init(reading stream: InputStream) {
        self.init()
        
        stream.open()
        
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: bufferSize)
            if (read == 0) { break }
            self.append(buffer, count: read)
        }
        buffer.deallocate()
        stream.close()
    }
    
}
