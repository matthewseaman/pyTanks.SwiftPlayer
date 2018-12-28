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
    
    /// A description of the player to be sent to the server as an info string
    var playerDescription: String? { get }
    
    /// A log to write messages to. Set by the `GameLoop` during its initialization.
    var log: Log! { get set }
    
    /// A game configuration set by the `GameLoop` during its initialization.
    var gameConfig: GameConfiguration! { get set }
    
    /**
     Called when the player is first connected to the server.
     This is your opportunity to do per-session (not per-round) setup work such as setting an info string.
     
     If called, this function will always be called before `roundStarting()`.
     */
    mutating func connectedToServer()
    
    /**
     Called at the beginning of each round. This may also be called in the middle of a round if a player joins in the middle of an existing round.
     This is your opportunity to do any per-round setup work.
     
     - parameter gameState: The initial game state
     */
    mutating func roundStarting(withGameState gameState: GameState)
    
    /**
     Called each frame.
     This is your opportunity to send a command based on the updated `gameState`.
     
     For the first frame of each round, this is called immediately after `roundStarting(withGameState:)` with the same `GameState` object.
     
     - parameter gameState: The updated game state
     
     - returns: An optional list of commands for the tank to execute in order
     */
    mutating func makeMove(withGameState gameState: GameState) -> [Command]
    
    /**
     Called when the player's tank is killed.
     This is your opportunity to do any learning for the next round. Perhaps try to avoid that mistake again.
     You can also clean things up here, because if your tank is killed the round is effectively over for you.
     */
    mutating func tankKilled()
    
    /**
     Called when a round is over.
     This is your opportunity to do any clean-up before setting up for the next round.
     */
    mutating func roundOver()
    
}
