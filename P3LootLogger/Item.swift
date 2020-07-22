//
//  Item.swift
//  P3LootLogger
//
//  Created by Carolina Salamanca on 7/12/20.
//  Copyright © 2020 Carolina Salamanca. All rights reserved.
//

import Foundation
import UIKit

class Item: Equatable, Codable  { // Conforms to equatable to be able to compare items
    var name: String
    var valueInDollars: Int
    var serialNumber: String?
    let dateCreated: Date
    let itemKey: String

    // Designated initilizer, its used because not all its props are initialized with a default value
    init(name: String, serialNumber: String?, valueInDollars: Int) {
        self.name = name
        self.valueInDollars = valueInDollars
        self.serialNumber = serialNumber
        self.dateCreated = Date()
        self.itemKey = UUID().uuidString
    }
    
    // Convenience initializer (helpers, in case the designated is not used)
    convenience init(random: Bool = false) {
        if random {
            let adjectives = ["Fluffy", "Rusty", "Shiny"]
            let nouns = ["Bear","Bear", "Spork", "Mac"]

            let randomAdjective = adjectives.randomElement()! // force unwrapping, bc i know the array is not empty
            let randomNoun = nouns.randomElement()! // force unwrapping, bc i know the array is not empty

            let randomName = "\(randomAdjective) \(randomNoun)"
            let randomValue = Int.random(in: 0..<100)
            let randomSerialNumber =
                UUID().uuidString.components(separatedBy: "-").first!

            self.init(name: randomName,
                      serialNumber: randomSerialNumber,
                      valueInDollars: randomValue)
        } else {
            self.init(name: "", serialNumber: nil, valueInDollars: 0)
        }
    }
    
    static func ==(lhs: Item, rhs: Item) -> Bool {
          return lhs.name == rhs.name
              && lhs.serialNumber == rhs.serialNumber
              && lhs.valueInDollars == rhs.valueInDollars
              && lhs.dateCreated == rhs.dateCreated
      }
}
