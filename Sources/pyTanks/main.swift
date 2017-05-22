//
//  main.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/7/17.
//
//

import Utils
import Client
import Players


// Start
if let clientConfig = clientConfig() {
    
    let gameConfig = GameConfiguration()
    
    let client = GameClient(configuration: clientConfig)
    
    let player = SimplePlayer()
    
    let gameLoop = GameLoop(client: client, player: player, configuration: gameConfig)
    
    // This call is asynchronous and will return almost immediately.
    client.start()
    
    // This call will hog the main thread and return once the game is over.
    gameLoop.start()
}
