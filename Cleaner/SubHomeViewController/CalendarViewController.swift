//
//  CalendarViewController.swift
//  Cleaner
//
//  Created by Macmini on 01/11/2023.
//

import UIKit
import EventKit
import Foundation

class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! CalendarTableViewCell
        cell.titleLb.text = dataTable[indexPath.row].title
        cell.dateLb.text = dateFormatter.string(from: dataTable[indexPath.row].startDate)
        if cell.isSelected {
            cell.checkboxImgView.image = UIImage(named: "Check box 1")
        } else {
            cell.checkboxImgView.image = UIImage(named: "Check box")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! CalendarTableViewCell
        selectedCell.checkboxImgView.image = UIImage(named: "Check box 1")
        eventsToDelete.append(dataTable[indexPath.row])
        indexPathToDelete.append(indexPath)
        infoLb.text = "\(eventsToDelete.count)/\(dataTable.count) selected events"
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedCell = tableView.cellForRow(at: indexPath) as! CalendarTableViewCell
        deselectedCell.checkboxImgView.image = UIImage(named: "Check box")
        if let index = eventsToDelete.firstIndex(where: { $0 == dataTable[indexPath.row]}) {
            eventsToDelete.remove(at: index)
        }
        if let index = indexPathToDelete.firstIndex(where: { $0 == indexPath}) {
            indexPathToDelete.remove(at: index)
        }
        infoLb.text = "\(eventsToDelete.count)/\(dataTable.count) selected events"
    }
    
    @IBOutlet weak var infoLb: UILabel!
    @IBOutlet weak var backgroundLb: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteBtn: UIButton!
    let eventStore = EKEventStore()
    var dataTable: [EKEvent] = []
    let dateFormatter = DateFormatter()
    var eventsToDelete: [EKEvent] = []
    var indexPathToDelete: [IndexPath] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "MMMM dd, yyyy"
        
        deleteBtn.layer.cornerRadius = 22
        
        tableView.register(UINib(nibName: "CalendarTableViewCell", bundle: .main), forCellReuseIdentifier: "myCell")
        tableView.rowHeight = 0.09624 * view.frame.height
        tableView.allowsMultipleSelection = true

        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            // Đã được cấp quyền, có thể truy cập vào dữ liệu lịch
            searchEventsSince1970 { events in
                self.dataTable = events
                print(self.dataTable.count)
                self.infoLb.text = "0/\(self.dataTable.count) selected events"
                if self.dataTable.count > 0 {
                    self.backgroundLb.isHidden = true
                    self.backgroundImageView.isHidden = true
                }
                self.tableView.reloadData()
            }

        case .denied, .restricted:
            // Người dùng từ chối hoặc bị hạn chế quyền truy cập
            print("Access denied or restricted")
            
        case .notDetermined:
            // Chưa được yêu cầu quyền truy cập, yêu cầu người dùng cấp quyền
            if #available(iOS 17.0, *) {
                eventStore.requestFullAccessToEvents { granted, error in
                    if granted {
                        // Đã được cấp quyền, thực hiện lại quá trình truy cập dữ liệu lịch
                    } else {
                        // Quyền truy cập bị từ chối
                        print("Access denied")
                    }
                }
                
            } else {
                // Fallback on earlier versions
                eventStore.requestAccess(to: .event, completion:
                { (granted: Bool, error: Error?) in
                    if granted {
                        // Đã được cấp quyền, thực hiện lại quá trình truy cập dữ liệu lịch
                    } else {
                        // Quyền truy cập bị từ chối
                        print("Access denied")
                    }
                })
            }
        
        case .fullAccess:
            searchEventsSince1970 { events in
                self.dataTable = events
                print(self.dataTable.count)
                self.infoLb.text = "0/\(self.dataTable.count) selected events"
                if self.dataTable.count > 0 {
                    self.backgroundLb.isHidden = true
                    self.backgroundImageView.isHidden = true
                }
                self.tableView.reloadData()
            }
            
        case .writeOnly:
            break

        @unknown default:
            break
        }
    }
    
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        if eventsToDelete.count == 0 {
            let alert = UIAlertController(title: "Please choose at least 1 Event to delete", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        let alert = UIAlertController(title: "Delete this \(eventsToDelete.count) event(s)?", message: "Events will be removed from the Calendar.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            for event in self.eventsToDelete {
                do {
                    try self.eventStore.remove(event, span: .thisEvent, commit: true)
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            self.indexPathToDelete.sort(by: >)
            
            for indexPath in self.indexPathToDelete {
                self.dataTable.remove(at: indexPath.row)
                print(indexPath.row)
            }
            
            if self.dataTable.count == 0 {
                self.backgroundLb.isHidden = false
                self.backgroundImageView.isHidden = false
            }
            
            self.infoLb.text = "0/\(self.dataTable.count) selected events"
            self.tableView.reloadData()
            self.eventsToDelete = []
            self.indexPathToDelete = []
        }))
        self.present(alert, animated: true)
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchEventsSince1970(completion: @escaping ([EKEvent]) -> Void) {
        var eventsArr: [EKEvent] = []
        var startDate = Date(timeIntervalSinceNow: 0)
        
        while startDate.timeIntervalSince1970 >= 0 {
            let predicate = eventStore.predicateForEvents(withStart: startDate - 365*24*60*60, end: startDate, calendars: nil)
            let events = eventStore.events(matching: predicate)
            print(events.count)
            for event in events {
                if event.calendar?.isSubscribed == false {
                    print("Event Title: \(event.title ?? "")")
                    print("Event Start Date: \(event.startDate ?? Date())")
                    print("Event End Date: \(event.endDate ?? Date())")
                    eventsArr.append(event)
                }
            }
            startDate = startDate - 365*24*60*60
            print(startDate)
        }
        
        if (startDate.timeIntervalSince1970 < 0) {
            completion(eventsArr)
        }
    }
    
    static func makeSelf() -> CalendarViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: CalendarViewController = storyboard.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
        
        return rootViewController
    }

}
