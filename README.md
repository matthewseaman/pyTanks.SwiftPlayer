# pyTanks.SwiftPlayer

A Swift pyTanks Player client.

### What is pyTanks? ###

pyTanks is a battleground for Python AIs to fight it out.

* [The Python Server](https://github.com/JoelEager/pyTanks.Server) manages the game and communicates with tank clients about game state.
* [The JavaScript/HTML Viewer](https://github.com/JoelEager/pyTanks.Viewer) manages the display of the battlefield and the scoreboard.
* Tank Player Clients manage and run Tank AIs, communicating with the server by sending and receiving JSON via web sockets.
  - [Python Player](https://github.com/JoelEager/pyTanks.Player) - Works on any OS with Python 3
  - Swift Player - Works on macOS Sierra or later with Swift 4.2 and Swift Package Manager. You may also get it to run on Linux, but Linux is not officially supported at this time.

### Where does Swift come in? ###
The existing pyTanks.Player expects clients to be written in Python, however, all communication happens via JSON and web sockets. Because these are open standards, a client may theoretically be written in any language. This project provides a Swift template for pyTank players.

### Requirements ###
- macOS 10.12 Sierra or later
- Swift 4.2 or later
- Swift Package Manager, which will automatically collect any dependencies upon building.

## Vended Products ##
This package contains 3 products that are publically vended:
- `pyTanks` — An executable that runs the `SimplePlayer` example AI.
- `PyPlayer` — A library that other packages can use to build custom `Player` brains.
- `PyClient` — A library that other packages can use to build custom Player executables.

*Rather than needing to fork this repo, you can get your own AI up and running by simply adding this package as a dependency to your own package.*

## Usage ##
To compile the player, run `Utils/build-executable <config>`, where `<config>` is `debug` or `release`. This will place an executable program called `start` at the top level of the working directory.

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

### Working in Xcode ###
To work on a fork in Xcode, run `swift package generate-xcodeproj` from the command line while inside the working directory. After opening the newly generated `pyTanks.SwiftPlayer.xcodeproj` file, be sure to change the project target to macOS 10.12 instead of 10.10. This allows it to be built, run, and debugged inside Xcode.

## Create Your Own Tank AI ##

To create a new AI:
- Create a Swift package and add this one as a dependency.
- In some target, `import PyPlayer` and conform an object to the `Player` protocol.
- Create an executable target with code like the following:

```swift
import CustomPlayer
import PyClient

let myPlayer = CustomPlayer()
Game(player: myPlayer).run(arguments: CommandLine.arguments)
```

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
3. `connectedToServer()` is called
4. `roundStarting(withGameState:)`
5. `makeMove(withGameState:)` each frame
6. `tankKilled()` only if the tank was killed
7. `roundOver()` regardless of who won
8. repeat steps 4–7 until termination

Inside the `makeMove(withGameState:)` function, you return a list of commands for the tank. Commands are defined in the `Command` enum. Valid commands include `go`, `stop`, `turn`, and `fire`. See the documentation in `PlayerSupport/Commands.swift`.

A few things to keep in mind:
- Your tank will die after 1 hit.
- Your tank will automatically stop if it collides with something, but you can always tell it to "go" again.
- Headings are always in radians with 0 being in the direction of the positive x axis.

### The `GameState` ###
At the beginning of each round, and each frame, you are sent a `GameState` object representing the state of the board at a point in time. This gives you access to information about your own tank (`.myTank`), enemy tanks (`otherTanks`), currently flying shells (`shells`), and board walls (`walls`). Note that `otherTanks` are stored in a `Dictionary` with a tank's unique ID as its key. IDs are not guarenteed to be persisted between runs. See the documentation in `GameState.swift` for all the available properties of `GameState`.

## Custom Logging ##
In your AI, you can log at anytime using the `Log` object set on your `Player`'s `log` property. Simply call `print(_:for:)` to print a message conditional on a specific log type being requested. You may pass `.debug` as the log type to treat it as a debug message that should only be printed if `--debug` was specified on the command line.

In your own fork, you may also easily modify which log levels are associated with which log types. Inside the `Log` class (`PlayerSupport/Log.swift`) is the `LogTypes` struct. This struct conforms to `OptionSet` and simply acts as a bitmask of log types. You can change which types are associated with which levels by modifying lines such as those below:
```swift
/// Includes everything in level 1 plus `gameEvents` and `aiLogic`
public static let level2: LogTypes = [
    .level1,
    .gameEvents,
    .aiLogic
]
```
