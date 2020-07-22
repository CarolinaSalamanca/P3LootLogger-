//
//  ItemsViewController.swift
//  P3LootLogger
//
//  Created by Carolina Salamanca on 7/12/20.
//  Copyright © 2020 Carolina Salamanca. All rights reserved.
//

import Foundation
import UIKit

class ItemsViewController: UITableViewController{
    
    // references for the sceneDelegate
    var itemStore: ItemStore!
    var imageStore: ImageStore!
    
    // The next two methods are required because of the conforming protocols of its superclass
    
    // this returns the number of rows
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return itemStore.allItems.count
    }
    
    // this returns something about the row's cells
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get a reusable and custom cell row (the top one works but this is custom)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell",
                                                 for: indexPath) as! ItemCell
        // indexPath.row refers to a row of the total number of rows in the table view
        let item = itemStore.allItems[indexPath.row]
        
        // Configure the custom cell with the Item
        cell.nameLabel.text = item.name
        cell.serialNumberLabel.text = item.serialNumber
        cell.valueLabel.text = "$\(item.valueInDollars)"
        
        return cell
    }
    
    // This deletes a row from the data and from the view
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        // If the table view is asking to commit a delete command...
        if editingStyle == .delete {
            let item = itemStore.allItems[indexPath.row]
            
            // Remove the item from the store
            itemStore.removeItem(item)
            
            // Remove the item's image from the image store (form cache)
            imageStore.deleteImage(forKey: item.itemKey)
            
            // Also remove that row from the table view with an animation
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // This re-orders items in the tableView
    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {
        // Update the model
        itemStore.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        // Create a new item and add it to the store
        let newItem = itemStore.createItem()
        
        // Figure out where that item is in the array, if its in the array we add it to the tableView
        if let index = itemStore.allItems.firstIndex(of: newItem) {
            let indexPath = IndexPath(row: index, section: 0)
            
            // Insert this new row into the table

            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    // setting tableviews properties
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // this line has nothing to do here xd, but it prints the path were the app bundle (were all the app resources are) is saved
        print(Bundle.main.bundlePath)
        
        // tableView.rowHeight = 65 // fixed height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 65
    }
    
    // to open a view controller from this one with segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the triggered segue is the 'showItem' segue
        switch segue.identifier {
        case "showItem":
            // Figure out which row was just tapped
            if let row = tableView.indexPathForSelectedRow?.row {
                
                // Get the item associated with this row and pass it along
                let item = itemStore.allItems[row]
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.item = item
                
                // the image is assigned here bc its going to be shown in the details screen
                detailViewController.imageStore = imageStore
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    // to reload the tables data when an items is edited from the details view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    //  override the init(coder:) method to set the left bar button item.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem
    }
}
