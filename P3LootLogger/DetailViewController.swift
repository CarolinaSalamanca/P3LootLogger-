//
//  DetailViewController.swift
//  P3LootLogger
//
//  Created by Carolina Salamanca on 7/13/20.
//  Copyright © 2020 Carolina Salamanca. All rights reserved.
//

import UIKit


class DetailViewController: UIViewController, UITextFieldDelegate,// conform to UITextFieldDelegate to implement a method to dismiss the keyboard on return key press
    UINavigationControllerDelegate, UIImagePickerControllerDelegate // conforms to those to be the delegate of iuImagePicker
{
    @IBOutlet var nameField: UITextField!
    @IBOutlet var serialNumberField: UITextField!
    @IBOutlet var valueField: UITextField!
    @IBOutlet var dateField: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var imageStore: ImageStore!

    var item: Item!{
        didSet {
            navigationItem.title = item.name
        }
    }
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    // the fields for the item retrieve the items info
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameField.text = item.name
        serialNumberField.text = item.serialNumber
        valueField.text = numberFormatter.string(from: NSNumber(value: item.valueInDollars))
        dateField.text = dateFormatter.string(from: item.dateCreated)
        
        // Get the item key
        let key = item.itemKey

        // If there is an associated image with the item, display it on the image view
        if let imageToDisplay = imageStore.image(forKey: key){
            imageView.image = imageToDisplay
        }
    }
    
    // Update the item when the user dismisses the details page
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Clear first responder to dismiss the key board firts and then go back to the items screen
        view.endEditing(true)
        
        // 'Save' changes to item
        item.name = nameField.text ?? ""
        item.serialNumber = serialNumberField.text
        
        if let valueText = valueField.text,
            let value = numberFormatter.number(from: valueText) {
            item.valueInDollars = value.intValue
        } else {
            item.valueInDollars = 0
        }
    }
    
    // dismissing the keyboard  upon tapping Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // it checks whether any text field in its hierarchy is the first responder.and resigns
        textField.resignFirstResponder()
        return true
    }
    
    // dismiss keyboard when the background is tapped (we used a gesture tap recognizer)
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // action for the camera item in the toollbar
    @IBAction func choosePhotoSource(_ sender: UIBarButtonItem) {
        
        // we create an UIAlertController instance to let the user decide how to upload the picture
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet) // it can be .actionSheet or .alert
        
        // Defines the style presentation of the alert
        alertController.modalPresentationStyle = .popover
        
        // Creates a pointer to the element that triggered the alert ((the camera icon) it only works for bigger devices)
        alertController.popoverPresentationController?.barButtonItem = sender
        
        // defines the actions for the alertController,
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) { // first, verifies that theres a camera on the device or is available
            // Each action is given a title, a style, and a closure to execute if that action is selected by the user.
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                let imagePicker = self.imagePicker(for: .camera) // calls the below method telling the camera is the  source type
                self.present(imagePicker, animated: true, completion: nil) // shows the img picker according to the user choice (camera)
            }
            // add action to the controller
            alertController.addAction(cameraAction)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            // calls the below method telling the library is the  source type
            let imagePicker = self.imagePicker(for: .photoLibrary)
            
            // gives format on how the photoLibrary should be presented
            imagePicker.modalPresentationStyle = .popover
            imagePicker.popoverPresentationController?.barButtonItem = sender
            
            // shows the img picker according to the user choice (photoLibrary)
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Adds actions to the controller
        alertController.addAction(cancelAction)
        alertController.addAction(photoLibraryAction)
        
        // Once the alert is configured, its shown in the screen 
        present(alertController, animated: true, completion: nil)
        
        // each time i run this method i see an error with the constraints, i did my research but its an xcode bug
    }
    
    // MARK: THIS IS A USEFUL DIVIDER 
    // It tells where to get images from
    func imagePicker(for sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self // declare this instance is the delagate of UIImagePicker
        return imagePicker
    }
    
    // get the selected image from the library or camera (notice that the method is didFinishPickingMediaWithInfo)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey: Any]) {

        // Get picked image from info dictionary
        let image = info[.originalImage] as! UIImage

        // Store the image in the ImageStore for the item's key
        // notice the images are saved immediately after being taken, and the instances of Item are saved only when the app enters the background.
        //You save the images right away because they are too big to keep in memory for long.
        imageStore.setImage(image, forKey: item.itemKey)
        
        // Put that image on the screen in the image view
        imageView.image = image

        // Take image picker off the screen - you must call this dismiss method
        dismiss(animated: true, completion: nil)
    }
}
