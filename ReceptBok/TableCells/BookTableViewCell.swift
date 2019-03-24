//
//  BookTableViewCell.swift
//  ReceptBok
//
//  Created by Isabel Pebaqué on 2019-03-13.
//  Copyright © 2019 Isabel Pebaqué. All rights reserved.
//

import Foundation
import UIKit

class BookTableViewCell: UITableViewCell {
    
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var bookCoverImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}
