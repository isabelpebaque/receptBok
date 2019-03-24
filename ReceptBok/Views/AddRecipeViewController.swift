//
//  AddRecipeViewController.swift
//  ReceptBok
//
//  Created by Isabel Pebaqué on 2019-03-08.
//  Copyright © 2019 Isabel Pebaqué. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class AddRecipeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var ref = Database.database().reference()
    let userId = Auth.auth().currentUser?.uid
    let storage = Storage.storage()
    
    
    var recipeImgpath : String?
    var name : String?
    var ingredients : String?
    var instructions : String?

    @IBOutlet weak var recipeNameTextView: UITextView!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var recipeImageView: UIImageView!
   
    // Sätter ramarna runt textviews och startar funktionen setupKeyboardDismissRecognizer
    override func viewWillAppear(_ animated: Bool) {
        setupKeyboardDismissRecognizer()
        
        addBorderTo(textView: recipeNameTextView)
        addBorderTo(textView: ingredientsTextView)
        addBorderTo(textView: instructionsTextView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func addImageButtonPressed(_ sender: UIButton) {
        getImage(fromSourceType: .photoLibrary)
    }
    
    // Metod som öppnar upp fotoalbum/kamera beroende på vilken sourcetype vi väljer som parameter
    func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self 
        picker.allowsEditing = true
        
        self.present(picker, animated: true, completion: nil)
    }
    
    func setupKeyboardDismissRecognizer() {
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(AddRecipeViewController.dismissKeyboard))
        
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func addBorderTo(textView: UITextView) {
        textView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        
        uploadToFirestoreStorage()
    }
    
    func addDataToFirebase() {

        name = recipeNameTextView.text
        ingredients = ingredientsTextView.text
        instructions = instructionsTextView.text
        
        // Saving data to database
        let newPrivateRecipe = [
            "recipeName":name,
            "ingredients":ingredients,
            "instructions":instructions,
            "recipeImage":recipeImgpath
        ]
        
        let newPublicRecipe = [
            "name":name,
            "ingredients":ingredients,
            "instructions":instructions,
            "recipeImage":recipeImgpath
        ]
        
        ref.child("AllCookBooks").child(userId!).child("aCookBookName").childByAutoId().setValue(newPrivateRecipe)
        ref.child("publicRecipes").childByAutoId().setValue(newPublicRecipe)
        
        dismiss(animated: true, completion: nil)
    }
    
    // Metod som vid val av bild, sparar bilden och presenterar den i UIImageView och sparar det till Firebase Storage
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker : UIImage?
        
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
            
        } else if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImageFromPicker = editedImage
            
        }
        
        
        if let selectedImage = selectedImageFromPicker {
            recipeImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func uploadToFirestoreStorage() {
        
        let storage = self.storage.reference()
        
        let storageRef = storage.child("recipesImages/\(userId!)/\(recipeNameTextView.text!).png")
        
        let resizedImage = resizeImage(image: recipeImageView.image!, targetSize: CGSize.init(width: 1024, height: 1024))
        
        let uploadData = resizedImage
        if let imageData = uploadData.pngData() {
            
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print(error!)
                } else {
                    print(metadata!)
                    storageRef.downloadURL { (url, error) in
                        if error != nil {
                            print("fel vid nedladdning av url")
                            print(error.debugDescription)
                        } else {
                            self.recipeImgpath = url?.absoluteString
                            print("URL är:")
                            print(url!)
                            self.addDataToFirebase()
                        }
                    }
                }
            }
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
