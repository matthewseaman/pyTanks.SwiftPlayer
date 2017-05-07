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
    /// The JSON did not contain a top-level dictionary
    case noTopLevelDict
    /// The value at `keyPath` was missing
    case missing(keyPath: String)
    /// The `value` at `keyPath` was invlalid
    case invalid(keyPath: String, value: Any)
    
    var description: String {
        switch self {
        case .notValidJSON:
            return "The received JSON could not be parsed."
        case .noTopLevelDict:
            return "The received JSON was in an invalid format."
        case .missing(let keyPath):
            return "The received JSON is missing \"\(keyPath)\"."
        case .invalid(let keyPath, let value):
            return "The received JSON contained \(value), an invlalid value for \(keyPath)."
        }
    }
}
