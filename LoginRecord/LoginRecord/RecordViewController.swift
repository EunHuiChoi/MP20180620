//
//  RecordViewController.swift
//  LoginRecord
//
//  Created by SWUCOMPUTER on 2018. 6. 17..
//  Copyright © 2018년 SWUCOMPUTER. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var recordTitle: UITextField!
    @IBOutlet var recordSub: UITextField!
    @IBOutlet var recordMemo: UITextView!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    
    @IBOutlet var recordTime: UILabel!
    @IBOutlet var sliderVol: UISlider!
    
    var audioPlayer : AVAudioPlayer!
    var audioFile : URL!
    let MAX_VOLUME : Float = 10.0
    var audioRecorder : AVAudioRecorder!
    var progressTimer : Timer!
    
    let timeRecordSelector: Selector = #selector(RecordViewController.updateRecordTime)
    let timePlaySelector: Selector = #selector(RecordViewController.updatePlayTime)
    
    @objc func updatePlayTime() {
        recordTime.text = convertNSTimeInterval2String(audioPlayer.currentTime)
    }
    @objc func updateRecordTime() {
        recordTime.text = convertNSTimeInterval2String(audioRecorder.currentTime)
    }
    
    @IBAction func saveRecord(_ sender: UIBarButtonItem) {
        let title = recordTitle.text!
        let subtitle = recordSub.text!
        let memo = recordMemo.text!
        if (title == "" || subtitle == "" || memo == "") {
            let alert = UIAlertController(title: "제목/설명을 입력하세요",
                                          message: "Save Failed!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                alert.dismiss(animated: true, completion: nil) }))
            self.present(alert, animated: true)
            return }
        /*guard let myRecord = audioPlayer else {
            let alert = UIAlertController(title: "녹음파일이 없습니다.",message: "Save Failed!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true)
            return
        }*/
        
        guard let myImage = imageView.image else {
            let alert = UIAlertController(title: "이미지를 선택하세요",message: "Save Failed!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true)
            return
        }
        
        let myUrl = URL(string: "http://condi.swu.ac.kr/student/W11iphone/upload.php");
        var request = URLRequest(url:myUrl!);
        request.httpMethod = "POST";
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard let imageData = UIImageJPEGRepresentation(myImage, 1) else { return }
        
        var body = Data()
        var dataString = "--\(boundary)\r\n"
        dataString += "Content-Disposition: form-data; name=\"userfile\"; filename=\".jpg\"\r\n"
        dataString += "Content-Type: application/octet-stream\r\n\r\n"
        if let data = dataString.data(using: .utf8) {
            body.append(data)
        }
        
        body.append(imageData)
        //print(body)
        
        dataString = "\r\n"
        dataString += "--\(boundary)--\r\n"
        if let data = dataString.data(using: .utf8) {
            body.append(data)
        }
        request.httpBody = body
        //print(body)
        
        var imageFileName: String = ""
        let semaphore = DispatchSemaphore(value: 0)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else { print("Error: calling POST"); return; }
            guard let receivedData = responseData else { print("Error: not receiving Data"); return; }
            if let utf8Data = String(data: receivedData, encoding: .utf8) {
                imageFileName = utf8Data
                print(imageFileName)
                semaphore.signal()
            }
        }
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        //해당부분 음성파일 서버에 넘기는 것 오류나서 일단 주석처리
        /*let myUrl = URL(string: "http://condi.swu.ac.kr/student/W11iphone/upload.php");
        var request = URLRequest(url:myUrl!);
        request.httpMethod = "POST";
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
        
        //let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSString
        //let path = fileManager.
        //let path = documentDirectory.appendingPathComponent("recordFile.m4a")
        
        //let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("xyz.mov")
        //fileManager.createFile(atPath: path as String, contents: <#Data?#>, attributes: nil)
        
        let fileManager = FileManager.default
        audioFile = getDirectory().appendingPathComponent("recordFile.m4a")
        fileManager.createDirectory(at: audioFile, withIntermediateDirectories: true, attributes: nil)
        
        
        //NSdata(contentsOf: audioFile)
        //guard let recordData = record else { return }
        //guard let recordData =  else { return }
        
        var body = Data()
        var dataString = "--\(boundary)\r\n"
        dataString += "Content-Disposition: form-data; name=\"userfile\"; filename=\".m4a\"\r\n"
        dataString += "Content-Type: application/octet-stream\r\n\r\n"
        if let data = dataString.data(using: .utf8) {
            body.append(data)
        }
        
        //body.append(recordData)
        
        dataString = "\r\n"
        dataString += "--\(boundary)--\r\n"
        if let data = dataString.data(using: .utf8) {
            body.append(data)
        }
        request.httpBody = body*/
        
        let urlString: String = "http://condi.swu.ac.kr/student/W11iphone/insertRecord.php"
        guard let requestURL = URL(string: urlString) else { return }
        request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let userID = appDelegate.ID  else { return }
        guard let folderName = appDelegate.foldername else { return }
        print(userID)
        print(folderName)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let myDate = formatter.string(from: Date())
        print(myDate)
        
        var restString: String = "id=" + userID + "&folderName=" + folderName
        restString += "&title=" + title
        restString += "&subtitle=" + subtitle
        restString += "&description=" + memo
        restString += "&image=" + imageFileName + "&date=" + myDate
        request.httpBody = restString.data(using: .utf8)
        
        let session2 = URLSession.shared
        let task2 = session2.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else { return }
            guard let receivedData = responseData else { return }
            if let utf8Data = String(data: receivedData, encoding: .utf8) {
                print(utf8Data)
            }
        }
        task2.resume()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        if audioRecorder == nil {

            let recordSettings = [AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless as UInt32),
                                  AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                                  AVEncoderBitRateKey: 320000,
                                  AVNumberOfChannelsKey: 2,
                                  AVSampleRateKey: 44100.0] as [String : Any]
            
            do {
                audioRecorder = try AVAudioRecorder(url: audioFile, settings: recordSettings)
                audioRecorder.delegate = self
                audioRecorder.record()
                sender.setImage(#imageLiteral(resourceName: "stop.png"), for: UIControlState())
            } catch let error as NSError {
                print("Error-initRecord : \(error)")
            }
            progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timeRecordSelector, userInfo: nil, repeats: true)
        }
        else {
            audioRecorder.stop()
            progressTimer.invalidate()
            sender.setImage(#imageLiteral(resourceName: "recordPress.png"), for: UIControlState())
            setPlayButtons(true, pause: false)
            initPlay()
            //recordTime.text = convertNSTimeInterval2String(audioPlayer.duration)
            recordTime.text = convertNSTimeInterval2String(0)
            audioRecorder = nil
        }
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        audioPlayer.play()
        setPlayButtons(false, pause: true)
        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timePlaySelector, userInfo: nil, repeats: true)
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        audioPlayer.pause()
        setPlayButtons(true, pause: false)
    }
    
    @IBAction func chagneVolum(_ sender: UISlider) {
        audioPlayer.volume = sliderVol.value
    }
    
    @IBAction func selectPicture (_ sender: UIButton) {
        let myPicker = UIImagePickerController()
        myPicker.delegate = self;
        myPicker.sourceType = .photoLibrary
        self.present(myPicker, animated: true, completion: nil)
    }
    
    @IBAction func takePicture (_ sender: UIButton) {
        let myPicker = UIImagePickerController()
        myPicker.delegate = self;
        myPicker.allowsEditing = true
        myPicker.sourceType = .camera
        self.present(myPicker, animated: true, completion: nil)
    }
    
    func imagePickerController (_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel (_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func initPlay() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
        } catch let error as NSError {
            print("Error-initPlay : \(error)")
        }
        sliderVol.maximumValue = MAX_VOLUME
        sliderVol.value = 1.0
        
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        audioPlayer.volume = sliderVol.value
        //recordTime.text = convertNSTimeInterval2String(audioPlayer.duration)
        //recordTime.text = convertNSTimeInterval2String(0)
        
        setPlayButtons(true, pause: false)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        progressTimer.invalidate()
        setPlayButtons(true, pause: false)
    }
    
    func convertNSTimeInterval2String(_ time: TimeInterval) -> String {
        let min = Int(time/60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        let stringTime = String(format: "%02d:%02d", min, sec)
        return stringTime
    }
    
    func setPlayButtons(_ play: Bool, pause: Bool) {
        playButton.isEnabled = play
        pauseButton.isEnabled = pause
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        recordMemo.becomeFirstResponder()
        return true
    }
    
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sliderVol.value = 1.0
        setPlayButtons(false, pause: false)
        
        //let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        audioFile = getDirectory().appendingPathComponent("recordFile.m4a")
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("Error-setCategory: \(error)")
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("Error-setActive: \(error)")
        }
        //audioRecorder.isMeteringEnabled = true
        //audioRecorder.prepareToRecord()
        recordTime.text = convertNSTimeInterval2String(0)
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
