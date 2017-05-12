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
    
    /// The configuration for the client server. This resource may be accessed from multiple threads.
    public var configuration: ClientConfiguration {
        return memorySyncQueue.sync {
            return _configuration
        }
    }
    
    /// The configuration for the client server
    private let _configuration: ClientConfiguration
    
    /// The `Log` to write logs to
    public var log: Log {
        return configuration.log
    }
    
    /// A closure to exectute on socket connection. Will be executed on background thread.
    internal var onConnect = {}
    
    /// A closure to exectute on socket disconnection. Will be executed on background thread.
    internal var onDisconnect = {}
    
    /// A closure to execute the first time a message is received from the server. Will be executed from a background thread.
    internal var onFirstReceive = {}
    
    /// A general dispatch queue for websocket callbacks. Tasks on this queue usually will simply dispatch the task to a different queue. This needs to be serial in order to maintain order.
    private let callbackQueue = DispatchQueue(label: "pyTanks Client Callback", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    
    /// A dispatch queue for sending commands to the server. This is serial because we must be certain that commands are sent one at a time in the order they were requested.
    private let sendQueue = DispatchQueue(label: "pyTanks Client Send", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    
    /// A dispatch queue for receiving game states from the server. This is serial because we want to be certain we are appending states to the messageQueue in the correct order.
    private let receiveQueue = DispatchQueue(label: "pyTanks Client Receive", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    
    /// A serial queue for syncronizing access to shared resources.
    private let memorySyncQueue = DispatchQueue(label: "pyTanks Client Shared Resource Sync", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    
    /**
     A queue of messages (in binary format) from the server. The newest message is at the end.
     
     Messages may represent JSON or error messages. Both are encoded as UTF-8.
     
     Messages are pushed onto the end by the `GameClient` and popped off the front by the `GameLoop`.
     
     - note: This resource is synchronized and may be accessed by multiple threads simultaneously.
     */
    public var messageQueue: [Data] {
        
        get {
            return memorySyncQueue.sync {
                return _messageQueue
            }
        }
        
        set {
            memorySyncQueue.async {
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
    public init(configuration: ClientConfiguration) {
        self._configuration = configuration
    }
    
    /**
     Connects the web socket so that send/receive events may be continuously handled.
     
     - note: Once this method returns, all tasks performed by this object, including closure executions,
     will take place off the main thread.
     */
    public func start() {
        self.webSocket = WebSocket(url: configuration.socketUrl, writeQueueQOS: .userInitiated)
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
            log(error: err)
        }
        log.print("Connection closed - shutting down", for: .connectAndDisconnect)
        self.onDisconnect()
    }
    
    private var receivedFirstMessage = false
    
    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        log.print("Received message from server: \(text)", for: .clientIO)
        
        receiveQueue.async {
            let data = text.data(using: .utf8)!
            self.messageQueue.append(data)
            if !self.receivedFirstMessage {
                self.onFirstReceive()
                self.receivedFirstMessage = true
            }
        }
    }
    
    public func websocketDidReceiveData(socket: WebSocket, data: Data) {
        log.print("Received binary message from server: \(data)", for: .clientIO)
    }
    
    /**
     Sends the command to the server. This method returns before work is complete.
     
     - parameter command: The command to send
     */
    public func send(command: Command) {
        sendQueue.async {
            let json = String(data: command.json(), encoding: .utf8)!
            self.webSocket?.write(string: json)
            self.log.print("Sent message to server: \(json)", for: .clientIO)
        }
    }
    
    /**
     Logs an error with a custom description if the error is known.
     
     - parameter error: The error to log
     */
    private func log(error: NSError) {
        
        func logDefault() {
            log.print(error.localizedDescription, for: .errors)
        }
        
        switch error.domain {
        case NSPOSIXErrorDomain:
            switch error.code {
            case POSIXError.connectionRefused.rawValue:
                log.print("Server Connection Refused", for: .errors)
            default:
                logDefault()
            }
        default:
            logDefault()
        }
        
    }
    
    private enum POSIXError: Int, Error {
        case connectionRefused = 61
    }
    
}
