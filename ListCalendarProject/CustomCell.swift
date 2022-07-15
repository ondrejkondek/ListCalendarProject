//
//  CuustomCell.swift
//  JTAppleCalendarDemo
//
//  Created by Ondrej Kondek on 16/11/2021.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
