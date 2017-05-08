//
//  GameClient.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/7/17.
//
//

import Foundation
import Dispatch
import Dispatch
import Starscream


/**
 The Game Client is responsible for managing the web socket connection to the pyTanks server, updating the game state, and sending commands.
 */
public class GameClient: WebSocketDelegate {
    
    /// The configuration for the client server
    public let clientConfiguration: ClientConfiguration
    
    /// The configuration for the game
    public let gameConfiguration: GameConfiguration
    
    /// The `Log` to write logs to
    public var log: Log {
        return clientConfiguration.log
    }
    
    /// A closure to exectute on socket connection. Will be executed on background thread.
    public var onConnect = {}
    
    /// A closure to exectute on socket disconnection. Will be executed on background thread.
    public var onDisconnect = {}
    
    /// A dispatch queue for sending commands to the server. This is serial because we must be certain that commands are sent one at a time in the order they were requested.
    private let sendQueue = DispatchQueue(label: "pyTanks Client Send", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    
    /// A dispatch queue for receiving game states from the server. This is serial because we want to be certain we are appending states to the messageQueue in the correct order. (And messageQueue is a shared resource.)
    private let receiveQueue = DispatchQueue(label: "pyTanks Client Receive", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    
    /// A serial queue for syncronizing access to the `messageQueue` shared resource.
    private let messagesSyncQueue = DispatchQueue(label: "pyTanks Client message queue sync", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    
    /**
     A queue of messages (in binary format) from the server. The newest message is at the end.
     
     Messages may represent JSON or
     
     Messages are pushed onto the end by the `GameClient` and popped off the front by the `GameLoop`.
     */
    public var messageQueue = [Data]()
    
    /**
     Creates a new `GameClient`. Typically, only one of these should be created per run.
     
     - parameter clientConfig: The configuration for the client server
     - parameter gameConfig: The configuration for the game
     */
    public init(clientConfig: ClientConfiguration, gameConfig: GameConfiguration) {
        self.clientConfiguration = clientConfig
        self.gameConfiguration = gameConfig
    }
    
    public func websocketDidConnect(socket: WebSocket) {
        log.print("Connected to server", for: .connectAndDisconnect)
        self.onConnect()
    }
    
    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        if let err = error {
            log.print(err.localizedDescription, for: .errors)
        }
        log.print("Connection closed - shutting down", for: .connectAndDisconnect)
        self.onDisconnect()
    }
    
    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        
    }
    
    public func websocketDidReceiveData(socket: WebSocket, data: Data) {
        
    }
    
}
