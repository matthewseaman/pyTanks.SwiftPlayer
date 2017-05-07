//
//  Log.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/6/17.
//
//


/**
 Manages the writing of logs to standard out. Each instance of this class holds a `logTypes` option set that specifies which types of information should be logged.
 
 - note: This type is not synchronized. Calling code should ensure thread safety.
 */
public class Log {
   
    /// The log types to send through standard out
    public var logTypes: LogTypes = .level3
    
    /**
     Creates a log with the default log types. The default log types currently correspond to a level 3: `connectAndDisconnect`, `errors`, `gameEvents`, `aiLogic`, and `fps`.
     */
    public init() {}
    
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
     
     - parameter message: The message to log
     - parameter logTypes: The log types to log the message for. You should generally only specify a singular log type, as this acts as an AND (not OR) predicate.
     */
    public func print(_ message: String, for logTypes: LogTypes) {
        if self.logTypes.contains(logTypes) {
            Swift.print(message)
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
        
        /// Details about input and output when communicating with the server
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
