//
//  Item.swift
//  AIPoweredFitnessApp
//
//  Created by kyle cahill on 2026-06-28.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
