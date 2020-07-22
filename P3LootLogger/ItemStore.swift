//
//  ItemStore.swift
//  P3LootLogger
//
//  Created by Carolina Salamanca on 7/12/20.
//  Copyright © 2020 Carolina Salamanca. All rights reserved.
//

import Foundation
import UIKit

class ItemStore {

    var allItems = [Item]()

    // This annotation means that a caller of this func is free to ignore the result of calling this func
    // if we hadnt used it, a warning saying: "result of the function unused" appears whenwe call it in the constructor below
    @discardableResult func createItem() -> Item {
        let newItem = Item(random: true)
        allItems.append(newItem)
        return newItem
    }
    
    func removeItem(_ item: Item) {
        if let index = allItems.firstIndex(of: item) {
            allItems.remove(at: index)
        }
    }
    
    // change item position in the array
    func moveItem(from fromIndex: Int, to toIndex: Int) {
        if fromIndex == toIndex {
            return
        }

        // Get reference to object being moved so you can reinsert it
        let movedItem = allItems[fromIndex]

        // Remove item from array
        allItems.remove(at: fromIndex)

        // Insert item in array at new location
        allItems.insert(movedItem, at: toIndex)
    }
    
    
    // saving items in the fiel system
    @objc func saveChanges() -> Bool { //objc To expose the method to the Objective-C r
       print("Saving items to: \(itemArchiveURL)")

        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(allItems)
            try data.write(to: itemArchiveURL, options: [.atomic])
            print("Saved all of the items")
            return true
        } catch let encodingError {
            print("Error encoding allItems: \(encodingError)")
            return false
        }
    }
    
    // this is a closure () not a computed property
    // this variable is asigned its value froma  aclosure bc this way the code is more maintainable, bc
    // the code needed to give it a value is kept together
    // this is useful to declare or initialize vars that need multiple lines of code
    let itemArchiveURL: URL = {
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("items.plist")
    }()
    
    // get saved items in the file system (if i run  it in a new device that has no saved items it goes to the catch block and prints an error)
    init() {
        do {
              let data = try Data(contentsOf: itemArchiveURL)
              let unarchiver = PropertyListDecoder()
              let items = try unarchiver.decode([Item].self, from: data)
              allItems = items
          } catch {
            print("Error reading in saved items: \(error)")
          }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(saveChanges),
                                       name: UIScene.didEnterBackgroundNotification,
                                       object: nil)
    }
}
