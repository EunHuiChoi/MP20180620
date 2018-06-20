
//
//  DirectViewController.swift
//  FinalAudioPlayer
//
//  Created by SWUCOMPUTER on 2018. 6. 1..
//  Copyright © 2018년 SWUCOMPUTER. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
//import CoreAudio

class DirectViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    //var audioURL:URL!
    
    var numberOfRecords : Int = 0
    var temFile : [NSManagedObject] = []
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var temRecordTableView: UITableView!
    
    @IBAction func record(_ sender: UIButton) {
        
        //Core data 저장 초기설정
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Temporary", in: context)
        let object = NSManagedObject(entity: entity!, insertInto: context)
        
        if audioRecorder == nil {
            numberOfRecords += 1
            let filename = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
            
            //파일 URL 클라이언트DB 저장
            object.setValue(filename, forKey: "temFileURL")
            /*do {
                try context.save()
                print("savedURL!")
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }*/
            
            //녹음 파일 초기 설정
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            do {
                //녹음 시작
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                recordButton.setImage(#imageLiteral(resourceName: "stop.png"), for: .normal)
            }
            catch {
                displayAlert(title: "Ups!", message: "Recording failed")
            }
        }
        else {
            audioRecorder.stop()
            audioRecorder = nil
            
            //녹음 파일 이름 저장을 위한 alert
            let alert = UIAlertController(title: "새로운 녹음", message: "이 녹음의 이름을 입력하십시오.", preferredStyle: .alert)
            let save = UIAlertAction(title: "Save", style: .default) {
                (save) in
                //녹음 파일 이름 클라이언트 DB저장
                object.setValue(alert.textFields?[0].text, forKey: "temFileName")
                //object.setValue(filename, forKey: "temFileURL")
                do {
                    try context.save()
                    print("saved!")
                } catch let error as NSError {
                    print("Could not save \(error), \(error.userInfo)")
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) {
                (cancel) in
            }
            alert.addAction(cancel)
            alert.addAction(save)
            alert.addTextField {
                (myTextField) in
                myTextField.placeholder = "녹음 이름"
            }
            present(alert, animated: true, completion: nil)
            
            //현재까지 된 녹음 파일 보여주기
            /*let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Temporary")
            do {
                temFile = try context.fetch(fetchRequest)
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }*/
            temRecordTableView.reloadData()
            recordButton.setImage(#imageLiteral(resourceName: "record.png"), for: .normal)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingSession = AVAudioSession.sharedInstance()
   
        //녹음 파일 내역 보여주기
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Temporary")
        do {
            temFile = try context.fetch(fetchRequest)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission {
            (hasPermission) in
            if hasPermission {
                print ("ACCEPTED")
            }
        }
    }
    
    func getContext() -> NSManagedObjectContext {
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     return appDelegate.persistentContainer.viewContext
    }
 
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (temFile.count)/2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Direct Cell", for: indexPath)
        let temBig = temFile[indexPath.row]
        cell.textLabel?.text = temBig.value(forKey: "temFileName") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = getContext()
            context.delete(temFile[indexPath.row])
            do {
                try context.save()
                print("delete file")
            } catch let error as NSError {
                print("Could not delete \(error), \(error.userInfo)")
            }
            temFile.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        else if editingStyle == .insert {
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = getDirectory().appendingPathComponent("\(indexPath.row+1).m4a")
        //let path = temFile[indexPath.row].value(forKey: "temFileURL")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        }
        catch {
            
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "temporary file"
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
}
