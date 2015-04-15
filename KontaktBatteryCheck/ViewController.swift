//
//  ViewController.swift
//  KontaktBatteryCheck
//
//  Created by Hatch on 08/12/2014.
//  Copyright (c) 2014 Hatch. All rights reserved.
//

import UIKit
import CoreBluetooth

struct beacon {
    var name:NSString
    var rssi:NSNumber
    var power:Int
}

class ViewController: UIViewController, CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var centralManager: CBCentralManager!
    var beacons: [beacon] = []

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }

    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
        println("did update state")
        
        if central.state == CBCentralManagerState.PoweredOn {
            self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
        }
        
    }
    
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI rssi: NSNumber!) {
      
      if peripheral.name != "Kontakt" { return }
      let serviceData = advertisementData[ CBAdvertisementDataServiceDataKey ] as! Dictionary<CBUUID, NSData>
      if let nameAndPower = serviceData[ CBUUID(string:"D00D") ] {
      
        let name = NSString(data: nameAndPower.subdataWithRange(NSMakeRange(0, 4)), encoding: NSASCIIStringEncoding)!
        var power: Int = 0;
        nameAndPower.getBytes(&power, range: NSMakeRange(6, 1))
        
        println( "\(name) \(power)%" )
        beacons.append( beacon(name: name, rssi: rssi, power: power) )
        refreshTableView()
      }
    }
    
    func refreshTableView() {
        
        activityIndicator.stopAnimating()
        beacons.sort { (lhs, rhs) in return lhs.rssi.integerValue > rhs.rssi.integerValue }
        tableView.reloadData()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return beacons.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("beaconCell", forIndexPath: indexPath) as! UITableViewCell

        if let nameLabel = cell.viewWithTag(1) as? UILabel {
            nameLabel.text = beacons[indexPath.row].name as String
        }
        
        if let rssiLabel = cell.viewWithTag(2) as? UILabel {
            rssiLabel.text = "rssi: \(beacons[indexPath.row].rssi)"
        }
        
        
        if let powerLabel = cell.viewWithTag(3) as? UILabel { 
            powerLabel.text = "\(beacons[indexPath.row].power)%"
        }

        return cell
        
    }


}

