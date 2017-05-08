//
//  main.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/7/17.
//
//

import Utils
import Client


// Setup arg parser
let argParser = CommandLineArgumentParser(toolName: "Start", version: "0.1")
argParser.addPossibleCommand(withText: "run", description: "Connects to the pyTanks server and starts the plaer.")
argParser.setDefaultCommand(withText: "run")

do {
    let (command, options) = try argParser.parse(arguments: CommandLine.arguments)
    print("Command: \(command.text)")
} catch {
    if let err = error as? CommandLineArgumentParser.UsageError {
        print(err.readableMessage)
    }
}
