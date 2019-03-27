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
        
        DataManager.shared.getDataFromFirebaseFirstTime()
        
        if tableView.indexPathForSelectedRow != nil {
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateViewOnNotification), name: Notification.Name("dataFetched"), object: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func updateViewOnNotification() {
        self.tableView.reloadData()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.recipesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "indexCell", for: indexPath) as! IndexTableViewCell
        
        var recipe : ReceipeModel
        
        recipe = DataManager.shared.recipesArray[indexPath.row]
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
            destination.namePassedOver = DataManager.shared.recipesArray[index!].receipeName
            destination.ingredientPassedOver = DataManager.shared.recipesArray[index!].ingredients
            destination.instructionPassedOver = DataManager.shared.recipesArray[index!].howTo
            destination.pageNrPassedOver = DataManager.shared.recipesArray[index!].pageNr
            destination.imagePassedOver = DataManager.shared.recipesArray[index!].image
            
            // Kollar så vi har någon data att föra över
            print("myIndexTableViewController will pass over: ")
            print(DataManager.shared.recipesArray[index!].receipeName!)
            
        }
    }
 

}
