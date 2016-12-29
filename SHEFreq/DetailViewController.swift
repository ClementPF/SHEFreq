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

class DetailViewController: UIViewController {

    @IBOutlet weak var appUrlTextField: UITextField!
    @IBOutlet weak var serverIPTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var stbIPTextField: UITextField!
    
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
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
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
        
        let url = String(format: "%@itv/startURL?url=%@%@", (environment?.stbIP!)!, (environment?.serverIP!)!, (environment?.appUrl!)!)
        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success:
                
                let red   = Float((arc4random() % 256)) / 255.0
                let green = Float((arc4random() % 256)) / 255.0
                let blue  = Float((arc4random() % 256)) / 255.0
                let alpha = Float(1.0)
                
                UIView.animate(withDuration: 1.0, delay: 0.0, options:[.repeat, .autoreverse], animations: {
                    self.view.backgroundColor = UIColor(colorLiteralRed: 0, green: 1, blue: 0, alpha: alpha)
                }, completion:nil)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func testClicked(_ sender: Any) {
        persistChanges()
        
        let url = String(format: "%@itv/getLogs", (environment?.stbIP)!)
        
        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func stopClicked(_ sender: Any) {
        persistChanges()
        
        let url = String(format: "%@itv/stopITV", (environment?.stbIP)!)
        
        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
            case .failure(let error):
                print(error)
            }
        }
    }
}

