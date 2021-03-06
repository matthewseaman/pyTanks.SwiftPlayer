//
//  ClientConfiguration.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/6/17.
//
//

import Foundation
import PlayerSupport


/**
 Represents the configuration of the game client powering the player.
 
 - note: Some of these settings settings refer to the "local server". This is because a pyTank client is actually its own local server.
 
 While many options are configurable, others are immutable because they must match values on the server.
 */
public struct ClientConfiguration {
    
    /// The pyTank server's IP Address
    public var ipAddress = "localhost"
    
    /// The pyTank server's port number
    public var port: UInt = 9042
    
    /// The formatted IP and port for the local server
    public var ipAndPort: String {
        return "\(ipAddress):\(port)"
    }
    
    /// The log to print messages to
    public var log = Log()
    
    /// The target framerate for processing game states and responding
    public var framesPerSecond = 60
    
    /// The time, in seconds, to wait before logging fps rate. This setting is ignored if fps logging is disabled.
    public var fpsLogRate = 5.0
    
    /// The maximum number of decimal places to show for FPS logs. This setting is ignored if fps logging is disabled.
    public var fpsLogMaximumFractionDigits = 2
    
    /// The API version of the client. This value must match the server API version.
    public let apiVersion = "beta-2"
    
    /// The player API path to connect to the server on
    public var apiPath: String {
        return "/pyTanksAPI/\(apiVersion)/player"
    }
    
    /// The web socket url to connect to
    public var socketUrl: URL {
        return URL(string: "ws://\(ipAndPort)\(apiPath)")!
    }
    
    /// Creates a `ClientConfiguration` with default values
    public init() {}
    
}
