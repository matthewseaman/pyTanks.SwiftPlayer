//
//  Operators.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 1/26/17.
//
//


/// Creates a `String` with `str` repeated `repeat` times.
public func *(str: String, repeat: Int) -> String {
    assert(`repeat` >= 0)
    
    var master = ""
    for _ in 0..<`repeat` {
        master += str
    }
    
    return master
}
