# pyTanks.SwiftPlayer #

A Swift pyTanks Player client.

### What is pyTanks? ###

pyTanks is a battlefield for Python tank AIs to fight.

* [The Python Server](https://github.com/JoelEager/pyTanks.Server) manages the game and communicates with tank clients about game state.
* [The JavaScript Viewer](https://github.com/JoelEager/pyTanks.Viewer) manages the display of the battlefield and the scoreboard.
* [Tank Player Clients](https://github.com/JoelEager/pyTanks.Player) manage and run Tank AIs, communicating with the server by sending and receiving JSON via web sockets.

### Where does Swift come in? ###
The existing pyTanks.Player expects clients to be written in Python, however, all communication happens via JSON and web sockets. Because these are open standards, a client may theoretically be written in any language. This project provides a Swift template for pyTank players.