#!/bin/bash
# Build Swift Package Executable into .build/Debug/
swift build -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.12"
cp ./.build/debug/pyTanks start
