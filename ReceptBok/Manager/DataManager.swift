//
//  DataManager.swift
//  ReceptBok
//
//  Created by Isabel Pebaqué on 2019-03-27.
//  Copyright © 2019 Isabel Pebaqué. All rights reserved.
//

import UIKit
import Firebase


class DataManager: NSObject {
    
    // öppen singelton variabel för DataManger-klassen som alla andra klasser kan komma åt
    static let shared = DataManager()
    //Arrayer att spara receptobjekten i från firebase
    var privateRecipesArray = [ReceipeModel]()
    var publicRecipesArray = [ReceipeModel]()
    
    // Referans variabler från firebase
    var ref : DatabaseReference!
    let userId = Auth.auth().currentUser?.uid
    let storage = Storage.storage()
    
    // Variabel för att hålla kolla på antal objekt (Används till att sätta sidonummer)
    var amountOfPages = 0
    
    // Metod som laddar ner bilderna från storage och in i objektet
    func getImageForRecipe(recipeImage: String, recipe: ReceipeModel) { // Skapa ett completion block
        
        let pathReference = self.storage.reference(forURL: recipeImage)
        
        pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("hittar ingen bild")
                print(error.localizedDescription)
            } else {
                let downloadedImage = UIImage(data: data!)!
                print("bilden är hittad")
                recipe.image = downloadedImage
                
                NotificationCenter.default.post(name: Notification.Name("imageFetched"), object: nil) // Uppdatera vyn i din view controller så att bilden visas!
            }
        }
    }
    
    
    // Mark: - Get data from Firebase
    // Metod som hämtar data från firabse till användarens egna receptbok
    func getDataFromFirebasePrivateRecipes() {
        self.ref = Database.database().reference().child("AllCookBooks").child(self.userId!).child("aCookBookName")
        
        self.ref.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! [String : AnyObject]
            
            let name = snapshotValue["recipeName"] as? String ?? "no info"
            let ingredient = snapshotValue["ingredients"] as? String ?? "no info"
            let howTo = snapshotValue["instructions"] as? String ?? "no info"
            let image = snapshotValue["recipeImage"] as? String ?? "no info"
            
            
            self.amountOfPages += 1
            
            let recipePage = ReceipeModel(receipeName: name, ingredients: ingredient, howTo: howTo, pageNr: self.amountOfPages ,
                                          imageUrlPath: image)
            
            self.privateRecipesArray.append(recipePage)
            self.getImageForRecipe(recipeImage: image , recipe: recipePage)
            print("ChildAdded observern har lagt till receptet")
            
            
            NotificationCenter.default.post(name: Notification.Name("dataFetched"), object: nil)
            
        }
    }
    
    // Metod som hämtar data från firabse till publika search tableView
    func getDataFromFirebasePublicRecipes() {
        self.ref = Database.database().reference().child("publicRecipes").child("recipesByUsers")
        
        self.ref.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! [String : AnyObject]
            
            let name = snapshotValue["name"] as? String ?? "no info"
            let ingredient = snapshotValue["ingredients"] as? String ?? "no info"
            let howTo = snapshotValue["instructions"] as? String ?? "no info"
            let image = snapshotValue["recipeImage"] as? String ?? "no info"
            
            
            let recipePage = ReceipeModel(receipeName: name, ingredients: ingredient, howTo: howTo, imageUrlPath: image)
            
            self.publicRecipesArray.append(recipePage)
            self.getImageForRecipe(recipeImage: image , recipe: recipePage)
            print("ChildAdded observern har lagt till receptet")
            
            
            NotificationCenter.default.post(name: Notification.Name("PublicDataFetched"), object: nil)
            
        }
    }


    
}
