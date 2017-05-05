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

class DetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    //@IBOutlet var appUrlTextField: UITextField!
    @IBOutlet var appUrlTextView: UITextView!
    @IBOutlet var appUrlView: UIView!
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
    
    var session: Session? {
        didSet {
            self.configureView()
        }
    }
    
    var environment: Environment? {
        return self.session?.target
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let environment = self.environment {
            if let label = self.appUrlTextView {
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
        if let session = self.session{
            if(session.status == kStatusStarted){
                successBackground()
                startTimer()
            }
            else if(session.status == kStatusUnavailable){
                failureBackground()
            }else{
                defaultBackground()
            }
            
            if let switchMG = self.miniGenieSwitch{
                switchMG.setOn(session.isMiniGenie, animated: false)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        //appUrlTextField.delegate = self
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
        environment?.appUrl = appUrlTextView.text
        environment?.serverIP = serverIPTextField.text
        environment?.name = nameTextField.text
        environment?.stbIP = stbIPTextField.text
        environment?.miniGenieAddr = miniGenieAddr.text
        
        session?.isMiniGenie = miniGenieSwitch.isOn
        
        do {
            try managedObjectContext?.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func startClicked(_ sender: Any) {
        persistChanges()
        startPulse()
        
        SHEF.stop(environment: environment!,
                  miniGenieMacAddress: miniGenieSwitch.isOn ? (environment?.miniGenieAddr!)! : "",
                  success: {_ in
                    
                    SHEF.start(environment: self.environment!,
                               miniGenieMacAddress: self.miniGenieSwitch.isOn ? (self.environment?.miniGenieAddr!)! : "",
                               success: {_ in
                                self.session?.status = kStatusStarted
                                self.successBackground()
                                self.getMemoryUsage()
                                self.startTimer()
                    },
                               failure: {(error : NSError) -> () in
                                print(error)
                                self.session?.status = kStatusUnavailable
                                self.failureBackground()
                                self.stopTimer()
                    })
        },
                  failure: {(error : NSError) -> () in
                    print(error)
                    self.session?.status = kStatusUnavailable
                    self.failureBackground()
        })
    }
    
    @IBAction func stopClicked(_ sender: Any) {
        persistChanges()
        startPulse()
        self.stopTimer()
        
        memoryUsageLabel.text = "NA"
        memoryUsageProgressView.setProgress(0, animated: true)
        
        SHEF.stop(environment: environment!,
                   miniGenieMacAddress: miniGenieSwitch.isOn ? (environment?.miniGenieAddr!)! : "",
                   success: {_ in
                    self.session?.status = kStatusAvailable
                    self.defaultBackground()
        },
                   failure: {(error : NSError) -> () in
                    print(error)
                    self.session?.status = kStatusUnavailable
                    self.failureBackground()
        })
    }
    
    @IBAction func clearClicked(_ sender: Any) {
        startPulse()
        
        self.stopTimer()
        
        memoryUsageLabel.text = "NA"
        memoryUsageProgressView.setProgress(0, animated: true)
        
        SHEF.clear(environment: environment!,
                  miniGenieMacAddress: miniGenieSwitch.isOn ? (environment?.miniGenieAddr!)! : "",
                  success: {_ in
                    self.session?.status = kStatusAvailable
                    self.defaultBackground()
        },
                  failure: {(error : NSError) -> () in
                    print(error)
                    self.session?.status = kStatusUnavailable
                    self.failureBackground()
        })
    }
    
    func getMemoryUsage(){
        
        SHEF.getMemoryUsage(environment: environment!,
                            miniGenieMacAddress: miniGenieSwitch.isOn ? (environment?.miniGenieAddr!)! : "",
                            success: {(mem : Int) -> () in
                                self.updateMemoryText(memoryUsage: mem)
        },
                            failure: {(error : NSError) -> () in
                                print(error)
        })
    }
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.getMemoryUsage()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func updateMemoryText(memoryUsage: Int){
        
        let currentMemory = memoryUsage
        
        let availableMem = 18000000
        
        memoryUsageLabel.text = String(describing: currentMemory/1000) + " kb"
        memoryUsageProgressView.setProgress(Float(currentMemory) / Float(availableMem * 3/3), animated: true)
        
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
    

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n")
        {
            textView.resignFirstResponder()
            self.view.endEditing(true)
            self.persistChanges()
            return false;
        }
        
        return true;
    }

    
    
    func textViewDidChange(_ textView: UITextView){
        //textView.sizeToFit()
    }
}

