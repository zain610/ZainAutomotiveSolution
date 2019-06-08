//
//  SelectDateAndTimeViewController.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 08/06/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit
import FSCalendar
class SelectDateAndTimeViewController: UIViewController {
    
    fileprivate weak var calendar: FSCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // In loadView or viewDidLoad
        let calendar = FSCalendar(frame: CGRect(x: view.frame.minX, y: view.frame.midY, width: 320, height: 300))
        calendar.dataSource = self
        calendar.delegate = self
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "CELL")
        calendar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(calendar)
        self.calendar = calendar
        
        
        calendar.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        calendar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        calendar.heightAnchor.constraint(equalToConstant: 275).isActive = true
        calendar.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true

        
    }
    

}
extension SelectDateAndTimeViewController: FSCalendarDataSource, FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "CELL", for: date, at: position)
        return cell
    }
}
