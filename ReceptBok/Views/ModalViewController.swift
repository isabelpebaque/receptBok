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
    @IBOutlet weak var newNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardDismissRecognizer()
    }
    
    // Action skapad från storyboard, vid tryck sparar vi data från våra outlets till Firebase
    @IBAction func saveNewNameBtnPressed(_ sender: UIButton) {
        addDataToFirebase()
        
    }
    
    // Lägger till data till firebase
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

}
