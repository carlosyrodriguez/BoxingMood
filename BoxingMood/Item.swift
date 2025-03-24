//
//  Item.swift
//  BoxingMood
//
//  Created by Los on 3/23/25.
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
