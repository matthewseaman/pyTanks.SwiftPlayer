//
//  Log.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/6/17.
//
//

import Dispatch


/**
 Manages the writing of logs to standard out. Each instance of this class holds a `logTypes` option set that specifies which types of information should be logged.
 
 - note: The setup of this object is not thread safe. Once set up, however, you may call `print` from multiple threads simulataneously without negative side effects.
 */
public class Log {
   
    /// The log types to send through standard out
    public let logTypes: LogTypes
    
    /// A serial queue to synchronize log printing
    private let serialQueue = DispatchQueue(label: "pyTanks Client Log", qos: .utility, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    
    /**
     Creates a log with the default log types. The default log types currently correspond to a level 3: `connectAndDisconnect`, `errors`, `gameEvents`, `aiLogic`, and `fps`.
     */
    public init() {
        self.logTypes = .level3
    }
    
    /**
     Create a log for an option set of log types. Desired log types may be mixed and matched.
     */
    public init(logTypes: LogTypes) {
        self.logTypes = logTypes
    }
    
    /**
     Creates a log for the give log level. See `Log.LogTypes`.
     */
    public convenience init(logLevel: Int) {
        self.init(logTypes: LogTypes(logLevel: logLevel))
    }
    
    /**
     Prints a given message to standard out if `logTypes` is/are requested by the `Log`'s requested log types.
     
     - note: You should generally only specify a singular log type, as this acts as an AND (not OR) predicate.
     
     - note: This method is asynchronous and synchronized. You may call this method from multiple threads simultaneously, however logs will be printed one at a time in the order that they were requested.
     
     - parameter message: The message to log
     - parameter logTypes: The log types to log the message for.
     */
    public func print(_ message: String, for logTypes: LogTypes) {
        serialQueue.async {
            
            if self.logTypes.contains(logTypes) {
                var message = message
                
                if logTypes.contains(.errors) {
                    message = "Error: " + message
                }
                
                Swift.print(message)
            }
        }
    }
    
    /**
     Runs `generateMessage` and prints the result only if `logTypes` were requested.
     This method should be used when you don't want to do the work necessary to generate a log
     unless the log type was requested.
     
     - note: You should generally only specify a singular log type, as this acts as an AND (not OR) predicate.
     
     - parameter logTypes: The relevant log typs
     - parameter generateMessage: A closure that generates and returns a message to log
     */
    public func print(ifRequested logTypes: LogTypes, _ generateMessage: () -> String) {
        if (serialQueue.sync { return self.logTypes }).contains(logTypes) {
            print(generateMessage(), for: logTypes)
        }
    }
    
    /// A collection of mix-and-match log types
    public struct LogTypes: OptionSet {
        
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        /**
         Creates a `LogTypes` set representing all log types assoiciated with the given log level.
         
         Numbers less than or equal to 0 translate to no logging. Numbers greater than 5 translate to all logs, which is currently equivilant to level 5.
         */
        public init(logLevel: Int) {
            switch logLevel {
            case let x where x <= 0:
                self = .none
            case 1:
                self = .level1
            case 2:
                self = .level2
            case 3:
                self = .level3
            case 4:
                self = .level4
            case 5:
                self = .level5
            default:
                // logLevel is greater than 5
                self = .all
            }
        }
        
        /// No logging
        public static let none: LogTypes = []
        
        /// Logs for server connects and disconnects
        public static let connectAndDisconnect = LogTypes(rawValue: 1 << 0)
        
        /// Logs for any errors that occur
        public static let errors = LogTypes(rawValue: 1 << 1)
        
        /// Logs for game events in the Client, such as tank spawning and killing
        public static let gameEvents = LogTypes(rawValue: 1 << 2)
        
        /// Logs for AI logic in the Player
        public static let aiLogic = LogTypes(rawValue: 1 << 3)
        
        /// Detailed frames-per-second logs
        public static let fps = LogTypes(rawValue: 1 << 4)
        
        /// Details about input and output when communicating with the server. (i.e. sending commands and receiving game states)
        public static let clientIO = LogTypes(rawValue: 1 << 5)
        
        /// Verbose websocket logging
        public static let websockets = LogTypes(rawValue: 1 << 6)
        
        /// Includes `connectAndDisconnect` and `errors`
        public static let level1: LogTypes = [
            .connectAndDisconnect,
            .errors
        ]
        
        /// Includes everything in level 1 plus `gameEvents` and `aiLogic`
        public static let level2: LogTypes = [
            .level1,
            .gameEvents,
            .aiLogic
        ]
        
        /// Includes everything in level 2 plus `fps`
        public static let level3: LogTypes = [
            .level2,
            .fps
        ]
        
        /// Includes everything in level 3 plus `clientIO`
        public static let level4: LogTypes = [
            .level3,
            .clientIO
        ]
        
        /// Inlcludes everything in level 4 plus `websockets`. This level currently covers all logs.
        public static let level5: LogTypes = [
            .level4,
            .websockets
        ]
        
        /// Includes all logs. Currently equivilant to `level5`.
        public static let all = level5
        
    }
    
}
