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
    
    override func viewWillAppear(_ animated: Bool) {
        
        DataManager.shared.getDataFromFirebasePrivateRecipes()
        
        if tableView.indexPathForSelectedRow != nil {
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateViewOnNotification), name: Notification.Name("dataFetched"), object: nil)
        
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
        return DataManager.shared.privateRecipesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "indexCell", for: indexPath) as! IndexTableViewCell
        
        var recipe : ReceipeModel
        
        recipe = DataManager.shared.privateRecipesArray[indexPath.row]
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
            destination.namePassedOver = DataManager.shared.privateRecipesArray[index!].receipeName
            destination.ingredientPassedOver = DataManager.shared.privateRecipesArray[index!].ingredients
            destination.instructionPassedOver = DataManager.shared.privateRecipesArray[index!].howTo
            destination.pageNrPassedOver = DataManager.shared.privateRecipesArray[index!].pageNr
            destination.imagePassedOver = DataManager.shared.privateRecipesArray[index!].image
            
            // Kollar så vi har någon data att föra över
            print("myIndexTableViewController will pass over: ")
            print(DataManager.shared.privateRecipesArray[index!].receipeName!)
            
        }
    }
 

}
