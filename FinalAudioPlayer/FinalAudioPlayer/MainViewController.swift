//
//  MainViewController.swift
//  FinalAudioPlayer
//
//  Created by SWUCOMPUTER on 2018. 6. 1..
//  Copyright © 2018년 SWUCOMPUTER. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var folderTableView: UITableView!
    
    var folders: [NSManagedObject] = []
    
    @IBAction func addFolderButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "새로운 폴더", message: "이 폴더의 이름을 입력하십시오.", preferredStyle: .alert)
        let save = UIAlertAction(title: "Save", style: .default) {
            (save) in
            let context = self.getContext()
            let entity = NSEntityDescription.entity(forEntityName: "Folder", in: context)
            let object = NSManagedObject(entity: entity!, insertInto: context)
            
            object.setValue(alert.textFields?[0].text, forKey: "folderName")

            do {
                try context.save()
                print("saved!")
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Folder")
            let sortDescriptor = NSSortDescriptor(key: "folderName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            do {
                self.folders = try context.fetch(fetchRequest)
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            self.folderTableView.reloadData()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) {
            (cancel) in
        }
        alert.addAction(cancel)
        alert.addAction(save)
        
        alert.addTextField {
            (myTextField) in
            myTextField.placeholder = "폴더 이름"
        }
        self.present(alert, animated: true, completion: nil)
    }

    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Decoder"
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //나중에 겹치는 코드 함수선언해서 처리하기
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Folder")
        let sortDescriptor = NSSortDescriptor(key: "folderName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            folders = try context.fetch(fetchRequest)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.folderTableView.dequeueReusableCell(withIdentifier: "Folder Cell", for: indexPath) as! FolderCell
        let folderBig = folders[indexPath.row]
        //cell.folderName?.text = folderBig.value(forKey: "folderName") as? String
        cell.textLabel?.text = folderBig.value(forKey: "folderName") as? String
        //cell.detailTextLabel?.text = folderBig.value(forKey: "listNum") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Decoder Folder"
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            /*
             폴더 지우면 하위 스토리보드 코어데이터들도 모두 지워지는거 코드 작성해야함
             */
            let context = getContext()
            context.delete(folders[indexPath.row])
            do {
                try context.save()
                print("delete file")
            } catch let error as NSError {
                print("Could not delete \(error), \(error.userInfo)")
            }
            folders.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        else if editingStyle == .insert {
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toListView" {
            if let destination = segue.destination as? ListTableViewController {
                if let selectedIndex = self.folderTableView.indexPathsForSelectedRows?.first?.row {
                    destination.detailList = folders[selectedIndex]
                    destination.title = folders[selectedIndex].value(forKey: "folderName") as? String
                }
            }
        }
    }

}
