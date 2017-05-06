//
//  Operators.swift
//  pyTanks.SwiftPlayer
//
//  Created by Matthew Seaman on 5/6/17.
//
//

#if SWIFT_PACKAGE
import Foundation
#endif

/// Creates a `String` with `str` repeated `repeat` times.
public func *(str: String, repeat: Int) -> String {
    assert(`repeat` >= 0)
    
    var master = ""
    for _ in 0..<`repeat` {
        master += str
    }
    
    return master
}
