//
//  RecordViewController.swift
//  FinalAudioPlayer
//
//  Created by SWUCOMPUTER on 2018. 6. 1..
//  Copyright © 2018년 SWUCOMPUTER. All rights reserved.
//

import UIKit
import CoreData

class RecordViewController: UIViewController {

    
    @IBOutlet var recordName: UITextField!
    @IBOutlet var recordDetailText: UITextField!
    @IBOutlet var recordMemoText: UITextView!
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "RecordList", in: context)
        let object = NSManagedObject(entity: entity!, insertInto: context)
        object.setValue(recordName.text, forKey: "recordTitle")
        object.setValue(recordDetailText.text, forKey: "recordDetail")
        object.setValue(recordMemoText.text, forKey: "recordMemo")
        object.setValue(Date(), forKey: "recordDate")
        
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
