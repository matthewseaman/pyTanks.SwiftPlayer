//
//  Player.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/12/17.
//
//


/**
 Conforming types act as a the primary brain for a tank.
 Different players may use their own AI strategy.
 */
public protocol Player {
    
    /**
     Called when the player is first connected to the server.
     This is your opportunity to do per-session (not per-round) setup work such as setting an info string.
     
     If called, this function will always be called before `roundStarting()`.
     */
    func connectedToServer()
    
    /**
     Called at the beginning of each round.
     This is your opportunity to do any per-round setup work.
     
     - parameter gameState: The initial game state
     */
    func roundStarting(withGameState gameState: GameState)
    
    /**
     Called each frame.
     This is your opportunity to send a command based on the updated `gameState`.
     
     For the first frame of each round, this is called immediately after `roundStarting(withGameState:)` with the same `GameState` object.
     
     - parameter gameState: The updated game state
     
     - returns: An optional command for the tank to execute
     */
    func makeMove(withGameState gameState: GameState) -> Command?
    
    /**
     Called when the player's tank is killed.
     This is your opportunity to do any learning for the next match.
     You can also clean things up here, because if your tank is killed the round is effectively over for you.
     */
    func tankKilled()
    
    /**
     Called when a round is over.
     This is your opportunity to do any clean-up before setting up for the next round.
     
     - parameter roundResult: Whether the player won or lost
     */
    func roundOver(withResult roundResult: RoundResult)
    
}

/// The result of a game round
public enum RoundResult {
    /// Your tank won the round
    case won
    /// Your tank lost the round
    case lost
}
