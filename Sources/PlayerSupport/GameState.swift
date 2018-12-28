//
//  GameState.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/6/17.
//
//

import Foundation


/// An object that may be moved by a given distance in its existing heading
public protocol Moveable {
    /// The x coordinate, in pixels, where larger x's are further right
    var centerX: Double { get set }
    /// The y coordinate, in pixels, where larger y's are further down
    var centerY: Double { get set }
    /// The current heading, in radians
    var heading: Double { get }
}

extension Moveable {
    
    /**
     Moves `self` `distance` pixels in its current heading.
     
     - parameter distance: The number of pixels to move in the current heading
     */
    public mutating func move(_ distance: Double) {
        self.centerX += cos(self.heading) * distance
        self.centerY -= sin(self.heading) * distance
    }
    
}

/**
 An instance of `GameState` stores the current state of a game, including the positions and other properties of all tanks, shells, and walls on the map.
 
 - note: This is a value type, so if used from multiple threads, each thread gets its own copy (not reference).
 */
public struct GameState {
    
    /// True if a game is currently ongoing
    public var isGameOngoing: Bool
    
    /// The Player's tank
    public var myTank: Tank
    
    /// The other tanks on the field, by id
    public var otherTanks: [Int: Tank]
    
    /// All shells currently on the map. Shells are assumed to be moving if they are on the map.
    public var shells: [Shell]
    
    /// All walls on the map for this match
    public var walls: [Wall]
    
    /**
     Creates a new `GameState`
     
     - parameter ongoingGame: True if a game is currently ongoing
     - parameter myTank: The Player's tank
     - parameter otherTanks: The other tanks on the field
     - parameter shells: All shells currently on the map
     - parameter walls: All walls on the map for this match
     */
    public init(ongoingGame: Bool, myTank: Tank, otherTanks: [Int: Tank], shells: [Shell], walls: [Wall]) {
        self.isGameOngoing = ongoingGame
        self.myTank = myTank
        self.otherTanks = otherTanks
        self.shells = shells
        self.walls = walls
    }
    
    /// Encapsulates information about a tank
    public struct Tank: Moveable {
        
        /// The unique id of the tank. These values are not guarenteed to persist across connections.
        public var id: Int
        
        /// The center x coordinate for the tank on the map
        public var centerX: Double
        
        /// The center y coordinate for the tank on the map
        public var centerY: Double
        
        /// The heading of the tank, in radians, from the positive x axis
        public var heading: Double
        
        /// `true` iff the tank is moving
        public var isMoving: Bool
        
        /// `true` iff the tank is still alive
        public var isAlive: Bool
        
        /// `true` iff your tank can shoot. `nil` if this is someone else's tank
        public var canShoot: Bool?
        
        /// The name of your tank. `nil` if this is someone else's tank
        public var name: String?
        
        /// A player-set info string for your tank. `nil` if this is someone else's tank
        public var info: String?
        
        /// The number of kills in the current round. `nil` if this is someone else's tank
        public var kills: Int?
        
        /// The number of rounds won. `nil` if this is someone else's tank
        public var wins: Int?
        
        /// Creates a new `Tank`.
        ///
        /// - Parameters:
        ///   - id: The unique id of the tank. These values are not guarenteed to persist across connections.
        ///   - centerX: The center x coordinate for the tank on the map
        ///   - centerY: The center y coordinate for the tank on the map
        ///   - heading: The heading of the tank, in radians, from the positive x axis
        ///   - isMoving: `true` iff the tank is moving
        ///   - isAlive: `true` iff the tank is still alive
        ///   - canShoot: `true` iff your tank can shoot. `nil` if this is someone else's tank
        ///   - name: The name of your tank. `nil` if this is someone else's tank
        ///   - info: A player-set info string for your tank. `nil` if this is someone else's tank
        ///   - kills: The number of kills in the current round. `nil` if this is someone else's tank
        ///   - wins: The number of rounds won. `nil` if this is someone else's tank
        public init(id: Int, centerX: Double, centerY: Double, heading: Double, isMoving: Bool, isAlive: Bool, canShoot: Bool?, name: String?, info: String?, kills: Int?, wins: Int?) {
            self.id = id
            self.centerX = centerX
            self.centerY = centerY
            self.heading = heading
            self.isMoving = isMoving
            self.isAlive = isAlive
            self.canShoot = canShoot
            self.name = name
            self.info = info
            self.kills = kills
            self.wins = wins
        }
        
    }
    
    /// Encapsulates information about a shell. If a shell is on the map, it is moving.
    public struct Shell: Moveable {
        
        /// The id of the shooting tank
        public var shooterId: Int
        
        /// The center x coordinate of the shell on the map
        public var centerX: Double
        
        /// The center y coordinate of the shell on the map
        public var centerY: Double
        
        /// The heading of the shell, in radians, from the positive x axis
        public var heading: Double
        
        /// Creates a new `Shell`.
        ///
        /// - Parameters:
        ///   - shooterId: The id of the shooting tank
        ///   - centerX: The center x coordinate of the shell on the map
        ///   - centerY: The center y coordinate of the shell on the map
        ///   - heading: The heading of the shell, in radians, from the positive x axis
        public init(shooterId: Int, centerX: Double, centerY: Double, heading: Double) {
            self.shooterId = shooterId
            self.centerX = centerX
            self.centerY = centerY
            self.heading = heading
        }
        
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
        
        /// Creates a new `Wall`.
        ///
        /// - Parameters:
        ///   - width: The width of the wall, in pixels
        ///   - height: The height of the wall, in pixels
        ///   - centerX: The center x coordinate of teh wall on the map
        ///   - centerY: The center y coordinate of teh wall on the map
        public init(width: Double, height: Double, centerX: Double, centerY: Double) {
            self.width = width
            self.height = height
            self.centerX = centerX
            self.centerY = centerY
        }
        
    }
    
}
