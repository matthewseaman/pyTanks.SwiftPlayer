//
//  GameLoop.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/9/17.
//
//

import Dispatch


public class GameLoop {
    
    private let client: GameClient
    
    /**
     Creates a new `GameLoop` and associates it with the given `client`.
     
     - parameter client: The game client to
     */
    public init(client: GameClient) {
        self.client = client
        
        client.onConnect = { [weak self] in
            self?.state = .running
        }
        
        client.onDisconnect = { [weak self] in
            self?.state = .off
        }
    }
    
    /// Sets the game loop in a waiting state that blocks the main thread if not already running. This method will not return until the client disconnects.
    public func start() {
        guard state == .off else { return }
        self.state = .waiting
        beginRunLoop()
    }
    
    /// Begins the main game loop. This method does not return until `state` is switched to `off`.
    private func beginRunLoop() {
        runLoop: while true {
            switch state {
            case .waiting:
                continue runLoop
            case .running:
                // TODO
                continue runLoop
            case .off:
                break runLoop
            }
        }
    }
    
    /// The current state of the game loop. This resource may be accessed from multiple threads.
    private var state: State {
        
        get {
            return syncQueue.sync {
                return _state
            }
        }
        
        set {
            syncQueue.sync {
                _state = newValue
            }
        }
        
    }
    
    /// The current state of the game loop
    private var _state: State = .off
    
    /// Represents the state of the game loop
    private enum State {
        /// The game loop is not running. This should be the case at the very beginning and at the very end.
        case off
        /// The game loop is running, but it is not actively doing any work other than blocking the main thread so that the program stays alive. This should be the case in the few milliseconds before the web socket actually connects to the server.
        case waiting
        /// The game loop is actively processing frames. This should be the case once the `GameClient` connects to the server.
        case running
    }
    
    /// A serial synchronization queue for managing access to properties like `state`.
    private let syncQueue = DispatchQueue(label: "pyTanks Game Loop Synchronization", qos: .utility, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    
}
