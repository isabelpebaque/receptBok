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
    
    @IBOutlet weak var findRecipesSearchBar: UISearchBar!
    
    override func viewWillAppear(_ animated: Bool) {
       
        DataManager.shared.getDataFromFirebasePublicRecipes()
        
        if tableView.indexPathForSelectedRow != nil {
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateViewOnNotification), name: Notification.Name("PublicDataFetched"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateViewOnNotification), name: Notification.Name("imageFetched"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @objc func updateViewOnNotification() {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.publicRecipesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BookTableViewCell
        

        let recipe : ReceipeModel
        recipe = DataManager.shared.publicRecipesArray[indexPath.row]
        
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
            
       /*     // Tar bort keyboard från vyn och tömmer searchbaren från bokstäver
            findRecipesSearchBar.endEditing(true)
            findRecipesSearchBar.text = "" */
            
            // Tar ut namn, ingredienser, instruktioner och sidonummer från objektet och för över det till destinations ViewController
            destination.namePassedOver = DataManager.shared.publicRecipesArray[index!].receipeName
            destination.ingredientPassedOver = DataManager.shared.publicRecipesArray[index!].ingredients
            destination.instructionPassedOver = DataManager.shared.publicRecipesArray[index!].howTo
            destination.imagePassedOver = DataManager.shared.publicRecipesArray[index!].image
            
            // Kollar så vi har någon data att föra över
            print("mySearchTableViewController will pass over: ")
            print(DataManager.shared.publicRecipesArray[index!].receipeName ?? "ingen information att hämta")
            
        }
    }
    
    // MARK: - Searchfunction
    
 /*   func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            recipeSearchArray = recipesArray;
            tableView.reloadData()
            return

        }
        recipeSearchArray = recipesArray.filter({ (recipe) -> Bool in
            return (recipe.receipeName?.lowercased().contains(searchText.lowercased()))!
        })
        tableView.reloadData()
    } */
    
}
