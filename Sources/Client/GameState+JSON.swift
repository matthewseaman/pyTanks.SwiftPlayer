//
//  GrameState+Serialization.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/6/17.
//
//

import Foundation
import PlayerSupport


extension GameState {
    
    /**
     Creates a new `GameState` with the given game state JSON package
     
     If `log` is non-nil, this init logs errors to it.
     
     - note: This function performs all work on the calling thread and performs no synchronization
     
     - parameter json: The json game state
     - parameter log: A log to write errors to
     
     - throws: `JSONError` if the data is invalid JSON or does not contain a top-level dictionary
     */
    internal init(json: Data, loggingTo log: Log? = nil) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(GameState.self, from: json)
    }
    
}
