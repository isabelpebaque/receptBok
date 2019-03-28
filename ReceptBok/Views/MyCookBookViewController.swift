//
//  MyCookBookViewController.swift
//  ReceptBok
//
//  Created by Isabel Pebaqué on 2019-03-11.
//  Copyright © 2019 Isabel Pebaqué. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class MyCookBookViewController: UIViewController {
    //Kopplingar till Firebase/userDefaults
    let ref = Database.database().reference()
    let userdef = UserDefaults.standard
    
    // Outlets skapade från storyboard
    
    @IBOutlet weak var myCookBookNameTV: UITextView!
    @IBOutlet weak var myCookBookImageView: UIImageView!
    @IBOutlet weak var createCookBook: UIButton!
   

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromFirebase()
        
        if userdef.bool(forKey: "createdCookBook") {
            createCookBook.isHidden = true
        }
        
    }
    
    // När man trycker på knappen gömmer vi createCookBook knapp och sparar detta i userDefaults
    @IBAction func createCookBookButtonPressed(_ sender: UIButton) {
        createCookBook.isHidden = true
        self.userdef.set(true, forKey: "createdCookBook")
    }
    
    // Loggar ut användaren från firebase Auth
    @IBAction func signOutButtonPressed(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            self.userdef.set(false, forKey: "UserIsSignedIn")
            self.userdef.synchronize()
            openSignInView()
        }
        catch let error as NSError {
            print (error.localizedDescription)
        }
        
    }
    
    // Metod som öppnar första inloggningsfönstret
    func openSignInView(){
        
        let signInView = self.storyboard!.instantiateViewController(withIdentifier: "firstViewController")
        self.present(signInView, animated: true, completion: nil)
        
    }
    
    // Mark: - Get data from Firebase
    
    fileprivate func getDataFromFirebase() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let userID = currentUser.uid
        
        // Hämtar datan från Firebase och setter värdet i vår label
        ref.child("AllCookBooks").child(userID).child("name").observe(.value) { (snapshot) in
            
            if let name = snapshot.value as? String {
                self.myCookBookNameTV.text = name
            }
        }

    }


}
