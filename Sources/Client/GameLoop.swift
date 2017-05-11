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
    
    /// The last time a frame was processed. `nil` if no frames have been received.
    private var lastFrameTime: Date? = nil
    
    /// The number of seconds since the last frame was processed
    private var secondsSinceLastFrame: Double? {
        guard let lastTime = lastFrameTime else { return nil }
        return -lastTime.timeIntervalSinceNow
    }
    
    /// The standard number of seconds per frame, disregarding compensation
    private var baseDelay: Double {
        return 1 / Double(client.configuration.framesPerSecond)
    }
    
    /// The number of frame deltas used in a sample for averaging and further calculation
    private let frameDeltaSampleSize = 15
    
    /// The most recent time gaps between frames
    private var frameDeltas = [Double]() {
        
        didSet {
            // Keep count to 15 max
            if frameDeltas.count > frameDeltaSampleSize {
                frameDeltas.removeFirst()
            }
        }
        
    }
    
    /// The approximate minimum frames-per-second rate. This variable is only maintained if FPS logging is enabled.
    private lazy var minimumFPS: Double = {
        return Double(self.client.configuration.framesPerSecond)
    }()
    
    /// The last time a frames-per-second rate was logged. `nil` if this has not taken place. This variable is only maintained if FPS logging is enabled.
    private var lastFPSLogTime: Date? = nil
    
    /// The number of seconds since the last time FPS was logged. This variable is only maintained if FPS logging is enabled.
    private var secondsSinceLastFPSLog: Double? {
        guard let lastTime = lastFPSLogTime else { return nil }
        return -lastTime.timeIntervalSinceNow
    }
    
    /// The number of frames processed since the last FPS log. This variable is only maintained if FPS logging is enabled.
    private var frameCount = 0
    
    /// Begins the main game loop. This method does not return until `state` is switched to `off`.
    private func beginRunLoop() {
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
        
        // The delay to enforce until the next frame
        var delay = baseDelay
        
        // Add frame delta if this is not the first frame
        if let frameDelta = secondsSinceLastFrame {
            self.lastFrameTime = Date()
            
            self.frameDeltas.append(frameDelta)
            
            // Adjust delay to try keeping FPS within 5% of target
            let averageDelta = frameDeltas.reduce(0.0, +) / Double(frameDeltas.count)
            let targetFramesPerActualFrame = averageDelta * targetFPS
            if targetFramesPerActualFrame < 0.95 {
                delay += baseDelay * 0.01
            } else if targetFramesPerActualFrame > 1.05 {
                delay -= baseDelay * 0.01
            }
            
            // Ensure delay is non-negative
            if delay < 0 { delay = 0 }
            
            logFPSIfNeeded(averageFrameDelta: averageDelta)
            
            makeMove(frameDelta: frameDelta)
        } else {
            self.lastFrameTime = Date()
            makeMove(frameDelta: nil)
        }
        
        // Sleep main thread until next frame
        let microsecondDelay = UInt32((delay * 1_000_000).rounded(.toNearestOrAwayFromZero))
        usleep(microsecondDelay)
    }
    
    /**
     Update the local game state and act upon it, possibly asking the client to send a command. Called once per frame.
     
     - parameter frameDelta: The time, in seconds, since the last frame. Pass `nil` if this is the first frame.
     */
    private func makeMove(frameDelta: Double?) {
        
    }
    
    /// Logs average and minimum frames-per-second if FPS logging is requested. This function also respects the FPS log rate set in the client configuration.
    private func logFPSIfNeeded(averageFrameDelta: Double) {
        
        guard let logDelta = secondsSinceLastFPSLog,
            logDelta >= client.configuration.fpsLogRate else { return }
        
        client.log.print(ifRequested: .fps) {
            
            // Set new minimum FPS if necessary
            if averageFrameDelta > 0 && 1 / averageFrameDelta < minimumFPS {
                self.minimumFPS = 1 / averageFrameDelta
            }
            
            self.frameCount += 1
            
            let fpsFormatter = NumberFormatter()
            fpsFormatter.numberStyle = .none
            fpsFormatter.maximumFractionDigits = client.configuration.fpsLogMaximumFractionDigits
            let avgFPS = Double(frameCount) / client.configuration.fpsLogRate
            let message = "FPS: avg=\(fpsFormatter.string(from: avgFPS as NSNumber)!), min=\(fpsFormatter.string(from: minimumFPS as NSNumber)!)"
            
            self.frameCount = 0
            self.minimumFPS = Double(client.configuration.framesPerSecond)
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
