//
//  Constants.swift
//  SHEFreq
//
//  Created by clement perez on 12/28/16.
//  Copyright © 2016 clement perez. All rights reserved.
//

import Foundation

let kName : String = "name"
let kAppUrl : String = "appUrl"
let kServerIP : String = "serverIP"
let kStbIP : String = "stbIP"
let kDateCreated : String = "dateCreated"
let kMiniGenieAddr : String = "miniGenieAddr"


let kTarget : String = "target"
let kStatus : String = "status"
let kMemoryUsage : String = "memory"
let kIsGenie : String = "isMiniGenie"

let kStatusStarted : String = "started"
let kStatusStopped : String = "stopped"
let kStatusUnknown : String = "unknown"
let kStatusAvailable : String = "available"
let kStatusUnavailable : String = "unavailable"

let defaultEnviromentName : String = "New Configuration"
let defaultProdEnviromentName : String = "STB & Prod"
let defaultProdFullScreenEnviromentName : String = "STB & Prod & Minidock bypass"
let defaultDevEnviromentName : String = "STB & Dev"
let defaultQAEnviromentName : String = "STB & QA"
let defaultLocalEnviromentName : String = "STB & Local"
let defaultClearSessionName : String = "Clear Session"

let prodServerUrl : String = "http://prd-freq-att-stb.frequency.com:4006/"
let devServerUrl : String = "http://dev-freq-att-stb.frequency.com:4006/"
let qaServerUrl : String = "http://qa-freq-att-stb.frequency.com:4006/"
let localServerUrl : String = "http://192.168.1.1:4006/"

let defaultIPAdress : String = "http://192.168.1.1:8080/"
let defaultMiniGenieMacAddress : String = "a1:b2:c3:d4:e5"
let defaultAppUrl: String = "apps/freq/minidock.html"
let defaultClearSessionUrl: String = "apps/freq/clear-session.html"
let fullscreenAppUrl: String = "apps/freq/mfw-home.html?tms_id=EP014328710087&rating=TV-G&returnURL=minidock.html"

let defaultProdEnvironment : [String : String] = [
    kName : defaultProdEnviromentName,
    kServerIP : prodServerUrl,
    kStbIP : defaultIPAdress,
    kAppUrl : defaultAppUrl,
    kMiniGenieAddr : defaultMiniGenieMacAddress,
]

let defaultProdFullScreenEnvironment : [String : String] = [
    kName : defaultProdFullScreenEnviromentName,
    kServerIP : prodServerUrl,
    kStbIP : defaultIPAdress,
    kAppUrl : fullscreenAppUrl,
    kMiniGenieAddr : defaultMiniGenieMacAddress,
]

let defaultDevEnvironment : [String : String] = [
    kName : defaultDevEnviromentName,
    kServerIP : devServerUrl,
    kStbIP : defaultIPAdress,
    kAppUrl : defaultAppUrl,
    kMiniGenieAddr : defaultMiniGenieMacAddress,
]

let defaultQAEnvironment : [String : String] = [
    kName : defaultQAEnviromentName,
    kServerIP : qaServerUrl,
    kStbIP : defaultIPAdress,
    kAppUrl : defaultAppUrl,
    kMiniGenieAddr : defaultMiniGenieMacAddress,
]

let defaultLocalEnvironment : [String : String] = [
    kName : defaultLocalEnviromentName,
    kServerIP : localServerUrl,
    kStbIP : defaultIPAdress,
    kAppUrl : defaultAppUrl,
    kMiniGenieAddr : defaultMiniGenieMacAddress,
]

let defaultClearSession : [String : String] = [
    kName : defaultClearSessionName,
    kServerIP : localServerUrl,
    kStbIP : defaultIPAdress,
    kAppUrl : defaultClearSessionUrl,
    kMiniGenieAddr : defaultMiniGenieMacAddress,
]

let defaultNewEnvironment : [String : String] = [
    kName : defaultEnviromentName,
    kServerIP : prodServerUrl,
    kStbIP : defaultIPAdress,
    kAppUrl : defaultAppUrl,
    kMiniGenieAddr : defaultMiniGenieMacAddress,
]

let defaultEnvironments = [
    defaultProdFullScreenEnvironment,
    defaultProdEnvironment,
    defaultDevEnvironment,
    defaultQAEnvironment,
    defaultLocalEnvironment
]


