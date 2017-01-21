//
//  DetailViewController.swift
//  SHEFreq
//
//  Created by clement perez on 12/28/16.
//  Copyright © 2016 clement perez. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class DetailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var appUrlTextField: UITextField!
    @IBOutlet var serverIPTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var stbIPTextField: UITextField!
    @IBOutlet var miniGenieAddr: UITextField!
    
    @IBOutlet var memoryUsageProgressView: UIProgressView!
    @IBOutlet var memoryUsageLabel: UILabel!
    @IBOutlet var miniGenieSwitch: UISwitch!
    
    weak var timer: Timer?
    
    var memoryInit : Int = -1
    
    var managedObjectContext: NSManagedObjectContext? = nil


    var environment: Environment? {
        didSet {
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let environment = self.environment {
            if let label = self.appUrlTextField {
                label.text = environment.appUrl
            }
            if let label = self.serverIPTextField {
                label.text = environment.serverIP
            }
            if let label = self.nameTextField {
                label.text = environment.name
            }
            if let label = self.stbIPTextField {
                label.text = environment.stbIP
            }
            if let label = self.miniGenieAddr {
                label.text = environment.miniGenieAddr
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        appUrlTextField.delegate = self
        serverIPTextField.delegate = self
        nameTextField.delegate = self
        stbIPTextField.delegate = self
        miniGenieAddr.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func persistChanges() {
        environment?.appUrl = appUrlTextField.text
        environment?.serverIP = serverIPTextField.text
        environment?.name = nameTextField.text
        environment?.stbIP = stbIPTextField.text
        do {
            try managedObjectContext?.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func startClicked(_ sender: Any) {
        persistChanges()
        startPulse()
        
        var url = String(format: "%@itv/startURL?url=%@%@", (environment?.stbIP!)!, (environment?.serverIP!)!, (environment?.appUrl!)!)
        
        if(miniGenieSwitch.isOn){
            var macAdrr = (environment?.miniGenieAddr!)!
            macAdrr = macAdrr.uppercased()
            
            url = String(format: "%@?&clientAddr=%@", url, (environment?.miniGenieAddr!)! )
        }
        
        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success:
                self.successBackground()
                self.getMemoryUsage()
                self.startTimer()
            case .failure(let error):
                print(error)
                self.failureBackground()
                self.stopTimer()
            }
        }
    }
    
    @IBAction func testClicked(_ sender: Any) {
        persistChanges()
        
        let url = String(format: "%@itv/getLogs", (environment?.stbIP)!)
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).validate().responseString
            { response in
                if let status = response.response?.statusCode {
                    switch(status){
                    case 200:
                        print("getLogs success")
                        print(response)
                    default:
                        print("error with response status: \(status)")
                    }
                }
                //to get JSON return value
                if let result = response.result.value {
                    let JSON = result as! String
                    self.parseMemoryResponse(body: JSON)
                    print(JSON)
                }
        }
    }
    
    @IBAction func stopClicked(_ sender: Any) {
        persistChanges()
        startPulse()
        
        self.stopTimer()
        memoryInit = -1
        
        memoryUsageLabel.text = "NA"
        memoryUsageProgressView.setProgress(0, animated: true)
        
        var url = String(format: "%@itv/stopITV", (environment?.stbIP)!)
        
        if(miniGenieSwitch.isOn){
            var macAdrr = (environment?.miniGenieAddr!)!
            macAdrr = macAdrr.uppercased()
            
            url = String(format: "%@?&clientAddr=%@", url, (environment?.miniGenieAddr!)! )
        }
        
        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("stopITV Successful")
                self.defaultBackground()
            case .failure(let error):
                print(error)
                self.failureBackground()
            }
        }
    }
    
    func getMemoryUsage(){
        
        let url = String(format: "%@itv/getLogs", (environment?.stbIP)!)
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).validate().responseString
            { response in
                if let status = response.response?.statusCode {
                    switch(status){
                    case 200:
                        print("getLogs success")
                    default:
                        print("error with response status: \(status)")
                    }
                }
                //to get JSON return value
                if let result = response.result.value {
                    let JSON = result as! String
                    self.parseMemoryResponse(body: JSON)
                    print(JSON)
                }
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.getMemoryUsage()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func parseMemoryResponse(body: String){
        
        let text = body
        
        if(text.range(of: "RAM memory: ") == nil){
            return
        }
        
        if(memoryInit < 0){
            let index1B = text.distance(from: text.startIndex, to: (text.range(of: "RAM memory: ")?.upperBound)!)
            let index1E = text.distance(from: text.startIndex, to: (text.range(of: " Bytes \n")?.lowerBound)!)
            
            let start = text.index(text.startIndex, offsetBy: index1B)
            let end = text.index(text.startIndex, offsetBy: index1E)
            
            let range1 = start..<end
            
            let t = text.substring(with: range1)
            memoryInit = Int(text.substring(with: range1))!
        }
        
        let index2B = text.distance(from: text.startIndex, to: (text.range(of: "RAM memory: ", options: String.CompareOptions.backwards)?.upperBound)!)
        let index2E = text.distance(from: text.startIndex, to: (text.range(of: " Bytes \n", options: String.CompareOptions.backwards)?.lowerBound)!)
        
        let start = text.index(text.startIndex, offsetBy: index2B)
        let end = text.index(text.startIndex, offsetBy: index2E)
        let range2 = start..<end
        
        let currentMemory = Int(text.substring(with: range2))
        
        let availableMem = 18000000
        
        let memoryUsage = (currentMemory! - memoryInit);
        
        memoryUsageLabel.text = String(currentMemory!/1000) + " kb"
        memoryUsageProgressView.setProgress(Float(currentMemory!) / Float(availableMem * 3/3), animated: true)
        
    }
    
    func successBackground(){
        UIView.animate(withDuration: 1.0, delay: 0.0, options:[], animations: {
            self.view.backgroundColor = UIColor(red: 0/255, green: 159/255, blue: 90/255, alpha: 1.0)
        }, completion:nil)
    }
    
    func failureBackground(){
        UIView.animate(withDuration: 1.0, delay: 0.0, options:[], animations: {
            self.view.backgroundColor = UIColor(red: 159/255, green: 17/255, blue: 17/255, alpha: 1.0)
        }, completion:nil)
    }
    
    func defaultBackground(){
        UIView.animate(withDuration: 1.0, delay: 0.0, options:[], animations: {
            self.view.backgroundColor = UIColor(red: 45/255, green: 170/255, blue: 222/255, alpha: 1.0) /* #2daade */
        }, completion:nil)
    }
    
    func startPulse(){
        defaultBackground()
        UIView.animate(withDuration: 1.0, delay: 0.0, options:[.repeat, .autoreverse], animations: {
            self.view.backgroundColor = UIColor(red: 31/255, green: 119/255, blue: 155/255, alpha: 1.0)
        }, completion:nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        self.persistChanges()
        return false
    }
}

