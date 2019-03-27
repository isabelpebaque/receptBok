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
    
    static let shared = DataManager()
    var recipesArray = [ReceipeModel]()
    
    var ref : DatabaseReference!
    let userId = Auth.auth().currentUser?.uid
    let storage = Storage.storage()
    
    var amountOfPages = 0
    
    
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
    
    func getDataFromFirebaseFirstTime() {
        self.ref = Database.database().reference().child("AllCookBooks").child(self.userId!).child("aCookBookName")
        
        
        
        if self.recipesArray.count == 0 {
            
        self.ref.observeSingleEvent(of: .value) { (snapshot) in
                
                guard let snapshotValue = snapshot.value as? [String : Any] else {return}
                
                for case let recipe as [String:String] in snapshotValue.values{
                    let name = recipe["recipeName"]!
                    let ingredient = recipe["ingredients"]!
                    let howTo = recipe["instructions"]!
                    let image = recipe["recipeImage"]! // URL
                    
                    // KOMMENTAR FRÅN HANDLEDARE - Du bör hämta bilder endast när de skall visas
                    
                    self.amountOfPages += 1
                    
                    let recipePage = ReceipeModel(receipeName: name, ingredients: ingredient, howTo: howTo, pageNr: self.amountOfPages ,
                        imageUrlPath: image)
                    
                    
                    self.recipesArray.append(recipePage)
                    self.getImageForRecipe(recipeImage: image, recipe: recipePage)
                    
                }
                
                NotificationCenter.default.post(name: Notification.Name("dataFetched"), object: nil)
                
            }
       
            
 
        } else {
            
            self.ref.observe(.childAdded) { (snapshot) in
                
                let snapshotValue = snapshot.value as! [String : AnyObject]
                
                    let name = snapshotValue["recipeName"]! as? String
                    let ingredient = snapshotValue["ingredients"]! as? String
                    let howTo = snapshotValue["instructions"]! as? String
                    let image = snapshotValue["recipeImage"]! as? String
                    
                    // KOMMENTAR FRÅN HANDLEDARE - Du bör hämta bilder endast när de skall visas
                    
                    self.amountOfPages += 1
                
                let recipePage = ReceipeModel(receipeName: name, ingredients: ingredient, howTo: howTo, pageNr: self.amountOfPages ,
                                              imageUrlPath: image)
                
                    
                    //lägger till objektet i array
                    self.recipesArray.append(recipePage)
                    self.getImageForRecipe(recipeImage: image ?? "", recipe: recipePage)
                    print("ChildAdded observern har lagt till receptet")
                    
                
                NotificationCenter.default.post(name: Notification.Name("dataFetched"), object: nil)
                
            }
            ref.removeAllObservers()
        }
       
        
        
    }

    
}
