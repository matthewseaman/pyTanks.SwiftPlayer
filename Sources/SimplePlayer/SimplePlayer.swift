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
    
    /// `true` if `Command.go` should be sent on the next frame without further analysis.
    private var sendGoOnNextFrame = false
    
    public init() {}
    
    public func connectedToServer() {
        log.print("connectedToServer", for: .debug)
        
        // Nothing special to do here
    }
    
    public func roundStarting(withGameState gameState: GameState) {
        log.print("roundStarting", for: .debug)
        
        // Nothing much to do here either
    }
    
    public mutating func makeMove(withGameState gameState: GameState) -> Command? {
        log.print("makeMove", for: .debug)
        
        if sendGoOnNextFrame {
            sendGoOnNextFrame = false
            log.print("Going", for: .gameEvents)
            return Command.go
        }
        
        // Keep moving
        if !gameState.myTank.isMoving {
            sendGoOnNextFrame = true
            log.print("Turning", for: .gameEvents)
            return Command.turn(heading: Double.random(in: -6...6) / 6 * .pi)
        }
        
        // Shoot at someone without paying attention to walls
        if gameState.myTank.canShoot ?? false && !gameState.otherTanks.isEmpty {
            // choose tank to shoot at
            let target = gameState.otherTanks.randomElement()!.value
            
            // Only shoot if alive
            if target.isAlive {
                let dx = target.centerX - gameState.myTank.centerX
                let dy = target.centerY - gameState.myTank.centerY
                let angle = atan2(-dy, dx) // y axis is flipped from standard radian system
                log.print("Firing", for: .gameEvents)
                return Command.fire(heading: angle)
            }
        }
        
        return nil
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
