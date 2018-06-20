//
//  ListTableViewController.swift
//  FinalAudioPlayer
//
//  Created by SWUCOMPUTER on 2018. 6. 1..
//  Copyright © 2018년 SWUCOMPUTER. All rights reserved.
//

import UIKit
import CoreData

class ListTableViewController: UITableViewController {

    var recordLists: [NSManagedObject] = []
    var detailList : NSManagedObject?
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "RecordList")
        // 순서
        let sortDescriptor = NSSortDescriptor(key: "recordDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            recordLists = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
         if let recordSmall = seeRecord {
         seeRecordTitle.text = recordSmall.value(forKey: "recordTitle") as? String
         seeRecordDetail.text = recordSmall.value(forKey: "recordDetail") as? String
         seeRecordMemo.text = recordSmall.value(forKey: "recordMemo") as? String
         }
         */
        //let context = self.getContext()
        //let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "RecordList")
        //let cell = tableView.dequeueReusableCell(withIdentifier: "List Cell", for: indexPath)
        
        /*if let listBig = detailList {
            //if let listBig = listSmall[indexPath.row]{
                var display : String = ""
                if let unwrapDate: Date = listBig.value(forKey: "recordDate") as? Date {
                    let formatter: DateFormatter = DateFormatter()
                    formatter.dateFormat = "yyyy.MM.dd."
                    let displayDate = formatter.string(from: unwrapDate as Date)
                    display = displayDate
                }
                cell.textLabel?.text = listBig.value(forKey: "recordTitle") as? String
                cell.detailTextLabel?.text = display
            //}
        }*/
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "List Cell", for: indexPath)
        let listBig = recordLists[indexPath.row]
        var display: String = ""
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd."
        if let unwrapDate: Date = listBig.value(forKey: "recordDate") as? Date {
            let displayDate = formatter.string(from: unwrapDate as Date)
            display = displayDate
        }
        cell.textLabel?.text = listBig.value(forKey: "recordTitle") as? String
        cell.detailTextLabel?.text = display
        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = getContext()
            context.delete(recordLists[indexPath.row])
            /*
             리스트 지우면 녹음서버데이터들도 모두 지워지는거 코드 작성해야함
             */
            do {
                try context.save()
                print("deleted")
            } catch let error as NSError {
                print("Could not delete \(error), \(error.userInfo)")
            }
            recordLists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
 
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlayView" {
            if let destination = segue.destination as? PlayViewController {
                if let selectedIndex = self.tableView.indexPathsForSelectedRows?.first?.row {
                    destination.seeRecord = recordLists[selectedIndex]
                }
            }
        }
    }
    

}
