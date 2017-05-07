//
//  Configuration.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/6/17.
//
//


/**
 Represents the configuration of a game field from the player's perspective,
 including the map, tank, and and shell properties.
 
 At this time, all settings are immutable because they must match specific values on the server. Use an instance of this object to refer to the default values.
 */
public struct GameConfiguration {
    
    /// A configuration for the map
    public let map = MapConfig()
    
    /// A configuration for the tank
    public let tank = TankConfig()
    
    /// A configuration for the shells
    public let shell = ShellConfig()
    
    /// Creates a `GameConfiguration` with required values.
    public init() {}
    
    /**
     Represents a configuration for a game map. These values match with the server and are therefore immutable.
     
     The origin is the upper left corner with positive x going to the right and positive y going down.
     */
    public struct MapConfig {
        
        /// The width of the game map, in pixels
        public let width = 500
        
        /// The height of the game map, in pixels
        public let height = 500
        
    }
    
    /**
     Represents a configuration for your tank. These values match with the server and are therefore immutable.
     */
    public struct TankConfig {
        
        /// The natural speed of the tank, in pixels per second
        public let speed = 30
        
        /// The width of the tank, in pixels
        public let width = 10
        
        /// The height of the tank, in pixels
        public let height = 10
        
        /// The minimum time, in seconds, to reload the tank's cannon
        public let reloadTime = 1.5
        
    }
    
    /**
     Represents a configuration for shells. These values match with the server and are therefore immutable.
     */
    public struct ShellConfig {
        
        /// The natural speed of shells, in pixels per second
        public let speed = 150
        
        /// The width of a shell, in pixels
        public let width = 1
        
        /// The height of a shell, in pixels
        public let height = 1
        
    }
    
}
