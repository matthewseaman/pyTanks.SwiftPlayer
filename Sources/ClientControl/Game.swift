//
//  Game.swift
//  ClientControl
//
//  Created by Matthew Seaman on 12/28/18.
//

import Foundation
import Client
import PlayerSupport


/// A `Game` is a simple object that can start a `Player` running right away.
///
/// To get started, just do something like:
/// ```swift
/// let myPlayer = // some custom Player
/// Game(player: myPlayer).run()
/// ```
public struct Game {
    
    /// The `Player` object representing this tank's brain.
    private let player: Player
    
    /// Create a new game using a `player`.
    ///
    /// - Parameter player: The brain of your tank.
    public init(player: Player) {
        self.player = player
    }
    
    /// Sets the game running.
    ///
    /// This method does not return until the connection with the server has been closed for whatever reason.
    ///
    /// - Parameter arguments: Arguments from the command line.
    public func run(arguments: [String]) {
        guard let clientConfig = ClientConfiguration.parse(from: arguments) else {
            exit(1)
        }
        
        let gameConfig = GameConfiguration(fps: clientConfig.framesPerSecond)
        
        let client = GameClient(configuration: clientConfig)
        
        let gameLoop = GameLoop(client: client, player: player, configuration: gameConfig)
        
        // This call is asynchronous and will return almost immediately.
        client.start()
        
        // This call will hog the main thread and return once the game is over.
        gameLoop.start()
    }
    
}
