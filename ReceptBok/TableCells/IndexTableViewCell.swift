//
//  IndexTableViewCell.swift
//  ReceptBok
//
//  Created by Isabel Pebaqué on 2019-03-14.
//  Copyright © 2019 Isabel Pebaqué. All rights reserved.
//

import UIKit

class IndexTableViewCell: UITableViewCell {

    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var pageNrLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
