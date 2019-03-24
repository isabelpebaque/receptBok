//
//  ModalViewController.swift
//  ReceptBok
//
//  Created by Isabel Pebaqué on 2019-03-08.
//  Copyright © 2019 Isabel Pebaqué. All rights reserved.
//

import UIKit
import Firebase

class ModalViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Referenser till Firebase/Firebase Auth
    let ref = Database.database().reference()
    let storage = Storage.storage()
    
    // Outlets kopplade från storyboard
    @IBOutlet weak var newImageImgView: UIImageView!
    @IBOutlet weak var newNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardDismissRecognizer()
    }
    
    // Action skapad från storyboard, vid tryck öppnar vi fotoalbumet i telefonen
    @IBAction func chooseImageBtn(_ sender: UIButton) {
        getImage(fromSourceType: .photoLibrary)
    }
    
    // Action skapad från storyboard, vid tryck sparar vi data från våra outlets till Firebase
    @IBAction func saveNewNameBtnPressed(_ sender: UIButton) {
        addDataToFirebase()
        uploadToFirestoreStorage()
    }
    
    func addDataToFirebase() {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        let userID = currentUser.uid
        let name = newNameTextField.text
        
        ref.child("AllCookBooks").child(userID).child("name").setValue(name)
        
        dismiss(animated: true, completion: nil)
    }
    
    // Metod som skapar TapGestureRecogniser, så keyboard försvinner vid tryck på vyn
    func setupKeyboardDismissRecognizer(){
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(ModalViewController.dismissKeyboard))
        
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    // Metod som öppnar upp fotoalbum/kamera beroende på vilken sourcetype vi väljer som parameter
    func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        self.present(picker, animated: true, completion: nil)
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
            newImageImgView.image = selectedImage
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func uploadToFirestoreStorage() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let userID = currentUser.uid
        
        let storageRef = storage.reference().child("cookBookCoverImages/\(userID).png")
        
        let uploadData = newImageImgView.image
        if let imageData = uploadData?.pngData() {
            
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print(error!)
                } else {
                    print(metadata!)
                }
            }
        }
        
    }
    
    // Metod som avslutar val av bild vid tryck på cancelknapp
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
