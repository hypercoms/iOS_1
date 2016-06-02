//
//  Thing.swift
//  IoT_AWS1
//
//  Created by TKT_SS9_43 on 31/05/2016.
//  Copyright © 2016 Hyper. All rights reserved.
//

import UIKit
import AWSIoT
import SwiftyJSON



let statusThingName="PCduino1"
let controlThingName="PCduino1"

class ThingViewController: UIViewController {
    
    
    var statusThingOperationInProgress:  Bool = false;
    var controlThingOperationInProgress: Bool = false;
    weak var setupTimer: NSTimer?;
    let cellIdentifier = "CellIdentifier"
    var iotDataManager: AWSIoTDataManager!;
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("huhuhu")
        
        //
        // Init IOT
        //
        iotDataManager = AWSIoTDataManager.defaultIoTDataManager()
        
        #if DEMONSTRATE_LAST_WILL_AND_TESTAMENT
            //
            // Set a Last Will and Testament message in the MQTT configuration; other
            // clients can subscribe to this topic, and if this client disconnects from
            // from AWS IoT unexpectedly, they will receive the message defined here.
            // Note that this is optional; your application may not need to specify a
            // Last Will and Testament.
            //
            // To enable this code, add '-DDEMONSTRATE_LAST_WILL_AND_TESTAMENT' to
            // your project build flags in:
            //
            //    Build Settings -> Swift Compiler - Custom Flags -> Other Swift Flags
            //
            // IMPORTANT NOTE FOR SWIFT PROGRAMS: When specifying the Last Will and Testament
            // message in Swift, make sure to use the NSString data type; this object must
            // support the dataUsingEncoding selector, which is not available in Swift's
            // native String type.
            //
            let lwtTopic: NSString = "temperature-control-last-will-and-testament"
            let lwtMessage: NSString = "disconnected"
            self.iotDataManager.mqttConfiguration.lastWillAndTestament.topic = lwtTopic as String
            self.iotDataManager.mqttConfiguration.lastWillAndTestament.message = lwtMessage as String
            self.iotDataManager.mqttConfiguration.lastWillAndTestament.qos = .AtMostOnce
        #endif
        
        //
        // Connect via WebSocket
        //
        self.iotDataManager.connectUsingWebSocketWithClientId( NSUUID().UUIDString, cleanSession:true, statusCallback: mqttEventCallback)
        
        //
        // Wait a few seconds and then subscribe to the special thing shadow topics.
        //
        
        setupTimer = NSTimer.scheduledTimerWithTimeInterval( 2.5, target: self, selector: #selector(ThingViewController.subscribeSpecialTopics), userInfo: nil, repeats: false )
        
        //
        // Two seconds after subscribing to all the special topics, retrieve the current thing states.
        //
        NSTimer.scheduledTimerWithTimeInterval( 4.5, target: self, selector: #selector(ThingViewController.getThingStates), userInfo: nil, repeats: false )
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        cell.textLabel?.text = "ss9 tkt"
        
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView .deselectRowAtIndexPath(indexPath, animated: true)
        NSLog("sapuy")
        self.performSegueWithIdentifier("ShowThingVC", sender: indexPath);
        
    }
    
    
    //thing
    
    func updateThingShadow( thingName: String, jsonData: JSON )
    {
        self.iotDataManager.publishString( jsonData.rawString(), onTopic: "$aws/things/\(thingName)/shadow/update", qoS:.MessageDeliveryAttemptedAtMostOnce);
    }
    
    
    
    
    func getThingState( thingName: String )
    {
        self.iotDataManager.publishString( "{ }", onTopic: "$aws/things/\(thingName)/shadow/get", qoS:.MessageDeliveryAttemptedAtMostOnce);
    }
    
    
    
    
    func thingShadowDeltaCallback( thingName: String, json: JSON, payloadString: String ) -> Void {
        if (thingName == controlThingName)
        {
            //            updateControl( json["state"]["setPoint"].int,
            //                           enabled: json["state"]["enabled"].bool );
        }
        else   // thingName == statusThingName
        {
            //            updateStatus( json["state"]["intTemp"].int,
            //                          exteriorTemperature: json["state"]["extTemp"].int,
            //                          state: json["state"]["curState"].string );
        }
    }
    func thingShadowAcceptedCallback( thingName: String, json: JSON, payloadString: String ) -> Void {
        if (thingName == controlThingName)
        {
            //            updateControl( json["state"]["desired"]["setPoint"].int,
            //                           enabled: json["state"]["desired"]["enabled"].bool );
            //            controlThingOperationInProgress = false;
        }
        else   // thingName == statusThingName
        {
            //            updateStatus( json["state"]["desired"]["intTemp"].int,
            //                          exteriorTemperature: json["state"]["desired"]["extTemp"].int,
            //                          state: json["state"]["desired"]["curState"].string );
            //            statusThingOperationInProgress = false;
        }
    }
    func thingShadowRejectedCallback( thingName: String, json: JSON, payloadString: String ) -> Void {
        if (thingName == controlThingName)
        {
            controlThingOperationInProgress = false;
        }
        else   // thingName == statusThingName
        {
            statusThingOperationInProgress = false;
        }
        print("operation rejected on: \(thingName)")
    }
    func getThingStates() {
        getThingState(statusThingName)
        getThingState(controlThingName)
    }
    func dispatchSpecialTopic(thingName: String, payload: NSData, callback: ( String, JSON, String ) -> Void) {
        let stringValue = NSString(data: payload, encoding: NSUTF8StringEncoding)!
        
        print("received: \(stringValue)")
        let json = JSON(data: payload as NSData!)
        
        dispatch_async(dispatch_get_main_queue()) {
            callback( thingName, json, stringValue as String );
        }
    }
    func subscribeSpecialTopics() {
        let things = [String]( arrayLiteral: statusThingName, controlThingName );
        
        for thing in things
        {
            self.iotDataManager.subscribeToTopic("$aws/things/\(thing)/shadow/update/accepted", qoS: .MessageDeliveryAttemptedAtMostOnce, messageCallback: {
                (payload) ->Void in
                self.dispatchSpecialTopic( thing, payload: payload, callback: self.thingShadowAcceptedCallback );
            })
            self.iotDataManager.subscribeToTopic("$aws/things/\(thing)/shadow/update/rejected", qoS: .MessageDeliveryAttemptedAtMostOnce, messageCallback: {
                (payload) ->Void in
                self.dispatchSpecialTopic( thing, payload: payload, callback: self.thingShadowRejectedCallback );
            })
            self.iotDataManager.subscribeToTopic("$aws/things/\(thing)/shadow/get/accepted", qoS: .MessageDeliveryAttemptedAtMostOnce, messageCallback: {
                (payload) ->Void in
                self.dispatchSpecialTopic( thing, payload: payload, callback: self.thingShadowAcceptedCallback );
            })
            self.iotDataManager.subscribeToTopic("$aws/things/\(thing)/shadow/get/rejected", qoS: .MessageDeliveryAttemptedAtMostOnce, messageCallback: {
                (payload) ->Void in
                self.dispatchSpecialTopic( thing, payload: payload, callback: self.thingShadowRejectedCallback );
            })
        }
    }
    func mqttEventCallback( status: AWSIoTMQTTStatus )
    {
        dispatch_async( dispatch_get_main_queue()) {
            print("connection status = \(status.rawValue)")
            switch(status)
            {
            case .Connecting:
                print( "Connecting..." )
                
            case .Connected:
                print( "Connected" )
                
            case .Disconnected:
                print( "Disconnected" )
                
            case .ConnectionRefused:
                print( "Connection Refused" )
                
            case .ConnectionError:
                print( "Connection Error" )
                
            case .ProtocolError:
                print( "Protocol Error" )
                
            default:
                print("unknown state: \(status.rawValue)")
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}

