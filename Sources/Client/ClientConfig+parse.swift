//
//  ClientConfig+parse.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/21/17.
//
//

import Utils
import PlayerSupport


extension ClientConfiguration {
    
    /// Creates a `ClientConfiguration` from command-line `args`.
    ///
    /// - Parameter args: The full command-line arguments passed.
    /// - Returns: A `ClientConfiguration`, if one could be parsed.
    public static func parse(from args: [String]) -> ClientConfiguration? {
        // Setup arg parser
        let argParser = CommandLineArgumentParser(toolName: "pyTanks", version: "0.1")
        
        // The official command is "run"…
        argParser.addPossibleCommand(withText: "run", description: "(Default) Connects to the pyTanks server and starts the player.")
        
        // …But it doesn't need to be specified explicitly
        argParser.setDefaultCommand(withText: "run")
        
        // Log level may be specified
        argParser.addPossibleOption(withText: "log", description: "The level of logging to use. See README.md.", usingAbreviation: "l", argTypes: ("level", .int))
        
        // Enable debug logs
        argParser.addPossibleOption(withText: "debug", description: "Specify this option to enable debug logs.", usingAbreviation: "d")
        
        // IP may be specified
        argParser.addPossibleOption(withText: "ip", description: "The pyTank server's IP address", usingAbreviation: "a", argTypes: ("address", .string))
        
        // Port may be specified
        argParser.addPossibleOption(withText: "port", description: "The port to connect to on the pyTank server", usingAbreviation: "p", argTypes: ("port", .int))
        
        do {
            let (command, options) = try argParser.parse(arguments: args)
            guard command.text == "run" else { return nil }
            
            // Create config
            var config = ClientConfiguration()
            
            // Set modifiable properties
            for option in options {
                switch option.text {
                case "log":
                    config.log = Log(logLevel: option.arguments[0] as! Int)
                case "ip":
                    config.ipAddress = option.arguments[0] as! String
                case "port":
                    config.port = UInt(option.arguments[0] as! Int)
                default:
                    continue
                }
            }
            if options.contains(where: {$0.text == "debug"}) {
                config.log.enableDebugMessages()
            }
            
            return config
        } catch {
            if let err = error as? CommandLineArgumentParser.UsageError {
                print(err.readableMessage)
            }
            return nil
        }
    }
    
}
