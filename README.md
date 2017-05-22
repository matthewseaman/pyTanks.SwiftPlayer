# pyTanks.SwiftPlayer #

A Swift pyTanks Player client.

### What is pyTanks? ###

pyTanks is a battlefield for Python tank AIs to fight.

* [The Python Server](https://github.com/JoelEager/pyTanks.Server) manages the game and communicates with tank clients about game state.
* [The JavaScript/HTML Viewer](https://github.com/JoelEager/pyTanks.Viewer) manages the display of the battlefield and the scoreboard.
* Tank Player Clients manage and run Tank AIs, communicating with the server by sending and receiving JSON via web sockets.
  - [Python Player](https://github.com/JoelEager/pyTanks.Player) - Works on any OS with Python 3
  - Swift Player - Works on macOS Sierra with Swift 3.1 and Swift Package Manager

### Where does Swift come in? ###
The existing pyTanks.Player expects clients to be written in Python, however, all communication happens via JSON and web sockets. Because these are open standards, a client may theoretically be written in any language. This project provides a Swift template for pyTank players.

### Requirements ###
- macOS 10.12 Sierra or later
- Swift 3.1 or later
- Swift Package Manager

All library dependencies will automatically be collected upon compilation with Swift Package Manager.

**Note: pyTanks is still in beta. API and functionality is subject to change.**

## Basic Structure ##
This project contains several targets, which you may think of as submodules:
- Utils - Provides generic functionality, such as a command line argument parser
- Client - Manages the main game loop and the background connection to the server
- Player - Holds tank AIs that may be chosen.
- pyTanks - The main executable which applies command line arguments, creates a `Player`, and sets the game loop running.

## Usage ##
To compile the player, `cd` to the working directory, then run `source build_executable.sh`. This will place an executable program called `pyTanks` inside `.build/debug/`. It will also place a copy called `start` in the top-level directory.

To run the previously-compiled executable, run `./start` from the top-level directory.

The main client configuration options are specified in the `ClientConfiguration` struct. You may change them directly in your own fork, but a few are customizable on the command line by default:
- `--log logLevel`, where *logLevel* cooresponds to one of the following:
  - 0 - Don't log anything
  - 1 - Connects, disconnects, and errors
  - 2 - Level 1, plus game events and AI logic
  - 3 - Level 2, plus FPS
  - 4 - Level 3, plus Client IO (every incoming and outgoing message)
- `--debug` turns on debug message logging
- `--ip address`, where *address* is the IP address of the pyTanks server you wish to connect to
- `--port p`, where *p* is the port on the pyTanks server you wish to connect to

The default player is `SimplePlayer`, which simply travels in random directions and attempts shooting at enemy tanks without considering walls.

## Create Your Own Tank AI ##
The pyTanks Swift Player is designed to allow the creation of many different `Player` AIs in the same project. The `main.swift` script inside the "pyTanks" target then initializes a specific `Player` and passes it to the game loop to act as the tank's brain. In this way, many different `Player` objects may be created, but only one may be used at a time.

To create a new AI:
- Conform an object to the `Player` protocol.
- In `pyTanks/main.swift`, ensure the `player` constant is set to the `Player` instance you want.

Any object that conforms to the `Player` protocol acts as the brain for a tank. You can either create your own object to conform to this protocol or conform an existing one. The `Player` protocol has the following requirements:
- `var playerDescription: String?` - This variable must provide `get` access to an optional textual description of the AI. This will be displayed in the pyTanks Viewer when a user clicks on the associated tank name.
- `var log: Log!` - This variable must provide `set` access so that that the game loop can set the appropriate `Log` object on your player. This `Log` object may be used to print log messages in a synchronized and logLevel-aware fashion.
- `func connectedToServer()` - A possibly-mutating function that will be called as soon as the first connection to the server is made. Do any setup work here that is not dependent on the current round. You can also put setup work in an `init` method if you do not wish to wait until a connection has been made.
- `func roundStarting(withGameState:)` - Called when a round is starting.
- `func makeMove(withGameState:)` - Called each frame during a round. Must return an array of commands for the tank. This array may be empty. For the first, move in a round, this will be called with the same `GameState` object as `roundStarting(withGameState:)`
- `func tankKilled()` - Called when a tank is killed, regardless of whether it results in the end of a round or not.
- `func roundOver()` - Called when a round is over, even if `tankKilled()` was just called.

The sequence of calls on the `Player` is as follows:
1. `log` is set to a `Log` object before attempting to connect to the server.
2. After a server connection is made, `playerDescription` is accessed and a new info string is sent to the server for the AI.
3. connectedToServer() is called
4. roundStarting(withGameState:)
5. makeMove(withGameState:) each frame
6. tankKilled() only if the tank was killed
7. roundOver() regardless of who won
8. repeat steps 4–7 until termination

Inside the `makeMove(withGameState:)` function, you return a list of commands for the tank. Commands are defined in the `Command` enum. Valid commands include `go`, `stop`, `turn`, and `fire`. See the documentation in `Client/Commands.swift`.

A few things to keep in mind:
- Your tank will die after 1 hit.
- Your tank will automatically stop if it collides with something, but you can always tell it to "go" again.
- Headings are always in radians with 0 being in the direction of the positive x axis.

### The `GameState` ###
At the beginning of each round, and each frame, you are sent a `GameState` object representing the state of the board at a point in time. This gives you access to information about your own tank (`.myTank`), enemy tanks (`otherTanks`), currently flying shells (`shells`), and board walls (`walls`). Note that `otherTanks` are stored in a `Dictionary` with a tank's unique ID as its key. IDs are not guarenteed to be persisted between runs. See the documentation in `GameState.swift` for all the available properties of `GameState`.

## Custom Logging ##
In your AI, you can log at anytime using the `Log` object set on your `Player`'s `log` property. Simply call `print(_:for:)` to print a message conditional on a specific log type being requested. You may pass `.debug` as the log type to treat it as a debug message that should only be printed if `--debug` was specified on the command line.

In your own fork, you may also easily modify which log levels are associated with which log types. Inside the `Log` class (`Client/Log.swift`) is the `LogTypes` struct. This struct conforms to `OptionSet` and simply acts as a bitmask of log types. You can change which types are associated with which levels by modifying lines such as those below:
```swift
/// Includes everything in level 1 plus `gameEvents` and `aiLogic`
public static let level2: LogTypes = [
    .level1,
    .gameEvents,
    .aiLogic
]
```
