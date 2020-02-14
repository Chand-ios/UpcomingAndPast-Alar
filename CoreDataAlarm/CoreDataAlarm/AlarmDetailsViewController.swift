//
//  AlarmDetailsViewController.swift
//  CoreDataAlarm
//
//  Created by eAlphaMac2 on 14/02/20.
//  Copyright © 2020 eAlphaMac2. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData
class AlarmDetailsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UNUserNotificationCenterDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate //Singlton instance
    var context:NSManagedObjectContext!
    var items: [NSManagedObject] = []
    var upcomingDates:[[String:String]] = []
    var pastDates:[[String:String]] = []
    var dates:[[String:String]] = []

@IBOutlet var tblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.delegate = self
        tblView.dataSource = self
       

        //deleteRecords()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
              super.viewWillAppear(animated)
           fetchData()
       }
       @IBAction func AddAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(vc, animated: false)
        
    }
     //TableView Delegate And Data Source
    @IBAction func upcomingAction(_ sender: Any) {
        
         dates = upcomingDates
        tblView.reloadData()

        }
//            if Calendar.current.isDate(datePicker.date, equalTo: Date(), toGranularity: .minute) {
//                   print("success")
//                   }
//        }
//
    
    @IBAction func pastAction(_ sender: Any) {
        dates = pastDates
        tblView.reloadData()


    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
              return dates.count
          }
          
          func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlaramDetailsTableViewCell") as! AlaramDetailsTableViewCell
              cell.selectionStyle = .none
              let item = dates[indexPath.row]
              
              cell.dateLbl.text = item["time"]
              cell.dateLbl.textColor = .white
             cell.titleLbl.text = item["title"]
            cell.deleteBtn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
               
            cell.deleteBtn.tag = indexPath.row
          cell.editBtn.addTarget(self, action: #selector(editAction), for: .touchUpInside)
             
          cell.editBtn.tag = indexPath.row
          return cell
          
          }
    @objc func deleteAction(){
       
        
    }
    @objc func editAction(_sender : UIButton){
          let vc = self.storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
        let item = dates[_sender.tag]
        
        vc.titleStr = item["title"]!
        vc.dateStr = item["time"]!
        self.navigationController?.pushViewController(vc, animated: false)
           
}
       func fetchData()
              {
                upcomingDates.removeAll()
                pastDates.removeAll()
                  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                     let manageContent = appDelegate.persistentContainer.viewContext
                     let fetchData = NSFetchRequest<NSFetchRequestResult>(entityName: "Dates")
                     do {

                         let result = try manageContent.fetch(fetchData)
                         items = result as! [NSManagedObject]
                        for date in items {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                               let Time = (date.value(forKey: "time") as? String)!
                                 let convertedDate = dateFormatter.date(from: Time)
                                if Date().compare(convertedDate!) == ComparisonResult.orderedDescending {
                                    print("myDate is earlier than currentDate")
                                   let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                                   let dateStr = dateFormatter.string(from: convertedDate!)
                                   let title = (date.value(forKey: "title") as? String)!
                                   var detail =  Dictionary<String, String>()
                                   detail.updateValue(title, forKey: "title")
                                   detail.updateValue(dateStr, forKey: "time")

                                    upcomingDates.append(detail)
                                }
                                else if Date().compare(convertedDate!) == ComparisonResult.orderedAscending{
                                    let dateFormatter = DateFormatter()
                                     dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                                    let dateStr = dateFormatter.string(from: convertedDate!)
                                    let title = (date.value(forKey: "title") as? String)!
                                    var detail =  Dictionary<String, String>()
                                    detail.updateValue(title, forKey: "title")
                                    detail.updateValue(dateStr, forKey: "time")

                                    pastDates.append(detail)

                                   }
                                }
                               dates = upcomingDates
                        tblView.reloadData()
                     }catch {
                         print("err")
                     }
              }
    // MARK: Delete Data Records

    func deleteRecords() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext

        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Dates")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
          

}
