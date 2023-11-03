//
//  CalendarViewController.swift
//  Cleaner
//
//  Created by Macmini on 01/11/2023.
//

import UIKit
import EventKit

class CalendarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let eventStore = EKEventStore()

        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            // Đã được cấp quyền, có thể truy cập vào dữ liệu lịch
            break
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
            let calendars = eventStore.calendars(for: .event)
            
            for calendar in calendars {
                // Lấy danh sách sự kiện từ lịch này
                let predicate = eventStore.predicateForEvents(withStart: Date(), end: Date().addingTimeInterval(365*24*60*60), calendars: [calendar])
                let events = eventStore.events(matching: predicate)
                
                for event in events {
                    // In ra thông tin của sự kiện
                    print("Event Title: \(event.title)")
                    print("Event Start Date: \(event.startDate)")
                    print("Event End Date: \(event.endDate)")
                }
            }
        case .writeOnly:
            break
        @unknown default:
            break
        }

    }
    
    static func makeSelf() -> CalendarViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: CalendarViewController = storyboard.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
        
        return rootViewController
    }

}
