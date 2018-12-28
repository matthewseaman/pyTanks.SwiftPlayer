//
//  Command+JSON.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/6/17.
//
//

import Foundation
import PlayerSupport


extension Command: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .go:
            try container.encode(Action.go, forKey: .action)
        case .stop:
            try container.encode(Action.stop, forKey: .action)
        case .turn(heading: let heading):
            try container.encode(Action.turn, forKey: .action)
            try container.encode(heading, forKey: .arg)
        case .fire(heading: let heading):
            try container.encode(Action.fire, forKey: .action)
            try container.encode(heading, forKey: .arg)
        case .setInfo(let info):
            try container.encode(Action.setInfo, forKey: .action)
            try container.encode(info, forKey: .arg)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case action, arg
    }
    
    /// Valid actions for JSON command objects
    private enum Action: String, Encodable {
        case go = "Command_Go"
        case stop = "Command_Stop"
        case turn = "Command_Turn"
        case fire = "Command_Fire"
        case setInfo = "Command_Info"
    }
    
    /**
     Converts and returns `self` as JSON.
     
     - returns: `self` as JSON data
     */
    internal func json(readable: Bool = false) -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = readable ? .prettyPrinted : []
        do {
            return try encoder.encode(self)
        } catch {
            assertionFailure("\(error)")
            return Data()
        }
    }
    
}
