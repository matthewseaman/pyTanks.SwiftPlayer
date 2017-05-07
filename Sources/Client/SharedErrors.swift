//
//  SharedErrors.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/6/17.
//
//


/// A JSON Serialization Error
internal enum JSONError: Error {
    /// The JSON data was not valid JSON and could not be parsed
    case notValidJSON
    /// The JSON data was parsed but it did not match the expected format for this object
    case invalidFormatForObject
}
