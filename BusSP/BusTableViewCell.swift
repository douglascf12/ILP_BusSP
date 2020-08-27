//
//  BusTableViewCell.swift
//  BusSP
//
//  Created by Douglas Cardoso Ferreira on 17/07/20.
//  Copyright © 2020 Douglas Cardoso. All rights reserved.
//

import UIKit

class BusTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbCarPrefix: UILabel!
    @IBOutlet weak var lbNameLine: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
