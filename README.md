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
- Swift 3.1
- Swift Package Manager

All library dependencies will automatically be collected upon compilation with Swift Package Manager.

**Note: pyTanks is still in beta. API and functionality is subject to change.**

## Usage ##
To compile the player, `cd` to the working directory, then run `source build_executable.sh`. This will place an executable program called `pyTanks` inside `.build/debug/`. It will also place a copy called `start` in the top-level directory.

To run the previously-compiled executable, run `./start` from the top-level directory.

The main client configuration options are specified in the `ClientConfiguration` struct. You may change them directly in your own fork, but a few are customizable on the command line by default:
- `--log logLevel`, where logLevel cooresponds to one of the following:
  - 0 - Don't log anything
  - 1 - Connects, disconnects, and errors
  - 2 - Level 1, plus game events and AI logic
  - 3 - Level 2, plus FPS
  - 4 - Level 3, plus Client IO (every incoming and outgoing message)
