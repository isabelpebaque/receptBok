//
//  ReceipeModel.swift
//  ReceptBok
//
//  Created by Isabel Pebaqué on 2019-03-13.
//  Copyright © 2019 Isabel Pebaqué. All rights reserved.
//

import Foundation
import UIKit

class ReceipeModel {
    // Variabler för varje objekt
    var receipeName: String?
    var ingredients: String?
    var howTo: String?
    var image: UIImage?
    var pageNr : Int?
    
    
    // Konstruktor för användarens egna ReceipeModel
    init(receipeName: String?, ingredients: String?, howTo: String?, pageNr : Int?, image: UIImage?) {
        self.receipeName = receipeName
        self.ingredients = ingredients
        self.howTo = howTo
        self.pageNr = pageNr
        self.image = image
    }
    
    //Konstruktor för sökfältets ReceipeModel
    init(receipeName: String?, ingredients: String?, howTo: String?, image : UIImage!) {
        self.receipeName = receipeName
        self.ingredients = ingredients
        self.howTo = howTo
        self.image = image
    }
}
