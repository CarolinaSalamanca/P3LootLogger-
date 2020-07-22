//
//  ImageStore.swift
//  P3LootLogger
//
//  Created by Carolina Salamanca on 7/14/20.
//  Copyright © 2020 Carolina Salamanca. All rights reserved.
//

import UIKit

class ImageStore {
    
    // this works like a dictionary (do same operations but it automatically removes objects when os is low in memory)
    let cache = NSCache<NSString,UIImage>() // NSstring is the objective-c way of string (we have to use it because NSCache is objective c)
    
    // these methods are to manipulate imgs in cache only (not in docs directory)
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
        
        // this is for saving in directory (calls the below method)
        // Create full URL for image
        let url = imageURL(forKey: key)
        
        // Turn image into JPEG data
        if let data = image.jpegData(compressionQuality: 0.5) {
            // Write it to full URL
            try? data.write(to: url)
        }
    }
    
    func image(forKey key: String) -> UIImage? {
        //return cache.object(forKey: key as NSString)
        // if img is in cache
        if let existingImage = cache.object(forKey: key as NSString) {
            return existingImage
        }

        // if image can be retrieved from disk save it in cache, else return nil
        let url = imageURL(forKey: key)
        // if the condition doesn met executes else, si no executes the code below
        guard let imageFromDisk = UIImage(contentsOfFile: url.path) else {
            return nil
        }

        cache.setObject(imageFromDisk, forKey: key as NSString)
        return imageFromDisk
    }
    
    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString) // remove from cache

        // remove also from file system
        let url = imageURL(forKey: key)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error removing the image from disk: \(error)")
        }
    }
    
    // this is only for saving items in documents directory (not in cache)
    func imageURL(forKey key: String) -> URL {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        
        return documentDirectory.appendingPathComponent(key)
    }
}
