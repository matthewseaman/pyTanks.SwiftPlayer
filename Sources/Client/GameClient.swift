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
    
    /// A general dispatch queue for websocket callbacks. Tasks on this queue usually will simply dispatch the task to a different queue. This needs to be serial in order to maintain order.
    private let callbackQueue = DispatchQueue(label: "pyTanks Client Callback", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    
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
     
     - note: This resource is synchronized and may be accessed by multiple threads simultaneously.
     */
    public var messageQueue: [Data] {
        
        get {
            return messagesSyncQueue.sync {
                return _messageQueue
            }
        }
        
        set {
            messagesSyncQueue.async {
                self._messageQueue = newValue
            }
        }
        
    }
    
    /// Underlying storage for `messageQueue`
    private var _messageQueue = [Data]()
    
    /// The currently connected web socket
    public var webSocket: WebSocket?
    
    /**
     Creates a new `GameClient`. Typically, only one of these should be created per run.
     
     - parameter clientConfig: The configuration for the client server
     - parameter gameConfig: The configuration for the game
     */
    public init(clientConfig: ClientConfiguration, gameConfig: GameConfiguration) {
        self.clientConfiguration = clientConfig
        self.gameConfiguration = gameConfig
    }
    
    /**
     Connects the web socket so that send/receive events may be continuously handled.
     
     - note: Once this method returns, all tasks performed by this object, including closure executions,
     will take place off the main thread.
     */
    public func start() {
        self.webSocket = WebSocket(url: clientConfiguration.socketUrl, writeQueueQOS: .userInitiated)
        webSocket?.callbackQueue = callbackQueue
        webSocket?.delegate = self
        webSocket?.connect()
    }
    
    /**
     Intentionally disconnects the web socket and stops all tasks performed by this object.
     */
    public func stop() {
        webSocket?.disconnect()
        self.webSocket = nil
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
        log.print("Received message from server: \(text)", for: .clientIO)
        
        receiveQueue.async {
            let data = text.data(using: .utf8)!
            self.messageQueue.append(data)
        }
    }
    
    public func websocketDidReceiveData(socket: WebSocket, data: Data) {
        log.print("Received binary message from server: \(data)", for: .clientIO)
    }
    
    public func send(command: Command) {
        
    }
    
}
