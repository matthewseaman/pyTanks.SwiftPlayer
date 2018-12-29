//
//  SimplePlayer.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/12/17.
//
//

import Foundation
import PlayerSupport


/**
 `SimplePlayer` keeps moving, turning a new random direction each time it encounters an obstacle. It also shoots as fast as possible, selecting a random tank each time. If the selected tank is not alive, it avoids shooting that turn.
 */
public struct SimplePlayer: Player {
    
    public var log: Log!
    
    public var gameConfig: GameConfiguration!
    
    public var playerDescription: String? {
        return "Swift client using the example SimplePlayer."
    }
    
    public init() {}
    
    public func connectedToServer() {
        log.print("connectedToServer", for: .debug)
        
        // Nothing special to do here
    }
    
    public func roundStarting(withGameState gameState: GameState) {
        log.print("roundStarting", for: .debug)
        
        // Nothing much to do here either
    }
    
    public mutating func makeMove(withGameState gameState: GameState) -> [Command] {
        log.print("makeMove", for: .debug)
        
        var commands = [Command]()
        
        // Keep moving
        if !gameState.myTank.isMoving {
            let turn = Command.turn(heading: Double.random(in: 1...12) * 2 * .pi)
            let move = Command.go
            commands.append(turn)
            commands.append(move)
            log.print("Turned and started moving", for: .gameEvents)
        }
        
        // Shoot at someone without paying attention to walls
        if gameState.myTank.canShoot ?? false && !gameState.otherTanks.isEmpty {
            // choose tank to shoot at
            let target = gameState.otherTanks.randomElement()!.value
            
            // Only shoot if alive
            if target.isAlive {
                let deltaX = abs(target.centerX - gameState.myTank.centerX)
                let deltaY = gameState.myTank.centerY - target.centerY
                var angle: Double
                if deltaX == 0 {
                    angle = deltaY >= 0 ? .pi / 2 : 3 * .pi / 2
                } else {
                    angle = atan(deltaY / deltaX)
                    if target.centerX < gameState.myTank.centerX {
                        angle = .pi - angle
                    }
                }
                let fire = Command.fire(heading: angle)
                commands.append(fire)
                log.print("Fired", for: .gameEvents)
            }
        }
        
        return commands
    }
    
    public func tankKilled() {
        log.print("tankKilled", for: .debug)
        
        // Nothing to do here
    }
    
    public func roundOver() {
        log.print("roundOver", for: .debug)
        
        // Nothing to do here
    }
    
}
