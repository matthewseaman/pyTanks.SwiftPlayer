# pyTanks.SwiftPlayer #

A Swift pyTanks Player client.

### What is pyTanks? ###

pyTanks is a battlefield for Python tank AIs to fight.

* [The Python Server](https://github.com/JoelEager/pyTanks.Server) manages the game and communicates with tank clients about game state.
* [The JavaScript/HTML Viewer](https://github.com/JoelEager/pyTanks.Viewer) manages the display of the battlefield and the scoreboard.
* Tank Player Clients manage and run Tank AIs, communicating with the server by sending and receiving JSON via web sockets.
  - Python Player - Works on any OS with Python 3
  - Swift Player - Works on macOS Sierra with Swift 3.1 and Swift Package Manager

### Where does Swift come in? ###
The existing pyTanks.Player expects clients to be written in Python, however, all communication happens via JSON and web sockets. Because these are open standards, a client may theoretically be written in any language. This project provides a Swift template for pyTank players.

### Requirements ###
- macOS 10.12 Sierra or later
- Swift 3.1
- Swift Package Manager

All library dependencies will automatically be collected upon compilation with Swift Package Manager.

**Note: pyTanks is still in beta. API and functionality is subject to change.**
