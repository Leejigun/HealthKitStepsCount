//
//  StepsInDateTableViewCell.swift
//  HealthKitStepsCount
//
//  Created by 이지건 on 20/09/2019.
//  Copyright © 2019 이지건. All rights reserved.
//

import UIKit

class StepsInDateTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commomInit()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        commomInit()
    }
    
    private func commomInit() {
        dateLabel.text = nil
        countLabel.text = nil
    }
}
