//
//  SettingsViewController.swift
//  Gludos
//
//  Created by Keaton Burleson on 4/2/16.
//  Copyright © 2016 Keaton Burleson. All rights reserved.
//

import Foundation
import UIKit
class SettingsViewController: UITableViewController {
	@IBOutlet var notificationSwitch: UISwitch?

	override func viewDidLoad() {
		super.viewDidLoad()

		notificationSwitch?.setOn(NSUserDefaults.standardUserDefaults().boolForKey("notif"), animated: false)
	}

	@IBAction func dismissYoSelf() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if (indexPath.row == 1) {
			self.deleteAll()
        }else{
            
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
	}

	override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		if (indexPath.row != 1) {
			return nil
		}
		return indexPath
	}

	@IBAction func switchChanged(sender: UISwitch) {
		print("changed")
		NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: "notif")
		NSUserDefaults.standardUserDefaults().synchronize()
	}
	@IBAction func deleteAll() {
		let controller = UIAlertController.init(title: "Delete all?", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)

		let yesButton = UIAlertAction.init(title: "Yes", style: UIAlertActionStyle.Destructive, handler: { (action) in
			NSUserDefaults.standardUserDefaults().removeObjectForKey("stuff")
			NSUserDefaults.standardUserDefaults().synchronize()
		})
		let noButton = UIAlertAction.init(title: "No", style: UIAlertActionStyle.Cancel, handler: { (action) in
			controller.dismissViewControllerAnimated(true, completion: nil)
		})
		controller.addAction(noButton)
		controller.addAction(yesButton)
		self.presentViewController(controller, animated: true, completion: nil)
	}
}