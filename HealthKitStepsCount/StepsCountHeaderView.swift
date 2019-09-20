//
//  StepsCountHeaderView.swift
//  HealthKitStepsCount
//
//  Created by 이지건 on 20/09/2019.
//  Copyright © 2019 이지건. All rights reserved.
//

import Foundation
import UIKit

class StepsCountHeaderView: UIView {

    @IBOutlet weak var startDate: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    
    @IBAction func search(_ sender: Any) {
        
    }
    
    @IBAction func onTapStart(_ sender: Any) {
        print("start")
    }
}

//extension StepsCountHeaderView {
//    func doDatePicker(){
//        // DatePicker
//        // datePicker = UIDatePicker()
//        
//        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: self.view.frame.size.height - 220, width:self.view.frame.size.width, height: 216))
//        self.datePicker.backgroundColor = UIColor.white
//        datePicker.datePickerMode = .date
//        
//        // ToolBar
//        
//        toolBar.barStyle = .default
//        toolBar.isTranslucent = true
//        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
//        toolBar.sizeToFit()
//        
//        // Adding Button ToolBar
//        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ViewController.doneClick))
//        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(ViewController.cancelClick))
//        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
//        toolBar.isUserInteractionEnabled = true
//        
//        self.toolBar.isHidden = false
//    }
//    
//    
//    @objc func doneClick() {
//        let dateFormatter1 = DateFormatter()
//        dateFormatter1.dateStyle = .medium
//        dateFormatter1.timeStyle = .none
//        
//        datePicker.isHidden = true
//        self.toolBar.isHidden = true
//    }
//    
//    @objc func cancelClick() {
//        datePicker.isHidden = true
//        self.toolBar.isHidden = true
//    }
//}
