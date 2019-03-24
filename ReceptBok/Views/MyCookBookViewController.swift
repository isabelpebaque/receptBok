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
    //Kopplingar till Firebase/Firebase Auth
    let ref = Database.database().reference()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userdef = UserDefaults.standard
    
    // Outlets skapade från storyboard
    @IBOutlet weak var myCookBookNameLabel: UILabel!
    @IBOutlet weak var myCookBookImageView: UIImageView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        getDataFromFirebase()
        downloadImageFromFirebaseStorage()
    }
    
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
        
        if let signInView = (self.storyboard!.instantiateViewController(withIdentifier: "firstViewController") as? UIViewController) {
            self.present(signInView, animated: true, completion: nil)
        }
    }
    
    // Mark: - Get data from Firebase
    
    fileprivate func getDataFromFirebase() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let userID = currentUser.uid
        
        // Hämtar datan från Firebase och setter värdet i vår label
        ref.child("AllCookBooks").child(userID).child("name").observe(.value) { (snapshot) in
            
            if let name = snapshot.value as? String {
                self.myCookBookNameLabel.text = name
            }
        }

    }
    
    func downloadImageFromFirebaseStorage() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let userID = currentUser.uid
        
        let storage = Storage.storage()
        let pathReference = storage.reference(withPath: "cookBookCoverImages/\(userID).png")
        
        pathReference.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
//                let image = #imageLiteral(resourceName: "Profile Avatar Picture")
//                self.appDelegate.cookBookImage = image
                print("hittar ingen bild")
                print(error.localizedDescription)
            } else {
                print("bilden är hittad")
                self.appDelegate.cookBookImage = UIImage(data: data!)!
                self.myCookBookImageView.image = self.appDelegate.cookBookImage
            }
        }
        
    }

}
