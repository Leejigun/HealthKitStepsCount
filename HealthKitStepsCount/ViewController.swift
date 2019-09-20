//
//  ViewController.swift
//  HealthKitStepsCount
//
//  Created by 이지건 on 02/09/2019.
//  Copyright © 2019 이지건. All rights reserved.
//

import UIKit
import HealthKit

protocol MainCountDelegate {
    func getCount(start: Date, end: Date)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var stepsCountTableView: UITableView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    
    var status: HKAuthorizationStatus = .notDetermined
    var items: [(Date,[(String, Int)])] = []
    var datePicker:UIDatePicker = UIDatePicker()
    let toolBar = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        stepsCountTableView.delegate = self
        stepsCountTableView.dataSource = self
        doDatePicker()
        [startDateTextField, endDateTextField].forEach { textField in
            textField?.inputView = self.datePicker
            textField?.inputAccessoryView = self.toolBar
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkPermission()
    }
    
    private func checkPermission() {
        
        HealthKitManager.sharedInstance.requestReadingPermission {[weak self] (error) in
            if let error = error {
                let alert = UIAlertController(title: "HK", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(.init(title: "확인", style: .cancel, handler: {(_) in
                    alert.dismiss(animated: true)
                }))
                self?.present(alert, animated: true)
            } else {
                self?.checkPermission()
            }
        }
    }
    @IBAction func onTapSearch(_ sender: Any) {
        guard let startDateString = startDateTextField.text, let startDate = dateFromString(startDateString) else {
            let alert = UIAlertController(title: "HK", message: "시작 시간을 입력해주세요", preferredStyle: .alert)
            alert.addAction(.init(title: "확인", style: .cancel, handler: { (_) in
                alert.dismiss(animated: true)
            }))
            self.present(alert, animated: true)
            return
        }
        guard let endDateString = endDateTextField.text, let endDate = dateFromString(endDateString) else {
            let alert = UIAlertController(title: "HK", message: "종료 시간을 입력해주세요", preferredStyle: .alert)
            alert.addAction(.init(title: "확인", style: .cancel, handler: { (_) in
                alert.dismiss(animated: true)
            }))
            self.present(alert, animated: true)
            return
        }
        
        getCount(start: startDate, end: endDate)
    }
}

extension ViewController: MainCountDelegate {
    func getCount(start: Date, end: Date) {
        HealthKitManager.sharedInstance.readStepCount(startDate: start,
                                                      endDate: end) {[weak self] (error, dateList) in
                                                        self?.items = dateList.sorted(by: { (lhs, rhs) -> Bool in
                                                            return lhs.0 < rhs.0
                                                        })
                                                        DispatchQueue.main.async {
                                                            self?.stepsCountTableView.reloadData()
                                                        }
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TimeStepsViewController") as! TimeStepsViewController
        vc.items = item.1.sorted(by: { (lhs, rhs) -> Bool in
            guard let lhsDate = dateWithHHFromString(lhs.0), let rhsDate = dateWithHHFromString(rhs.0) else {
                return true
            }
            return lhsDate < rhsDate
        })
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepsInDateTableViewCell") as! StepsInDateTableViewCell
        
        cell.dateLabel.text = stringFromDate(item.0)
        let intSum = item.1.reduce(0, { (sum, arg) -> Int in
            let (_, count) = arg
            return sum + count
        })
        cell.countLabel.text = "\(intSum)"
        return cell
    }
 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
}

extension ViewController {
    func doDatePicker() {
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: self.view.frame.size.height - 220, width:self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.datePickerMode = .date
        
        // ToolBar
        
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(ViewController.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        self.toolBar.isHidden = false
        
    }
    
    @objc func doneClick() {
        let seletedDate = datePicker.date
        [startDateTextField, endDateTextField].forEach { textField in
            if let textF = textField, textF.isFirstResponder {
                textF.text = stringFromDate(seletedDate)
            }
            textField?.resignFirstResponder()
        }
    }
    
    @objc func cancelClick() {
        [startDateTextField, endDateTextField].forEach { textField in
            textField?.resignFirstResponder()
        }
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let seletedDate = datePicker.date
        [startDateTextField, endDateTextField].forEach { textField in
            if let textF = textField, textF.isFirstResponder {
                textF.text = stringFromDate(seletedDate)
            }
        }
    }
    
    /// yyyy-MM-dd HH 형태의 String 으로 Date 생성
    private func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let gregorian = Calendar(identifier: .gregorian)
        dateFormatter.calendar = gregorian
        
        // 한국 설정
        dateFormatter.timeZone = .autoupdatingCurrent
        let locale = Locale(identifier: "ko_KR")
        dateFormatter.locale = locale
        
        return dateFormatter.date(from: dateString)
    }
    
    /// Date를 "yyyy-MM-dd HH" 형태로 수정
    private func stringFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let gregorian = Calendar(identifier: .gregorian)
        dateFormatter.calendar = gregorian
        
        // 한국 설정
        dateFormatter.timeZone = .autoupdatingCurrent
        let locale = Locale(identifier: "ko_KR")
        dateFormatter.locale = locale
        
        return dateFormatter.string(from: date)
    }
    /// yyyy-MM-dd HH 형태의 String 으로 Date 생성
    private func dateWithHHFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH"
        
        let gregorian = Calendar(identifier: .gregorian)
        dateFormatter.calendar = gregorian
        
        // 한국 설정
        dateFormatter.timeZone = .autoupdatingCurrent
        let locale = Locale(identifier: "ko_KR")
        dateFormatter.locale = locale
        
        return dateFormatter.date(from: dateString)
    }
}

