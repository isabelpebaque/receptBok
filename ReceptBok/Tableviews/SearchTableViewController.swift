//
//  SearchTableViewController.swift
//  ReceptBok
//
//  Created by Isabel Pebaqué on 2019-03-08.
//  Copyright © 2019 Isabel Pebaqué. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    // Array av receipeModel objekt, som vi sparar vår data från firebase i
    var recipesArray = [ReceipeModel]()
    var recipeSearchArray = [ReceipeModel]()
    
    // Referenser till Firebase/Firebase Auth
    var ref : DatabaseReference!
    let userId = Auth.auth().currentUser?.uid
    let storage = Storage.storage()
    var recipeNameForImagePath = ""
    
    @IBOutlet weak var findRecipesSearchBar: UISearchBar!
    
    override func viewWillAppear(_ animated: Bool) {
        getDataFromFirebase()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // Mark: - Get data from Firebase
    
    fileprivate func getDataFromFirebase() {
        ref = Database.database().reference().child("publicRecipes")
        var downloadedImage = UIImage()
        
        
        ref.observe(.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                // Rensar listan så vi inte får dubbla recept i tableviewn
                self.recipesArray.removeAll()
                self.recipeSearchArray.removeAll()
                
                for recipe in snapshot.children.allObjects as! [DataSnapshot] {
                    // hämtar värden från firebase med nyckelar och sätter dem i variabelns namn
                    let recipeObject = recipe.value as? [String: AnyObject]
                    let recipeName = recipeObject?["name"]
                    let ingredient = recipeObject?["ingredients"]
                    let howTo = recipeObject?["instructions"]
                    let image = recipeObject?["recipeImage"]
                    
                    let pathReference = self.storage.reference(forURL: image as! String)
                    
                    pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print("hittar ingen bild")
                            print(error.localizedDescription)
                        } else {
                            downloadedImage = UIImage(data: data!)!
                            print("bilden är hittad")
                            
                            // skapar ett objekt med konstruktor från ReceipeModel
                            let publicRecipe = ReceipeModel(receipeName: (recipeName as! String), ingredients: (ingredient as! String), howTo: (howTo as! String), image: downloadedImage)
                            
                            //lägger till objectet i array
                            self.recipesArray.append(publicRecipe)
                            self.recipeSearchArray = self.recipesArray
                            
                            // Uppdaterar tableview:n med data
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeSearchArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BookTableViewCell
        

        let recipe : ReceipeModel
        recipe = recipeSearchArray[indexPath.row]
        
        cell.recipeNameLabel.text = recipe.receipeName
        cell.bookCoverImage.image = recipe.image
        
        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Kollar så vi har rätt segueway
        if  segue.identifier == "searchSegueToFullRecipe" {
            // Sätter CookBookPageViewController som vår destination
            let destination = segue.destination as! CookBookPageViewController
            
            // Sparar vilken plats i arrayen vi skal hämta data
            let index = tableView.indexPathForSelectedRow?.row
            
            // Tar bort keyboard från vyn och tömmer searchbaren från bokstäver
            findRecipesSearchBar.endEditing(true)
            findRecipesSearchBar.text = ""
            
            // Tar ut namn, ingredienser, instruktioner och sidonummer från objektet och för över det till destinations ViewController
            destination.namePassedOver = self.recipeSearchArray[index!].receipeName
            destination.ingredientPassedOver = self.recipeSearchArray[index!].ingredients
            destination.instructionPassedOver = self.recipeSearchArray[index!].howTo
            destination.imagePassedOver = self.recipeSearchArray[index!].image
            
            // Kollar så vi har någon data att föra över
            print("mySearchTableViewController will pass over: ")
            print(self.recipeSearchArray[index!].receipeName ?? "ingen information att hämta")
            
        }
    }
    
    // MARK: - Searchfunction
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            recipeSearchArray = recipesArray;
            tableView.reloadData()
            return
            
        }
        recipeSearchArray = recipesArray.filter({ (recipe) -> Bool in
            return (recipe.receipeName?.lowercased().contains(searchText.lowercased()))!
        })
        tableView.reloadData()
    }
    
}
