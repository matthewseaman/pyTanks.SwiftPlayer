//
//  GameState.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/6/17.
//
//

#if SWIFT_PACKAGE
import Foundation
#endif


/**
 An instance of `GameState` stores the current state of a game, including the positions and other properties of all tanks, shells, and walls on the map.
 
 A single instance of this class would typically be constantly updated by higher-level objects, then read and written to by others.
 */
public class GameState {
    
    /// True if a game is currently ongoing
    public var isGameOngoing: Bool
    
    /// The Player's tank
    public var myTank: Tank
    
    /// The other tanks on the field
    public var otherTanks: [Tank]
    
    /// All shells currently on the map. Shells are assumed to be moving if they are on the map.
    public var shells: [Shell]
    
    /// All walls on the map for this match
    public private(set) var walls: [Wall]
    
    /**
     Creates a new `GameState`
     
     - parameter ongoingGame: True if a game is currently ongoing
     - parameter myTank: The Player's tank
     - parameter otherTanks: The other tanks on the field
     - parameter shells: All shells currently on the map
     - parameter walls: All walls on the map for this match
     */
    internal init(ongoingGame: Bool, myTank: Tank, otherTanks: [Tank], shells: [Shell], walls: [Wall]) {
        self.isGameOngoing = ongoingGame
        self.myTank = myTank
        self.otherTanks = otherTanks
        self.shells = shells
        self.walls = walls
    }
    
    /// Encapsulates information about a tank
    public struct Tank {
        
        /// The center x coordinate for the tank on the map
        public var centerX: Double
        
        /// The center y coordinate for the tank on the map
        public var centerY: Double
        
        /// The heading of the tank, in radians, from the positive x axis
        public var heading: Double
        
        /// True iff the tank is moving
        public var isMoving: Bool
        
        /// True iff the tank is still alive
        public var isAlive: Bool
        
        /// True iff the tank can shoot. `nil` if this is someone else's tank
        public var canShoot: Bool!
        
        /// The name of the tank. `nil` if this is someone else's tank
        public var name: String!
        
    }
    
    /// Encapsulates information about a shell. If a shell is on the map, it is moving.
    public struct Shell {
        
        /// The id of the shooting tank
        public var shooterId: Int
        
        /// The center x coordinate of the shell on the map
        public var centerX: Double
        
        /// The center y coordinate of the shell on the map
        public var centerY: Double
        
        /// The heading of the shell, in radians, from the positive x axis
        public var heading: Double
        
    }
    
    /// Encapsulates information about a wall on the map
    public struct Wall {
        
        /// The width of the wall, in pixels
        public var width: Double
        
        /// The height of the wall, in pixels
        public var height: Double
        
        /// The center x coordinate of teh wall on the map
        public var centerX: Double
        
        /// The center y coordinate of teh wall on the map
        public var centerY: Double
        
    }
    
}
