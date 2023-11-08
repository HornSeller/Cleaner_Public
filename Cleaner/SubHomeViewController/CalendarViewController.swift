//
//  CalendarViewController.swift
//  Cleaner
//
//  Created by Macmini on 01/11/2023.
//

import UIKit
import EventKit

class CalendarViewController: UIViewController {

    let eventStore = EKEventStore()
    var dataTable: [EKEvent] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            // Đã được cấp quyền, có thể truy cập vào dữ liệu lịch
            searchEventsSince1970 { events in
                self.dataTable = events
                print(self.dataTable.last?.title)
//                do {
//                    try self.eventStore.remove(self.dataTable.last!, span: .thisEvent, commit: true)
//                } catch {
//                    print(error.localizedDescription)
//                }
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
                print(self.dataTable)
            }
            
        case .writeOnly:
            break
        @unknown default:
            break
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchEventsSince1970(completion: @escaping ([EKEvent]) -> Void) {
        var eventsArr: [EKEvent] = []
        let calendars = eventStore.calendars(for: .event).filter {
            $0.allowsContentModifications && $0.source.sourceType == .local
        }
        var startDate = Date(timeIntervalSinceNow: 0); print(startDate)
        print(startDate.timeIntervalSince1970)
        for calendar in calendars {
            // Tạo predicate để lấy sự kiện từ lịch này
            while (startDate.timeIntervalSince1970 >= 0) {
                let predicate = eventStore.predicateForEvents(withStart: startDate - 365*24*60*60, end: startDate, calendars: [calendar])
                let events = eventStore.events(matching: predicate)
                print(events.count)
                for event in events {
                    print("Event Title: \(event.title ?? "")")
                    print("Event Start Date: \(event.startDate ?? Date())")
                    print("Event End Date: \(event.endDate ?? Date())")
                    eventsArr.append(event)
                }
                startDate = startDate - 365*24*60*60
                print(startDate)
            }
            
            if (startDate.timeIntervalSince1970 < 0) {
                completion(eventsArr)
            }
        }
    }
    
    static func makeSelf() -> CalendarViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: CalendarViewController = storyboard.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
        
        return rootViewController
    }

}
