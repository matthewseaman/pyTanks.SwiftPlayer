//
//  Commands+JSON.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/6/17.
//
//

#if SWIFT_PACKAGE
import Foundation
#endif


extension Command {
    
    /**
     Converts and returns `self` as JSON.
     
     - returns: `self` as JSON data
     */
    internal func json(readable: Bool = false) -> Data {
        switch self {
        case .go:
            return json(withAction: .go, arg: nil, pretty: readable)
        case .stop:
            return json(withAction: .stop, arg: nil, pretty: readable)
        case .turn(let heading):
            return json(withAction: .turn, arg: heading, pretty: readable)
        case .fire(let heading):
            return json(withAction: .fire, arg: heading, pretty: readable)
        case .setInfo(let info):
            return json(withAction: .setInfo, arg: info, pretty: readable)
        }
    }
    
    /**
     Converts the given command text and floating-point argument to JSON data.
     */
    private func json(withAction action: Action, arg: Any?, pretty: Bool = false) -> Data {
        var dict = [String : Any]()
        dict["\(JSONKey.action)"] = "\(action)"
        if let arg = arg {
            dict["\(JSONKey.arg)"] = arg
        }
        return try! JSONSerialization.data(withJSONObject: dict, options: pretty ? .prettyPrinted : [])
    }
    
    /// Expected keys for JSON commands
    private enum JSONKey: String, CustomStringConvertible {
        case action = "action"
        case arg = "arg"
        
        fileprivate var description: String {
            return rawValue
        }
    }
    
    /// Valid actions for JSON command objects
    private enum Action: String, CustomStringConvertible {
        case go = "Command_Go"
        case stop = "Command_Stop"
        case turn = "Command_Turn"
        case fire = "Command_Fire"
        case setInfo = "Command_Info"
        
        var description: String {
            return rawValue
        }
    }
    
}
