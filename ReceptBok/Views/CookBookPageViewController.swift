//
//  CookBookPageViewController.swift
//  ReceptBok
//
//  Created by Isabel Pebaqué on 2019-03-11.
//  Copyright © 2019 Isabel Pebaqué. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class CookBookPageViewController: UIViewController {
    var ref : DatabaseReference!
    var userId = Auth.auth().currentUser?.uid
    let storage = Storage.storage()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var namePassedOver : String?
    var ingredientPassedOver : String?
    var instructionPassedOver : String?
    var pageNrPassedOver : Int?
    var imagePassedOver : String?
    
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var instructionsTextView: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
       
        downloadImageFromFirebaseStorage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Sätter labels och textViews med datan skickad från segue
        recipeNameLabel.text = namePassedOver
        ingredientsTextView.text = ingredientPassedOver
        instructionsTextView.text = instructionPassedOver
       // photoImageView.image = imagePassedOver
        
        
        // Data skickat från sök tableView skal ha titel 'delade recept', data skickat från myIndex tableView skal sidanummer stå
        if pageNrPassedOver != nil {
            navigationItem.title = "Sida \(String(describing: pageNrPassedOver!))"
        } else {
            navigationItem.title = "Delade recept"
        }
        
        // Kollar så vi har data från segue
        print("CookBookPageViewController got this from passed over data: ")
        print(namePassedOver!)
    }
    
    func downloadImageFromFirebaseStorage() {
        
        let pathReference = storage.reference(forURL: (imagePassedOver!))
        
        pathReference.downloadURL { (url, error) in
            if let error = error {
                print("hittar ingen bild")
                print(error.localizedDescription)
            } else {
                let data = NSData(contentsOf: url!)
                self.photoImageView.image = UIImage(data: data! as Data)!
                print("Bild hittad!")
            }
        }
        
    }
   

}
