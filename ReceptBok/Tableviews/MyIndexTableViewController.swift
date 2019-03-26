//
//  MyIndexTableViewController.swift
//  ReceptBok
//
//  Created by Isabel Pebaqué on 2019-03-14.
//  Copyright © 2019 Isabel Pebaqué. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class MyIndexTableViewController: UITableViewController {
    // Array av receipeModel objekt, som vi sparar vår data från firebase i
    var amountOfRecipesArray = [ReceipeModel]()
    // Referenser till Firebase/Firebase Auth
    var ref : DatabaseReference!
    var refHandle : DatabaseHandle!
    var userId = Auth.auth().currentUser?.uid
    let storage = Storage.storage()
    
    override func viewWillAppear(_ animated: Bool) {
        getDataFromFirebase()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    // Mark: - Get data from Firebase
    
    fileprivate func getDataFromFirebase() {
        ref = Database.database().reference().child("AllCookBooks").child(userId!).child("aCookBookName")
        var downloadedImage = UIImage()
        // Variabel som håller koll hur många recept som hämtas från firebase som vi sedan använder som sidonummer
        var amountOfPages = 0
        
        // Rensar listan så vi inte får dubbla recept i tableviewn
        self.amountOfRecipesArray.removeAll()
        
        refHandle = ref.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! [String : AnyObject]
            
            let name = snapshotValue["recipeName"]!
            let ingredient = snapshotValue["ingredients"]!
            let howTo = snapshotValue["instructions"]!
            let image = snapshotValue["recipeImage"]!
            
            let pathReference = self.storage.reference(forURL: image as! String)
            
            pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("hittar ingen bild")
                    print(error.localizedDescription)
                } else {
                    downloadedImage = UIImage(data: data!)!
                    print("bilden är hittad")
                    amountOfPages += 1
                    // skapar ett objekt med konstruktor från ReceipeModel
                    let recipePage = ReceipeModel(receipeName: name as? String, ingredients: ingredient as? String, howTo: howTo as? String, pageNr: amountOfPages, image: downloadedImage )
                    
                    //lägger till objektet i array
                    self.amountOfRecipesArray.append(recipePage)
                    
                    // Uppdaterar tableview:n med data
                    self.tableView.reloadData()

                }
            }
        }
        //ref.removeObserver(withHandle: refHandle)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return amountOfRecipesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "indexCell", for: indexPath) as! IndexTableViewCell
        
        var recipe : ReceipeModel
        
        recipe = amountOfRecipesArray[indexPath.row]
        cell.recipeNameLabel.text = recipe.receipeName
        cell.pageNrLabel.text = "\(String(describing: recipe.pageNr!))"

        return cell
    }
 
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Kollar så vi har rätt segueway
        if  segue.identifier == "segueToFullRecipe" {
            // Sätter CookBookPageViewController som vår destination
            let destination = segue.destination as! CookBookPageViewController
            // Sparar vilket objekt det gäller i en variabel
            let index = tableView.indexPathForSelectedRow?.row
            
            // Tar ut namn, ingredienser, instruktioner och sidonummer från objektet och för över det till destinations ViewController
            destination.namePassedOver = self.amountOfRecipesArray[index!].receipeName
            destination.ingredientPassedOver = self.amountOfRecipesArray[index!].ingredients
            destination.instructionPassedOver = self.amountOfRecipesArray[index!].howTo
            destination.pageNrPassedOver = self.amountOfRecipesArray[index!].pageNr
            destination.imagePassedOver = self.amountOfRecipesArray[index!].image
            
            // Kollar så vi har någon data att föra över
            print("myIndexTableViewController will pass over: ")
            print(self.amountOfRecipesArray[index!].receipeName!)
            
        }
    }
 

}
