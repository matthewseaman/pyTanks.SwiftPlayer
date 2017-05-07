//
//  Commands.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/6/17.
//
//

#if SWIFT_PACKAGE
    import Foundation
#endif


/// A command that may be sent to the server on behalf of a player. These commands control the player's tank.
public enum Command {
    
    /// Tells the tank to drive in the direction of its current heading. It will keep moving until the `stop` command is used or until a collision occurs.
    case go
    
    /// Tells the tank to stop
    case stop
    
    /// Tells the tank to turn to a new position, specified as radians from the positive x axis.
    case turn(heading: Double)
    
    /// Tells the tank to fire in the direction specified as radians from the positive x axis. The server may restrict shooting in certain situations.
    case fire(heading: Double)
    
}
