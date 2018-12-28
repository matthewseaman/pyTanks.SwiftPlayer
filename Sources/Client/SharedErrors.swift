//
//  SharedErrors.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/6/17.
//
//


/// A JSON Serialization Error
internal enum JSONError: Error, CustomStringConvertible {
    /// The JSON data was not valid JSON and could not be parsed
    case notValidJSON
    /// The value at `keyPath` was missing
    case missing(keyPath: [String])
    /// The `value` at `keyPath` was invlalid
    case invalid(keyPath: [String]?)
    
    var description: String {
        switch self {
        case .notValidJSON:
            return "The received JSON was invalid."
        case .missing(let keyPath):
            return "The received JSON is missing \"\(keyPath.joined(separator: " -> "))\"."
        case .invalid(let keyPath):
            var message = "The received JSON contained an invalid value"
            if let path = keyPath {
                message += "for \"\(path.joined(separator: " -> "))\"."
            }
            message += "."
            return message
        }
    }
}
