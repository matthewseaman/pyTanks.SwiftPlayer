//
//  ClientConfiguration.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/6/17.
//
//


/**
 Represents the configuration of the game client powering the player.
 
 - note: Some of these settings settings refer to the "local server". This is because a pyTank client is actually its own local server.
 
 While many options are configurable, others are immutable because they must match values on the server.
 */
public struct ClientConfiguration {
    
    /// The local server's IP Address
    public var ipAddress = "localhost"
    
    /// The local server's port number
    public var port: UInt = 9042
    
    /// The formatted IP and port for the local server
    public var ipAndPort: String {
        return "\(ipAddress):\(port)"
    }
    
    /// Determines the amount of logging that the client performs. See `Log.swift`.
    public var logLevel = 3
    
    /// The target framerate for issuing commands
    public var framesPerSecond = 60
    
    /// The time, in seconds, to wait before logging fps rate. This value is only used if FPS rate is being logged, as specified by `logLevel`. See `Log.swift`.
    public var fpsLogRate = 5.0
    
    /// The API version of the client. This value must match the server API version.
    public let apiVersion = "beta-0"
    
    /// The player API path to connect to the server on
    public var apiPath: String {
        return "/pyTanksAPI/\(apiVersion)/player"
    }
    
}
