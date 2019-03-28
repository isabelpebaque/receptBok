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
        
        // Kollar så arrayen är tom för att hämta ner alla info från firebase första gången
        if self.privateRecipesArray.count == 0 {
            
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
                    
                    
                    self.privateRecipesArray.append(recipePage)
                    self.getImageForRecipe(recipeImage: image, recipe: recipePage)
                    
                }
                // Notis om att alla objekt från firebase har blivit hämtade
                NotificationCenter.default.post(name: Notification.Name("dataFetched"), object: nil)
                
            }
        } else {
            // Om arrayen inte är tom hämtas bara nya objekt
            self.ref.observe(.childAdded) { (snapshot) in
                
                let snapshotValue = snapshot.value as! [String : AnyObject]
                
                let name = snapshotValue["recipeName"]! as? String
                let ingredient = snapshotValue["ingredients"]! as? String
                let howTo = snapshotValue["instructions"]! as? String
                let image = snapshotValue["recipeImage"]! as? String
                
                
                self.amountOfPages += 1
                
                let recipePage = ReceipeModel(receipeName: name, ingredients: ingredient, howTo: howTo, pageNr: self.amountOfPages ,
                                              imageUrlPath: image)
                
                self.privateRecipesArray.append(recipePage)
                self.getImageForRecipe(recipeImage: image ?? "", recipe: recipePage)
                print("ChildAdded observern har lagt till receptet")
                
                
                NotificationCenter.default.post(name: Notification.Name("dataFetched"), object: nil)
                
            }
            ref.removeAllObservers()
        }
    }
    
    // Metod som hämtar data från firabse till publika search tableView
    func getDataFromFirebasePublicRecipes() {
        self.ref = Database.database().reference().child("publicRecipes").child("recipesByUsers")
        
        if self.publicRecipesArray.count == 0 {
            
            self.ref.observeSingleEvent(of: .value) { (snapshot) in
                
                guard let snapshotValue = snapshot.value as? [String : Any] else {return}
                
                for case let recipe as [String:String] in snapshotValue.values{
                    let name = recipe["name"]!
                    let ingredient = recipe["ingredients"]!
                    let howTo = recipe["instructions"]!
                    let image = recipe["recipeImage"]! // URL
                    
                    let recipePage = ReceipeModel(receipeName: name, ingredients: ingredient, howTo: howTo, imageUrlPath: image)
                    
                    print("första nedladdningen gjord")
                    self.publicRecipesArray.append(recipePage)
                    self.getImageForRecipe(recipeImage: image, recipe: recipePage)
                    
                }
                
                NotificationCenter.default.post(name: Notification.Name("PublicDataFetched"), object: nil)
                
            }
        } else {
            
            self.ref.observe(.childAdded) { (snapshot) in
                
                let snapshotValue = snapshot.value as! [String : AnyObject]
                
                let name = snapshotValue["recipeName"]! as? String
                let ingredient = snapshotValue["ingredients"]! as? String
                let howTo = snapshotValue["instructions"]! as? String
                let image = snapshotValue["recipeImage"]! as? String
                
                
                let recipePage = ReceipeModel(receipeName: name, ingredients: ingredient, howTo: howTo, imageUrlPath: image)
                
                self.publicRecipesArray.append(recipePage)
                self.getImageForRecipe(recipeImage: image ?? "", recipe: recipePage)
                print("ChildAdded observern har lagt till receptet")
                
                
                NotificationCenter.default.post(name: Notification.Name("PublicDataFetched"), object: nil)
                
            }
            ref.removeAllObservers()
        }
    }


    
}
