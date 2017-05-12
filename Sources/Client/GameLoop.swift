//
//  GameLoop.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/9/17.
//
//

import Foundation
import Dispatch


public class GameLoop {
    
    /// The configuration for the game
    public let configuration: GameConfiguration
    
    /// The associated Game Client that manages the connection to the server and provides a message queue for reading
    private let client: GameClient
    
    /// The current game state object. Should remain set after the first set.
    private var gameState: GameState!
    
    /**
     Creates a new `GameLoop` and associates it with the given `client`.
     
     - parameter client: The game client to
     */
    public init(client: GameClient, configuration: GameConfiguration) {
        self.client = client
        self.configuration = configuration
        
        // Wait until we get the initial game state
        client.onFirstReceive = { [weak self] in
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
    
    /// The requested frames-per-second for processing
    private var targetFPS: Double {
        return Double(self.client.configuration.framesPerSecond)
    }
    
    /// The target seconds-per-frame for processing
    private var targetSPF: Double {
        return 1 / targetFPS
    }
    
    /// The most recent time gaps between frames. This is used only for logging.
    private var frameDeltas = [Double]()
    
    /// The last time a frames-per-second rate was logged. `nil` if this has not taken place. This variable is only maintained if FPS logging is enabled.
    private lazy var lastFPSLogTime = Date()
    
    /// The number of seconds since the last time FPS was logged. This variable is only maintained if FPS logging is enabled.
    private var secondsSinceLastFPSLog: Double {
        return -lastFPSLogTime.timeIntervalSinceNow
    }
    
    /// Begins the main game loop. This method does not return until `state` is switched to `off`.
    private func beginRunLoop() {
        client.log.print("Target: \(targetSPF) s", for: .debug)
        runLoop: while true {
            switch state {
            case .waiting:
                continue runLoop
            case .running:
                processFrame()
                continue runLoop
            case .off:
                break runLoop
            }
        }
    }
    
    /**
     Processes a single frame, maintaing the target frame rate.
     */
    private func processFrame() {
        
        let frameStartTime = Date()
        
        logFPSIfNeeded()
        
        makeMove()
        
        // Delay before next frame to keep target FPS
        let processTime = -frameStartTime.timeIntervalSinceNow
        client.log.print("Processing: \(processTime) s", for: .debug)
        if processTime < targetSPF {
            let microseconds = (targetSPF - processTime) * 1_000_000
            client.log.print("Leftover: \(microseconds / 1_000_000) s", for: .debug)
            usleep(UInt32(microseconds))
        }
        
        self.frameDeltas.append(-frameStartTime.timeIntervalSinceNow)
    }
    
    /**
     Update the local game state and act upon it, possibly asking the client to send a command. Called once per frame.
     */
    private func makeMove() {
        
    }
    
    /// Logs average and minimum frames-per-second if FPS logging is requested. This function also respects the FPS log rate set in the client configuration.
    private func logFPSIfNeeded() {
        
        guard frameDeltas.count > 0 else { return }
        
        guard secondsSinceLastFPSLog >= client.configuration.fpsLogRate else { return }
        
        client.log.print(ifRequested: .fps) {
            
            
            let fpsFormatter = NumberFormatter()
            fpsFormatter.numberStyle = .none
            fpsFormatter.maximumFractionDigits = client.configuration.fpsLogMaximumFractionDigits
            
            let avgFPS = Double(frameDeltas.count) / secondsSinceLastFPSLog
            let minFPS = 1 / frameDeltas.max()!
            
            let message = "FPS: avg=\(fpsFormatter.string(from: avgFPS as NSNumber)!), min=\(fpsFormatter.string(from: minFPS as NSNumber)!)"
            
            self.frameDeltas = []
            self.lastFPSLogTime = Date()
            
            return message
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
