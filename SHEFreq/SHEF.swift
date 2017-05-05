//
//  SHEF.swift
//  SHEFreq
//
//  Created by clement perez on 2/13/17.
//  Copyright © 2017 clement perez. All rights reserved.
//

import Foundation
import Alamofire

class SHEF{
    
    static func start(environment : Environment,
               miniGenieMacAddress : String,
               success succeed: (() -> ())? = nil,
               failure fail : ((NSError) -> ())? = nil){
        
        let appPath = (environment.appUrl!).addingPercentEncoding(withAllowedCharacters: .nonBaseCharacters)
        
        var url = String(format: "%@itv/startURL?url=%@%@", (environment.stbIP!), (environment.serverIP!), appPath!)
        
        if(miniGenieMacAddress.characters.count > 0){
            var macAdrr = miniGenieMacAddress
            macAdrr = macAdrr.uppercased()
            macAdrr = macAdrr.replacingOccurrences(of: ":", with: "", options: NSString.CompareOptions.literal, range:nil)
            url = String(format: "%@?&clientAddr=%@", url, macAdrr )
        }
        
        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success:
                succeed!();
            case .failure(let error):
                print(error)
                fail;
            }
        }
    }
    
    static func clear(environment : Environment,
                      miniGenieMacAddress : String,
                      success succeed: (() -> ())? = nil,
                      failure fail : ((NSError) -> ())? = nil){
        
        let appPath = (defaultClearSessionUrl).addingPercentEncoding(withAllowedCharacters: .nonBaseCharacters)
        
        var url = String(format: "%@itv/startURL?url=%@%@", (environment.stbIP!), (environment.serverIP!), appPath!)
        
        if(miniGenieMacAddress.characters.count > 0){
            var macAdrr = miniGenieMacAddress
            macAdrr = macAdrr.uppercased()
            macAdrr = macAdrr.replacingOccurrences(of: ":", with: "", options: NSString.CompareOptions.literal, range:nil)
            url = String(format: "%@?&clientAddr=%@", url, macAdrr )
        }
        
        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success:
                succeed!();
            case .failure(let error):
                print(error)
                fail;
            }
        }
    }
    
    static func test(environment : Environment,
                     miniGenieMacAddress : String,
                     success : (String) -> Void,
                     failure : (NSError) -> Void){
        
        let url = String(format: "%@itv/getLogs", (environment.stbIP)!)
        
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
                    print(JSON)
                }
        }
    }
    
    static func stop(environment : Environment,
                     miniGenieMacAddress : String,
                     success : @escaping (String) -> Void,
                     failure : (NSError) -> Void){
        
        var url = String(format: "%@itv/stopITV", (environment.stbIP)!)
        
        if(miniGenieMacAddress.characters.count > 0){
            var macAdrr = miniGenieMacAddress
            macAdrr = macAdrr.uppercased()
            
            url = String(format: "%@?&clientAddr=%@", url, macAdrr )
        }
        
        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("stopITV Successful")
                success("")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func getMemoryUsage(environment : Environment,
                        miniGenieMacAddress : String,
                        success : @escaping (Int) -> Void,
                        failure : (NSError) -> Void){
        
        var url = String(format: "%@itv/getLogs", (environment.stbIP)!)
        
        if(miniGenieMacAddress.characters.count > 0){
            var macAdrr = miniGenieMacAddress
            macAdrr = macAdrr.uppercased()
            
            url = String(format: "%@?&clientAddr=%@", url, macAdrr )
        }
        
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
                    let JSON = result
                    let mem = parseMemoryResponse(body: JSON)
                    success(mem)
                }
        }
    }
    
    static func ping(environment : Environment,
                               miniGenieMacAddress : String,
                               success : @escaping (Void) -> Void,
                               failure : @escaping (NSError) -> Void){
        
        let url = String(format: "%@itv/getLogs", (environment.stbIP)!)
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).validate().responseString
            { response in
                if let status = response.response?.statusCode {
                    switch(status){
                    case 200:
                        success()
                    default:
                        failure(NSError())
                    }
                }else{
                
                failure(NSError())
                }
        }
    }
    
    static func parseMemoryResponse(body: String) -> Int{
        
        let text = body
        
        if(text.range(of: "RAM memory: ") == nil){
            return -1;
        }
        
        let index2B = text.distance(from: text.startIndex, to: (text.range(of: "RAM memory: ", options: String.CompareOptions.backwards)?.upperBound)!)
        let index2E = text.distance(from: text.startIndex, to: (text.range(of: " Bytes \n", options: String.CompareOptions.backwards)?.lowerBound)!)
        
        let start = text.index(text.startIndex, offsetBy: index2B)
        let end = text.index(text.startIndex, offsetBy: index2E)
        let range2 = start..<end
        
        let currentMemory = Int(text.substring(with: range2))
        return currentMemory!;
    }
}
