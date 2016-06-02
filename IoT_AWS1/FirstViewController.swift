//
//  FirstViewController.swift
//  IoT_AWS1
//
//  Created by TKT_SS9_43 on 20/05/2016.
//  Copyright © 2016 Hyper. All rights reserved.
//

import UIKit



class FirstViewController: UIViewController {
 

    let cellIdentifier = "CellIdentifier"

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        // Init IOT
        //
        
        
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
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    


}

