//
//  MainTourInfoTableViewCell.swift
//  PlayWeekendProject
//
//  Created by leejaesung on 2017. 11. 2..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class MainTourInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewRepresentativeTour: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelLocation: UILabel!
    
    var contentID: String?
    var contentTypeID: String?
    var title: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
