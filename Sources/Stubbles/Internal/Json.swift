//
//  Json.swift
//  Stubbles
//
//  Created by Andreas Pfurtscheller on 22.08.22.
//

import Foundation

enum Json: Equatable {
    case array([Json])
    case object([String: Json])
    case string(String)
    case number(NSNumber)
    case bool(Bool)
    case null
    
    init(_ json: Any) {
        switch json {
        case let value as [Any]:
            self = .array(value.map(Json.init))
        case let value as [String: Any]:
            self = .object(value.mapValues(Json.init))
        case let value as String:
            self = .string(value)
        case let value as NSNumber:
            self = value.isBool ? .bool(value.boolValue) : .number(value)
        default:
            self = .null
        }
    }
    
    static func == (lhs: Json, rhs: Json) -> Bool {
        switch (lhs, rhs) {
        case let (.array(l), .array(r)): return l == r
        case let (.object(l), .object(r)): return l == r
        case let (.string(l), .string(r)): return l == r
        case let (.number(l), .number(r)): return l == r
        case let (.bool(l), .bool(r)): return l == r
        case (.null, .null): return true
        default: return false
        }
    }
}
