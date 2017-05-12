//
//  SimplePlayer.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/12/17.
//
//

import Client


public struct SimplePlayer: Player {
    
    public init() {}
    
    public func connectedToServer() {
        
    }
    
    public func roundStarting(withGameState gameState: GameState) {
        
    }
    
    public func makeMove(withGameState gameState: GameState) -> Command? {
        return nil
    }
    
    public func tankKilled() {
        
    }
    
    public func roundOver(withResult roundResult: RoundResult) {
        
    }
    
}
