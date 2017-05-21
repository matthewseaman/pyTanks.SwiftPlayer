//
//  SimplePlayer.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/12/17.
//
//

import Client
import GameplayKit


public struct SimplePlayer: Player {
    
    public var log: Log!
    
    public var playerDescription: String? {
        return "Swift client using the SimplePlayer."
    }
    
    /// The random source responsible for generating random behaviors
    public var randomSource = GKARC4RandomSource()
    
    public init() {}
    
    /// A random distribution for choosing which direction to turn. Uniform floats [1/12, 1.0] from this distribution are multiplied by 2π to determine which direction to turn.
    private lazy var turnRandomDistribution: GKRandomDistribution = {
        return GKRandomDistribution(randomSource: self.randomSource, lowestValue: 1, highestValue: 12)
    }()
    
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
            let turn = Command.turn(heading: Double(turnRandomDistribution.nextUniform() * 2 * Float.pi))
            let move = Command.go
            commands.append(turn)
            commands.append(move)
            log.print("Turned and started moving", for: .gameEvents)
        }
        
        // Shoot at someone without paying attention to walls
        if gameState.myTank.canShoot && !gameState.otherTanks.isEmpty {
            // choose tank to shoot at
            let index = GKRandomDistribution(randomSource: randomSource, lowestValue: 0, highestValue: gameState.otherTanks.count - 1).nextInt()
            let (_, target) = Array(gameState.otherTanks)[index]
            
            // Only shoot if alive
            if target.isAlive {
                let deltaX = gameState.myTank.centerX - target.centerX
                if deltaX != 0 {
                    let deltaY = gameState.myTank.centerY - target.centerY
                    let angle = atan(deltaY / deltaX)
                    
                    
                }
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
