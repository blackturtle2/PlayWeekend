//
//  SearchLocationTableViewCell.swift
//  PlayWeekendProject
//
//  Created by leejaesung on 2017. 11. 2..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class SearchLocationTableViewCell: UITableViewCell {
    
    var city = cityClass(name: "서울특별시", latitude: "37.56667", longitude: "126.97806")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
