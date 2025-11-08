//
//  Item.swift
//  PrepareInterview
//
//  Created by furkan gurcay on 8.11.2025.
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
