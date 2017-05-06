//
//  CommandLineArgumentParser.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/6/17.
//
//

#if SWIFT_PACKAGE
import Foundation
#endif


/**
 Given instructions on possible input, parses command line input and returns more useful objects.
 
 **Thread Safety**
 
 This class should generally be used only on the thread on which it was created.
 */
open class CommandLineArgumentParser {
    
    /// Commands that may be entered
    private final var possibleCommands = [PossibleCommand]()
    
    /// An `Input` value used as the command if the user did not enter a command
    private final var defaultCommand: Input?
    
    /// Options that may be entered
    private final var possibleOptions = [PossibleOption]()
    
    /// The name of the command line tool
    private final let toolName: String
    
    /// The version string of the command line tool
    private final let version: String
    
    /**
     Creates a new `CommandLineArgumentParser` for a command line tool
     
     - parameter toolName: The name of the command line tool
     - parameter version: The version of the command line tool
     */
    public init(toolName: String, version: String) {
        self.toolName = toolName
        self.version = version
    }
    
    /**
     Sets the command that gets set if the user does not specify any commands
     
     - parameter text: The unique text of the command
     - parameter arguments: The arguments to be passed along with the command.
     */
    public final func setDefaultCommand(withText text: String, arguments: Any...) {
        self.defaultCommand = Input(text: text, arguments: arguments)
    }
    
    /**
     Adds a command that could be entered
     
     - parameter text: The unique text that must be entered for the command
     - parameter description: A description of what the command does, also explaining any arguments it takes
     - parameter argTypes: Names and types for the arguments the command should take
     */
    public final func addPossibleCommand(withText text: String, description: String, argTypes: (String, ArgType)...) {
        self.possibleCommands.append(PossibleCommand(text: text, description: description, argTypes: argTypes))
    }
    
    /**
     Adds an option that could be entered
     
     - parameter text: The unique text that must be entered for the option
     - parameter description: A description of what the option does, also explaining any arguments it takes
     - parameter argTypes: Names and types for the arguments the option should take
     */
    public final func addPossibleOption(withText text: String, description: String, usingAbreviation abreviation: String, argTypes: (String, ArgType)...) {
        self.possibleOptions.append(PossibleOption(abreviation: abreviation, text: text, description: description, argTypes: argTypes))
    }
    
    /**
     Returns the command and options represented by a set of arguments from the command line.
     
     - parameter arguments: Arguments from the command line, including the initial executable path argument
     
     - returns: The command, followed by a series of options
     
     - throws: `UsageError`
     */
    public final func parse(arguments: [String]) throws -> (command: Input, options: [Input]) {
        
        assert(!arguments.isEmpty, "Empty Arguments on Command Line")
        
        var args = arguments
        
        // The first argument should be the name or path of the executable, which we don't need to parse because this code would not be running if it wasn't the correct program.
        args.removeFirst()
        
        var command: Input! = nil
        var options = [Input]()
        
        while !args.isEmpty {
            let (input, isCommand) = try parse(partialArguments: &args)
            if isCommand && command == nil {
                // The command should be added only if it has not been already added. There can only be one command.
                command = input
            } else if !isCommand && !options.contains(where: { $0.text == input.text }) {
                // This is an option. There can be any number of options, but not repeats of the same option.
                options.append(input)
            } else {
                // Improper usage of command line tool
                throw UsageError(usageText: usageDescription())
            }
        }
        
        if command == nil {
            if let `default` = defaultCommand {
                command = `default`
            } else {
                throw UsageError(usageText: usageDescription())
            }
        }
        
        return (command, options)
    }
    
    /**
     Returns the first `Input` item that can be created from a list of arguments. `partialArguments` are processed in order and removed after they are processed.
     
     - parameter partialArguments: The remaining entered arguments
     
     - returns: The first `Input` item that could be created, and whether or not it represents a command. (If it's not a command, it's an option.)
     */
    private final func parse(partialArguments: inout [String]) throws -> (Input, isCommand: Bool) {
        
        let fullSpecifier = partialArguments.removeFirst()
        let specifier: String
        let isAbreviation: Bool
        let isCommand: Bool
        
        if fullSpecifier.hasPrefix("-") {
            isCommand = false
            isAbreviation = true
            specifier = fullSpecifier.substring(from: fullSpecifier.index(after: fullSpecifier.startIndex))
        } else if fullSpecifier.hasPrefix("--") {
            isCommand = false
            isAbreviation = true
            specifier = fullSpecifier.substring(from: fullSpecifier.index(fullSpecifier.startIndex, offsetBy: 2))
        } else {
            isCommand = true
            isAbreviation = false
            specifier = fullSpecifier
        }
        
        if isCommand {
            let command = try parse(commandWithSpecifier: specifier, arguments: &partialArguments)
            return (command, isCommand: true)
        } else {
            let option = try parse(optionWithSpecifier: specifier, isAbreviation: isAbreviation, arguments: &partialArguments)
            return (option, false)
        }
    }
    
    /**
     Returns an `Input` item representing an entered option.
     
     This method removes processed arguments from `arguments`
     
     - parameter specifier: The unique text of the option
     - parameter arguments: The remaining arguments the user entered after the specifier
     
     - returns: An `Input` item representing the option
     */
    private final func parse(optionWithSpecifier specifier: String, isAbreviation: Bool, arguments: inout [String]) throws -> Input {
        
        guard let option = possibleOptions.first(where: { (isAbreviation ? $0.abreviation : $0.text) == specifier }) else {
            throw UsageError(usageText: usageDescription())
        }
        
        let convertedArguments = try convert(arguments: &arguments, accordingTo: option.argTypes.map({ $0.type }), usageText: usageDescription(forOption: option))
        
        return Input(text: option.text, arguments: convertedArguments)
    }
    
    /**
     Returns an `Input` item representing an entered command.
     
     This method removes processed arguments from `arguments`
     
     - parameter specifier: The unique text of the command
     - parameter arguments: The remaining arguments the user entered after the specifier
     
     - returns: An `Input` item representing the command
     */
    private final func parse(commandWithSpecifier specifier: String, arguments: inout [String]) throws -> Input {
        
        guard let command = possibleCommands.first(where: { $0.text == specifier }) else {
            throw UsageError(usageText: usageDescription())
        }
        
        let convertedArguments = try convert(arguments: &arguments, accordingTo: command.argTypes.map({ $0.type }), usageText: usageDescription(forCommand: command))
        
        return Input(text: specifier, arguments: convertedArguments)
    }
    
    /**
     Converts `arguments` to there natural types by using `argTypes` to inform it about the natural type for each argument.
     
     This method removes converted arguments from `arguments` before returning.
     
     - parameter arguments: The raw textual arguments. If this array is larger than `argTypes`, the latter elements will be ignored.
     - parameter argTypes: The natural types for each argument
     - parameter usageText: The usage text to be displayed on error
     
     - returns: Arguments in their natural types
     */
    private final func convert(arguments: inout [String], accordingTo argTypes: [ArgType], usageText: String) throws -> [Any] {
        
        guard arguments.count >= argTypes.count else {
            throw UsageError(usageText: usageText)
        }
        
        var converted = [Any]()
        
        for i in 0..<argTypes.count {
            let arg = arguments[i]
            let argType = argTypes[i]
            
            switch argType {
            case .string:
                converted.append(arg)
            case .int:
                guard let int = Int(arg) else {
                    throw UsageError(usageText: usageText)
                }
                converted.append(int)
            case .double:
                guard let double = Double(arg) else {
                    throw UsageError(usageText: usageText)
                }
                converted.append(double)
            }
        }
        
        arguments.removeSubrange(0..<argTypes.count)
        
        return converted
    }
    
    /**
     Returns a usage description for the entire tool, including all commands, options, and their arguments.
     
     - returns: A complete multi-line usage description
     */
    private final func usageDescription() -> String {
        var description = "\(toolName) \(version)"
        description += "\n\n"
        description += "Usage: \(toolName) \(possibleOptions.isEmpty ? "" : "[options] ")[command]"
        description += "\n\n"
        
        if !possibleOptions.isEmpty {
            description += "Options:"
            description += "\n"
        }
        
        for option in possibleOptions {
            description += self.description(forOption: option, indent: 1)
            description += "\n"
        }
        
        description += "Commands:"
        description += "\n"
        
        for command in possibleCommands {
            description += self.description(forCommand: command, indent: 1)
            description += "\n"
        }
        
        return description
    }
    
    /**
     Returns a usage description for `option`, useful for cases where you only want to show the usage of a singular option and not all options/commands.
     
     - parameter option: The option to get a usage description for
     - parameter indent: The number of tabs to indent the usage description
     
     - returns: A multi-line usage description
     */
    private final func usageDescription(forOption option: PossibleOption, indent: Int = 0) -> String {
        return "usage:\n\(description(forOption: option, indent: indent + 1))"
    }
    
    /**
     Returns a usage description for `command`, useful for cases where you only want to show the usage of a singular command and not all options/commands.
     
     - parameter command: The command to get a usage description for
     - parameter indent: The number of tabs to indent the usage description
     
     - returns: A multi-line usage description
     */
    private final func usageDescription(forCommand command: PossibleCommand, indent: Int = 0) -> String {
        return "usage:\n\(description(forCommand: command, indent: indent + 1))"
    }
    
    /**
     Returns a description of `option` suitable for a usage description
     
     - parameter option: The option to get a description of
     - parameter indent: The number of tabs to indent the description
     
     - returns: A multi-line description
     */
    private final func description(forOption option: PossibleOption, indent: Int = 0) -> String {
        let indentation = "\t" * indent
        var description = "\(indentation)[-\(option.abreviation) | --\(option.text)]"
        add(argumentTitles: option.argTypes.map({ $0.title }), toExampleUsage: &description)
        description += "\n"
        description += "\(indentation)\t\(option.description)"
        return description
    }
    
    /**
     Returns a description of `command` suitable for a usage description
     
     - parameter command: The command to get a description of
     - parameter indent: The number of tabs to indent the description
     
     - returns: A multi-line description
     */
    private final func description(forCommand command: PossibleCommand, indent: Int = 0) -> String {
        let indentation = "\t" * indent
        var description = "\(indentation)\(command.text)"
        add(argumentTitles: command.argTypes.map({ $0.title }), toExampleUsage: &description)
        description += "\n"
        description += "\(indentation)\t\(command.description)"
        return description
    }
    
    /**
     Appends argument requirements onto `description`, which is typically an example usage.
     
     For example, if `description` is "command" and one argument is provided, `description` after return will be "command <argument_title>".
     
     - parameter argumentTitles: Argument names to append
     - parameter description: An existing usage example to append to
     */
    private final func add(argumentTitles: [String], toExampleUsage description: inout String) {
        for title in argumentTitles {
            description += " <\(title)>"
        }
    }
    
    /// A command or option and its arguments as input by the user.
    public struct Input: CustomDebugStringConvertible {
        
        /// The raw text of the entered input
        public let text: String
        
        /// The entered arguments. The type of each argument is specified when calling `addPossibleCommand` or `addPossibleOption`.
        public let arguments: [Any]
        
        public var debugDescription: String {
            return "\(text) \(arguments)"
        }
        
    }
    
    /// A description of a possible option
    private struct PossibleOption {
        
        /// The short version of the option specifier (not including -)
        let abreviation: String
        
        /// The expanded version of the option (not including --)
        let text: String
        
        /// A help description for the option
        let description: String
        
        /// The type(s) of argument(s) expected after the option specifer. This may be empty.
        let argTypes: [(title: String, type: ArgType)]
        
    }
    
    /// A description of a possible command
    private struct PossibleCommand {
        
        /// The required command name
        let text: String
        
        /// A help description for the command
        let description: String
        
        /// The type(s) of argument(s) expected after the command. This may be empty.
        let argTypes: [(title: String, type: ArgType)]
        
    }
    
    /// A type of argument
    public enum ArgType {
        /// A `String`
        case string
        /// An `Int`
        case int
        /// A `Double`
        case double
    }
    
    /// An error in the usage of a command-line tool. In this situation, you would typically display usage information to the user. You can access recommended usage text in the `usageText` property of this error object.
    public struct UsageError: Error {
        
        /// The usage text to be displayed
        public let usageText: String
        
        /// A human-readable description
        public var readableMessage: String {
            return usageText
        }
        
    }
    
}
