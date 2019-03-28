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
import SVProgressHUD

class AddRecipeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    var ref = Database.database().reference()
    let userId = Auth.auth().currentUser?.uid
    let storage = Storage.storage()
    
    
    var recipeImgpath : String?
    var name : String?
    var ingredients : String?
    var instructions : String?

    @IBOutlet weak var secretRecipeSwitch: UISwitch!
    @IBOutlet weak var recipeNameTextView: UITextView!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var recipeImageView: UIImageView?
   
    // Sätter ramarna runt textviews och startar funktionen setupKeyboardDismissRecognizer
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        setupKeyboardDismissRecognizer()
        
        addBorderToTextViews()
        addPlaceholderInTextview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeNameTextView.delegate = self
        ingredientsTextView.delegate = self
        instructionsTextView.delegate = self
        
    }
    
    // Buttons
    @IBAction func addImageButtonPressed(_ sender: UIButton) {
        getImage(fromSourceType: .photoLibrary)
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        
        if recipeImageView?.image == nil {
            recipeImageView?.image = UIImage(named: "noImage")
        }
        
        uploadToFirestoreStorage()
    }
    
    // Metod som lägger 'placeholder' i mina textViews
    func addPlaceholderInTextview() {
        
        recipeNameTextView.text = "Namn på recept"
        ingredientsTextView.text = "Vilka ingredienser behövs"
        instructionsTextView.text = "Instruktioner för receptet"
        
        recipeNameTextView.textColor = UIColor.lightGray
        ingredientsTextView.textColor = UIColor.lightGray
        instructionsTextView.textColor = UIColor.lightGray
    }
    
    // När användaren går in i en textview ändrar vi färgen till svart och tar bort placeholder texten
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        textView.text = nil
        textView.textColor = UIColor.black
    }
    
    // Om användaren går ut ur textviewn utan att skrivit något i den så lägger vi på placeholder texten igen
    func textViewDidEndEditing(_ textView: UITextView) {
     
        if textView == recipeNameTextView {
            if recipeNameTextView.text.isEmpty {
                recipeNameTextView.text = "Namn på recept"
                recipeNameTextView.textColor = UIColor.lightGray
            }
        } else if textView == ingredientsTextView {
            if ingredientsTextView.text.isEmpty {
                ingredientsTextView.text = "Vilka ingredienser behövs"
                ingredientsTextView.textColor = UIColor.lightGray
            }
        } else if textView == instructionsTextView {
            if instructionsTextView.text.isEmpty {
                instructionsTextView.text = "Instruktioner för receptet"
                instructionsTextView.textColor = UIColor.lightGray
            }
        }
    }
    
    
    
    // Metod som öppnar upp fotoalbum/kamera beroende på vilken sourcetype vi väljer som parameter
    func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self 
        picker.allowsEditing = true
        
        self.present(picker, animated: true, completion: nil)
    }
    
    // Metod som skapar TapGestureRecogniser, så keyboard försvinner vid tryck på vyn
    func setupKeyboardDismissRecognizer() {
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(AddRecipeViewController.dismissKeyboard))
        
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // Metod som skapar en ram runt textview
    func addBorderToTextViews() {
        
        recipeNameTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        recipeNameTextView.layer.borderWidth = 1.0
        recipeNameTextView.layer.cornerRadius = 5
        
        ingredientsTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        ingredientsTextView.layer.borderWidth = 1.0
        ingredientsTextView.layer.cornerRadius = 5
        
        instructionsTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        instructionsTextView.layer.borderWidth = 1.0
        instructionsTextView.layer.cornerRadius = 5
    }
    
    
    // MEtod som sparar data till firebase
    func addDataToFirebase() {

        name = recipeNameTextView.text
        ingredients = ingredientsTextView.text
        instructions = instructionsTextView.text
        
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
        
        // Kollar om användaren har tryckt på switch för hemligt recept
        if secretRecipeSwitch.isOn {
            ref.child("AllCookBooks").child(userId!).child("aCookBookName").childByAutoId().setValue(newPrivateRecipe)
        } else {
            ref.child("publicRecipes").child("recipesByUsers").childByAutoId().setValue(newPublicRecipe)
            ref.child("AllCookBooks").child(userId!).child("aCookBookName").childByAutoId().setValue(newPrivateRecipe)
        }
        
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
            recipeImageView?.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // Metod som sparar data till Firebase
    func uploadToFirestoreStorage() {
        
        let storage = self.storage.reference()
        
        let storageRef = storage.child("recipesImages/\(userId!)/\(recipeNameTextView.text!).png")
        
        let resizedImage = resizeImage(image: recipeImageView?.image ?? UIImage(named: "receptBok")!, targetSize: CGSize.init(width: 500, height: 500))
        
        let uploadData = resizedImage
        
        SVProgressHUD.show(withStatus: "Ditt recept sparas..")
       
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
                            SVProgressHUD.dismiss()
                        }
                    }
                }
            }
        }
    }
    
    // Metod som tar en bild och och komprimerar den vald storlek
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
