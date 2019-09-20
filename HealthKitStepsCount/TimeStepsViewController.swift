//
//  TimeStepsViewController.swift
//  HealthKitStepsCount
//
//  Created by 이지건 on 20/09/2019.
//  Copyright © 2019 이지건. All rights reserved.
//

import Foundation
import UIKit

class TimeStepsViewController: UIViewController {
    
    @IBOutlet weak var stepsTableView: UITableView!
    
    var items: [(String, Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepsTableView.dataSource = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stepsTableView.reloadData()
    }
}

extension TimeStepsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepsInDateTableViewCell") as! StepsInDateTableViewCell
        
        cell.dateLabel.text = item.0
        cell.countLabel.text = "\(item.1)"
        cell.selectionStyle = .none
        return cell
    }
}
