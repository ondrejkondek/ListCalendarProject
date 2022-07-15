//
//  ViewController.swift
//  JTAppleCalendarDemo
//
//  Created by Ondrej Kondek on 15/11/2021.
//

import UIKit

struct Section {
    var monthDays: [String]
    var monthName: String
    var date: Date
    
    init(monthDays: [String], monthName: String, date: Date) {
        self.monthDays = monthDays
        self.monthName = monthName
        self.date = date
    }
}

class ViewController: UIViewController {
    
    @IBOutlet var prevBtn: UIButton!
    @IBOutlet var nextBtn: UIButton!
    @IBOutlet var month: UILabel!
    
    var sections = [Section]()
    // actually displayed month - in Label
    var dateActual = Date()
    // Flag if the screen was scrolled by draggin or programatically
    var drag: Bool = false
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        prevBtn.setTitle("<", for: .normal)
        nextBtn.setTitle(">", for: .normal)
        
        sections.append(Section(monthDays: getDaysMonth(date: dateActual),
                                monthName: CalendarHelper().monthString(date: dateActual),
                                date: dateActual))
        month.text = CalendarHelper().monthString(date: dateActual)
    }
    
    func getSectionForDate(date: Date) -> Int? {
        for idx in 0 ..< sections.count {
            if sections[idx].date == date {
                return idx
            }
        }
        return nil
    }
    
    @IBAction func nextTap(_ sender: Any) {
        let nextMonth = CalendarHelper().plusMonth(date: dateActual)
        let nextSection = getSectionForDate(date: nextMonth)
        let actualSection = getSectionForDate(date: dateActual)
        
        // Next month was already loaded
        if nextSection != nil {
            dateActual = CalendarHelper().plusMonth(date: dateActual)
        }
        // Next month needs to be loaded
        else {
            getNextMonth()
        }
        
        tableView.scrollToRow(at: IndexPath(row: 0, section: actualSection! + 1), at: .top, animated: true)
        drag = false // scroll is done programatically
        month.text = CalendarHelper().monthString(date: dateActual)
    }
    
    @IBAction func prevTap(_ sender: Any) {
        let prevMonth = CalendarHelper().minusMonth(date: dateActual)
        let prevSection = getSectionForDate(date: prevMonth)
        let actualSection = getSectionForDate(date: dateActual)
        
        // Previous month was already loaded
        if prevSection != nil {
            dateActual = CalendarHelper().minusMonth(date: dateActual)
            tableView.scrollToRow(at: IndexPath(row: 0, section: actualSection! - 1), at: .top, animated: true)
        }
        // Previous month needs to be loaded
        else {
            getPrevMonth()
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        
        drag = false // scroll is done programatically
        month.text = CalendarHelper().monthString(date: dateActual)
    }
    
    func getDaysMonth(date: Date) -> [String] {
        var daysMonth = [String]()
        for idx in 0..<CalendarHelper().daysInMonth(date: date) {
            let day = String(idx + 1)
            daysMonth.append(day)
        }
        return daysMonth
    }
    
    func getNextMonth(){
        dateActual = CalendarHelper().plusMonth(date: dateActual)
        let newSection = Section(monthDays: getDaysMonth(date: dateActual),
                                 monthName: CalendarHelper().monthString(date: dateActual),
                                 date: dateActual)
        sections.append(newSection)
        
        let set = IndexSet(integer: sections.count - 1)
        tableView.beginUpdates()
        tableView.insertSections(set, with: .bottom)
        tableView.endUpdates()
    }
    
    func getPrevMonth(){
        dateActual = CalendarHelper().minusMonth(date: dateActual)
        let newSection = Section(monthDays: getDaysMonth(date: dateActual),
                                 monthName: CalendarHelper().monthString(date: dateActual),
                                 date: dateActual)
        sections.insert(newSection, at: 0)
        
        var initialContentOffSet = tableView.contentOffset.y
        if initialContentOffSet < 0 {
            initialContentOffSet = 0
        }
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: false)
        tableView.contentOffset.y = tableView.contentOffset.y  + initialContentOffSet
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].monthDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomCell
        cell.label.text = sections[indexPath.section].monthDays[indexPath.row] + sections[indexPath.section].monthName
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y;
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        // Scrolling Down
        if (maximumOffset - currentOffset <= 2.0) {
            getNextMonth()
            month.text = CalendarHelper().monthString(date: dateActual)
        }
        // Scrolling Up
        if (currentOffset < -2.0) {
            getPrevMonth()
            month.text = CalendarHelper().monthString(date: dateActual)
        }
        
        if let visibleRows = tableView.indexPathsForVisibleRows {
            let visibleSections = visibleRows.map({$0.section})
            var section: Int
            
            if drag {
                section = visibleSections[0]
            }
            else {
                section = visibleSections[1]
            }
            
            guard var displayedSection = getSectionForDate(date: dateActual) else {
                return
            }
            
            if (section != displayedSection) {
                displayedSection = section
                dateActual = sections[displayedSection].date
                month.text = CalendarHelper().monthString(date: dateActual)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        drag = true
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        drag = true
    }
}

//func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
////        if let visibleRows = tableView.indexPathsForVisibleRows {
////            let visibleSections = visibleRows.map({$0.section})
////
////            var section: Int = 0
////
//////            var counts: [Int: Int] = [:]
////
//////            for item in visibleSections {
//////                counts[item] = (counts[item] ?? 0) + 1
//////            }
////
//////            var tmpVal = 100
//////            for (key, value) in counts {
//////                if value > 1, tmpVal > value {
//////                    tmpVal = value
//////                    section = key
//////                }
//////            }
////
////            section = visibleSections.first ?? 0
////            print(section)
////
////            displayedSection = section
////            dateActual = sections[section].date
////            month.text = sections[section].monthName + CalendarHelper().yearString(date: sections[section].date)
////            print(sections[section].monthName + CalendarHelper().yearString(date: sections[section].date))
////        }
//
////        var section: Int = 0
////        let position: CGPoint = cell.convert(CGPoint.zero, to: self.tableView)
////        if let indexPath = self.tableView.indexPathForRow(at: position)
////        {
////            section = indexPath.section
////            displayedSection = section
////            dateActual = sections[section].date
////            month.text = sections[section].monthName + CalendarHelper().yearString(date: sections[section].date)
////            print(sections[section].monthName + CalendarHelper().yearString(date: sections[section].date))
////        }
//
//}


//        // next month was never loaded - firstly load it
//        if displayedSection == sections.count - 1 {
//            getNextMonth()
//            tableView.scrollToRow(at: IndexPath(row: 0, section: displayedSection + 1), at: .top, animated: true)
//        }
//        // If next month is already loaded - do not load it again just scroll to it
//        else {
//            dateActual = CalendarHelper().plusMonth(date: dateActual)
//            tableView.scrollToRow(at: IndexPath(row: 0, section: displayedSection + 1), at: .top, animated: true)
//        }
//
//        displayedSection += 1
//        month.text = CalendarHelper().monthString(date: dateActual)


// previous month was never loaded - firstly load it
//        if displayedSection == 0 {
//            getPrevMonth()
//            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//        }
//        // if previous month is already loaded - do not load it again just scroll to it
//        else {
//            tableView.scrollToRow(at: IndexPath(row: 0, section: displayedSection - 1), at: .top, animated: true)
//        }
