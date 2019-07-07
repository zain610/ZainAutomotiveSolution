//
//  SelectDateAndTimeViewController.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 08/06/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit
import FSCalendar
class SelectDateAndTimeViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    var selectedDate: Date = Date()
    var selectedTime: String = ""
//    fileprivate let timeFormatter: DateFormatter = {
//        let timeFormatter = DateFormatter()
//        timeFormatter.timeStyle = .medium
//        return timeFormatter
//
//    }()
//
    fileprivate weak var calendar: FSCalendar!
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "AEST")
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        return formatter
    }()
    var selectedCar: Car?
    
    override func loadView() {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.groupTableViewBackground
        self.view = view
        
        let height: CGFloat = UIDevice.current.model.hasPrefix("iPad") ? 400 : 300
        let calendar = FSCalendar(frame: CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.maxY)!, width: view.frame.width, height: height))
        calendar.dataSource = self
        calendar.delegate = self
        calendar.allowsMultipleSelection = false
        view.addSubview(calendar)
        self.calendar = calendar
        
        calendar.calendarHeaderView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        calendar.calendarWeekdayView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        calendar.appearance.eventSelectionColor = UIColor.white
        calendar.appearance.eventOffset = CGPoint(x: 0, y: -7)
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "CELL")
        
//        calendar.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        calendar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        calendar.heightAnchor.constraint(equalToConstant: 275).isActive = true
//        calendar.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        
        let timeOptions = ["9:00", "11:00", "13:00", "15:00"]
        
        let timePicker: UISegmentedControl = UISegmentedControl(items: timeOptions)
        timePicker.addTarget(self, action: #selector(segmentAction(_:)), for: .valueChanged)
        view.addSubview(timePicker)
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = timePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let verticalConstraint = timePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50)
        let widthConstraint = timePicker.widthAnchor.constraint(equalToConstant: view.frame.width)
        
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Select Date and Time"
        
    }
    @objc func segmentAction(_ segmentedControl: UISegmentedControl) {
        switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            self.selectedTime = "9"
            break // 9am
        case 1:
            self.selectedTime = "11"
            break // 11am
        case 2:
            break // 1pm
        case 3:
            break //3pm
        default:
            break
        }
    }
    private func convertToSeconds(hour: String) -> Double {
/* So the user enters time in hours like 9,11,13, etc. So we have to convert this to seconds which can be then added  as time interval to the date object. When we convert 9:00am to time interval we are expecting to get a  result something along the lines of
    12am -> 9am = +9 hours
    9 * 60 = 540 min
    540 * 60 = 32400 seconds <- return value
 */
        if hour.isEmpty == false {
            let intHour = Double(string: hour)
            let returnValue: Double
            print(intHour)
            returnValue = intHour! * 60 * 60
            return returnValue
        }
        return 0
        
    }
    
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "CELL", for: date, at: position)
        return cell
    }
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.frame = CGRect(origin: calendar.frame.origin, size: bounds.size)
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let timeInSeconds = convertToSeconds(hour: self.selectedTime)
        let time: TimeInterval = TimeInterval(exactly: timeInSeconds)!
        let newdate = date.addingTimeInterval(time)
        let actualDate = self.formatter.string(from: newdate)
        print("actualDate \(actualDate)")

        
    }
}
