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
     
     If `log` is non-nil, this init logs non-breaking errors to it. Non-breaking errors include any missing or invalid values in the JSON. When this occurs, that particular value is not updated in the JSON, or the default value is used.
     
     - note: This function performs all work on the calling thread and performs no synchronization
     
     - parameter json: The json game state
     - parameter log: A log to write non-breaking errors to
     
     - throws: `JSONError` if the data is invalid JSON or does not contain a top-level dictionary
     */
    internal init(json: Data, loggingTo log: Log? = nil) throws {
        self.init(ongoingGame: false, myTank: Tank(id: 0, centerX: 0.0, centerY: 0.0, heading: 0.0, isMoving: false, isAlive: false, canShoot: false, name: "None", info: nil, kills: 0, wins: 0), otherTanks: [:], shells: [], walls: [])
        try self.update(with: json, loggingTo: log)
    }
    
    /**
     Updates the `GameState` with the given game state JSON package
     
     If `log` is non-nil, this method logs non-breaking errors to it. Non-breaking errors include any missing or invalid values in the JSON. When this occurs, that particular value is not updated in the JSON, or the default value is used.
     
     - note: This function performs all work on the calling thread and performs no synchronization
     
     - parameter json: The json game state
     - parameter log: A log to write non-breaking errors to
     
     - throws: `JSONError` if the data is invalid JSON or does not contain a top-level dictionary
     */
    internal mutating func update(with json: Data, loggingTo log: Log? = nil) throws {
        // Parse
        let topLevelDict: [String : Any]
        do {
            guard let dict = try JSONSerialization.jsonObject(with: json, options: []) as? [String : Any] else {
                throw JSONError.noTopLevelDict
            }
            topLevelDict = dict
        } catch {
            throw JSONError.notValidJSON
        }
        
        /**
         Logs an error for the missing key
         
         - parameter key: The key that is missing or of an invalid type
         */
        func logMissing(keyPath: String) {
            let error = JSONError.missing(keyPath: keyPath)
            log?.print("\(error)", for: .errors)
        }
        
        /**
         Logs an error for the invalid key value
         
         - parameter keyPath: Teh key whose value was invalid
         - parameter value: The invalid value
         */
        func logInvalid(keyPath: String, value: CustomStringConvertible) {
            let error = JSONError.invalid(keyPath: keyPath, value: value)
            log?.print("\(error)", for: .errors)
        }

        // isGameOngoing
        if let ongoingGame = topLevelDict["\(JSONKey.isGameOngoing)"] as? Bool {
            self.isGameOngoing = ongoingGame
        } else {
            logMissing(keyPath: "\(JSONKey.isGameOngoing)")
        }
        
        // myTank
        if let tankDict = topLevelDict["\(JSONKey.myTank)"] as? [String : Any] {
            
            // x
            if let x = tankDict["\(JSONKey.x)"] as? Double {
                self.myTank.centerX = x
            } else {
                logMissing(keyPath: "\(JSONKey.myTank) -> \(JSONKey.x)")
            }
            
            // y
            if let y = tankDict["\(JSONKey.y)"] as? Double {
                self.myTank.centerY = y
            } else {
                logMissing(keyPath: "\(JSONKey.myTank) -> \(JSONKey.y)")
            }
            
            // heading
            if let heading = tankDict["\(JSONKey.heading)"] as? Double {
                self.myTank.heading = heading
            } else {
                logMissing(keyPath: "\(JSONKey.myTank) -> \(JSONKey.heading)")
            }
            
            // isMoving
            if let moving = tankDict["\(JSONKey.isMoving)"] as? Bool {
                self.myTank.isMoving = moving
            } else {
                logMissing(keyPath: "\(JSONKey.myTank) -> \(JSONKey.isMoving)")
            }
            
            // isAlive
            if let alive = tankDict["\(JSONKey.isAlive)"] as? Bool {
                self.myTank.isAlive = alive
            } else {
                logMissing(keyPath: "\(JSONKey.myTank) -> \(JSONKey.isAlive)")
            }
            
            // id
            if let id = tankDict["\(JSONKey.id)"] as? Int {
                self.myTank.id = id
            } else {
                logMissing(keyPath: "\(JSONKey.myTank) -> \(JSONKey.id)")
            }
            
            // name
            if let name = tankDict["\(JSONKey.name)"] as? String {
                self.myTank.name = name
            } else {
                logMissing(keyPath: "\(JSONKey.myTank) -> \(JSONKey.name)")
            }
            
            // info
            if let info = tankDict["\(JSONKey.info)"] as? String {
                self.myTank.info = info
            } else {
                logMissing(keyPath: "\(JSONKey.myTank) -> \(JSONKey.info)")
            }
            
            // kills
            if let kills = tankDict["\(JSONKey.kills)"] as? Int {
                self.myTank.kills = kills
            } else {
                logMissing(keyPath: "\(JSONKey.myTank) -> \(JSONKey.kills)")
            }
            
            // wins
            if let wins = tankDict["\(JSONKey.wins)"] as? Int {
                self.myTank.wins = wins
            } else {
                logMissing(keyPath: "\(JSONKey.myTank) -> \(JSONKey.wins)")
            }
            
            // canShoot
            if let canShoot = tankDict["\(JSONKey.canShoot)"] as? Bool {
                self.myTank.canShoot = canShoot
            } else {
                logMissing(keyPath: "\(JSONKey.myTank) -> \(JSONKey.canShoot)")
            }
            
        } else {
            logMissing(keyPath: "\(JSONKey.myTank)")
        }
        
        // otherTanks
        if let tanksList = topLevelDict["\(JSONKey.otherTanks)"] as? [[String : Any]] {
            
            self.otherTanks = [:]
            
            for tankDict in tanksList {
                
                var tank = Tank(id: 0, centerX: 0.0, centerY: 0.0, heading: 0.0, isMoving: false, isAlive: false, canShoot: nil, name: nil, info: nil, kills: nil, wins: nil)
                
                // x
                if let x = tankDict["\(JSONKey.x)"] as? Double {
                    tank.centerX = x
                } else {
                    logMissing(keyPath: "\(JSONKey.otherTanks) -> \(JSONKey.x)")
                }
                
                // y
                if let y = tankDict["\(JSONKey.y)"] as? Double {
                    tank.centerY = y
                } else {
                    logMissing(keyPath: "\(JSONKey.otherTanks) -> \(JSONKey.y)")
                }
                
                // heading
                if let heading = tankDict["\(JSONKey.heading)"] as? Double {
                    tank.heading = heading
                } else {
                    logMissing(keyPath: "\(JSONKey.otherTanks) -> \(JSONKey.heading)")
                }
                
                // isMoving
                if let moving = tankDict["\(JSONKey.isMoving)"] as? Bool {
                    tank.isMoving = moving
                } else {
                    logMissing(keyPath: "\(JSONKey.otherTanks) -> \(JSONKey.isMoving)")
                }
                
                // isAlive
                if let alive = tankDict["\(JSONKey.isAlive)"] as? Bool {
                    tank.isAlive = alive
                } else {
                    logMissing(keyPath: "\(JSONKey.otherTanks) -> \(JSONKey.isAlive)")
                }
                
                // id
                if let id = tankDict["\(JSONKey.id)"] as? Int {
                    tank.id = id
                } else {
                    logMissing(keyPath: "\(JSONKey.otherTanks) -> \(JSONKey.id)")
                }
                
                self.otherTanks[tank.id] = tank
            }
            
        } else {
            logMissing(keyPath: "\(JSONKey.otherTanks)")
        }
        
        // shells
        if let shellsList = topLevelDict["\(JSONKey.shells)"] as? [[String : Any]] {
            
            self.shells = []
            
            for shellDict in shellsList {
                
                var shell = Shell(shooterId: 1, centerX: 0.0, centerY: 0.0, heading: 0.0)
                
                // shooterId
                if let shooterId = shellDict["\(JSONKey.shooterId)"] as? Int {
                    shell.shooterId = shooterId
                } else {
                    logMissing(keyPath: "\(JSONKey.shells) -> \(JSONKey.shooterId)")
                }
                
                // x
                let shellXKeyPath = "\(JSONKey.shells) -> \(JSONKey.x)"
                if let x = shellDict["\(JSONKey.x)"] as? Double {
                    if x < 0.0 { logInvalid(keyPath: shellXKeyPath, value: x) }
                    shell.centerX = x
                } else {
                    logMissing(keyPath: shellXKeyPath)
                }
                
                // y
                let shellYKeyPath = "\(JSONKey.shells) -> \(JSONKey.y)"
                if let y = shellDict["\(JSONKey.y)"] as? Double {
                    if y < 0.0 { logInvalid(keyPath: shellYKeyPath, value: y) }
                    shell.centerY = y
                } else {
                    logMissing(keyPath: shellYKeyPath)
                }
                
                // heading
                if let heading = shellDict["\(JSONKey.heading)"] as? Double {
                    shell.heading = heading
                } else {
                    logMissing(keyPath: "\(JSONKey.shells) -> \(JSONKey.heading)")
                }
                
                self.shells.append(shell)
            }
            
        } else {
            logMissing(keyPath: "\(JSONKey.shells)")
        }
        
        // walls
        if let wallsList = topLevelDict["\(JSONKey.walls)"] as? [[String : Any]] {
            
            self.walls = []
            
            for wallDict in wallsList {
                
                var wall = Wall(width: 1.0, height: 1.0, centerX: 0.0, centerY: 0.0)
                
                // width
                let wallWidthKeyPath = "\(JSONKey.walls) -> \(JSONKey.width)"
                if let width = wallDict["\(JSONKey.width)"] as? Double {
                    if width < 0.0 { logInvalid(keyPath: wallWidthKeyPath, value: width) }
                    wall.width = width
                } else {
                    logMissing(keyPath: wallWidthKeyPath)
                }
                
                // height
                let wallHeightKeyPath = "\(JSONKey.walls) -> \(JSONKey.height)"
                if let height = wallDict["\(JSONKey.height)"] as? Double {
                    if height < 0.0 { logInvalid(keyPath: wallHeightKeyPath, value: height) }
                    wall.height = height
                } else {
                    logMissing(keyPath: wallHeightKeyPath)
                }
                
                // x
                let wallXKeyPath = "\(JSONKey.walls) -> \(JSONKey.x)"
                if let x = wallDict["\(JSONKey.x)"] as? Double {
                    if x < 0.0 { logInvalid(keyPath: wallXKeyPath, value: x) }
                    wall.centerX = x
                } else {
                    logMissing(keyPath: wallXKeyPath)
                }
                
                // y
                let wallYKeyPath = "\(JSONKey.walls) -> \(JSONKey.y)"
                if let y = wallDict["\(JSONKey.y)"] as? Double {
                    if y < 0.0 { logInvalid(keyPath: wallYKeyPath, value: y) }
                    wall.centerY = y
                } else {
                    logMissing(keyPath: wallYKeyPath)
                }
                
                self.walls.append(wall)
            }
            
        } else {
            logMissing(keyPath: "\(JSONKey.walls)")
        }
    }
    
    /// Expected keys for JSON game state objects. Keys are top-level unless otherwise specified
    private enum JSONKey: String, CustomStringConvertible {
        case isGameOngoing = "ongoingGame"
        case myTank = "myTank"
        case otherTanks = "tanks"
        case shells = "shells"
        case walls = "walls"
        /// Nested inside `myTank`, `tanks`, `shells`, and `walls`
        case x = "x"
        /// Nested inside `myTank`, `tanks`, `shells`, and `walls`
        case y = "y"
        /// Nested inside each item in `walls`
        case height = "height"
        /// Nested inside each item in `walls`
        case width = "width"
        /// Nested inside `myTank`, `tanks`, and `shells`
        case heading = "heading"
        /// Nested inside `myTank` and `tanks`
        case isMoving = "moving"
        /// Nested inside `myTank` and `tanks`
        case isAlive = "alive"
        /// Nested inside `myTank` and `tanks`
        case id = "id"
        /// Nested inside `myTank`
        case name = "name"
        /// Nested inside `myTank`
        case info = "info"
        /// Nested inside `myTank`
        case kills = "kills"
        /// Nested inside `myTank`
        case wins = "wins"
        /// Nested inside `myTank`
        case canShoot = "canShoot"
        /// Nested inside each item in `shells`
        case shooterId = "shooterId"
        
        fileprivate var description: String {
            return rawValue
        }
    }
    
}
