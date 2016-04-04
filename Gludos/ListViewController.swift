//
//  ListViewController.swift
//  Gludos
//
//  Created by Keaton Burleson on 4/1/16.
//  Copyright © 2016 Keaton Burleson. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class InsulinCell: UITableViewCell {
	@IBOutlet weak var insulinLabel: UILabel?
	@IBOutlet weak var carbLabel: UILabel?
	@IBOutlet weak var bloodSugarLabel: UILabel?
	@IBOutlet weak var dateLabel: UILabel?
	@IBOutlet weak var statusImage: UIImageView?

	enum TimeOfDay {
		case Morning
		case Noon
        case Afternoon
		case Night
	}

	func loadItem(glucose: String, carbs: String, insulin: String, time: TimeOfDay, date: NSDate) {

        
        let timeOfDay = self.determineFriendlyName(date)
		bloodSugarLabel?.text = glucose
		carbLabel?.text = "\(carbs) grams"
		insulinLabel?.text = "\(insulin) units"
		statusImage?.image = UIImage.init(named: "\(timeOfDay).png")
    
  
       
        dateLabel?.layer.cornerRadius = 10
        dateLabel?.layer.borderWidth = 1
        dateLabel?.layer.borderColor = UIColor.clearColor().CGColor
        dateLabel?.layer.backgroundColor = UIColor(hue: 275/360, saturation: 82/100, brightness: 92/100, alpha: 1.0).CGColor

		let formatter = NSDateFormatter()
		formatter.dateStyle = NSDateFormatterStyle.LongStyle
		formatter.timeStyle = .MediumStyle

		let dateString = formatter.stringFromDate(date)

		dateLabel?.text = dateString
        print("Time of Day: \(timeOfDay)")
		switch timeOfDay {
		case .Morning:
			self.backgroundColor = UIColor(hue: 60 / 360, saturation: 100 / 100, brightness: 99 / 100, alpha: 1.0)
			break
		case .Noon:
			self.backgroundColor = UIColor(hue: 130 / 360, saturation: 59 / 100, brightness: 100 / 100, alpha: 1.0)
			break
		case .Night:
			self.backgroundColor = UIColor(hue: 218 / 360, saturation: 78 / 100, brightness: 90 / 100, alpha: 1.0)
			break
        case .Afternoon:
            self.backgroundColor = UIColor(hue: 199/360, saturation: 86/100, brightness: 99/100, alpha: 1.0)
            break
		}
	}
	func determineFriendlyName(date: NSDate) -> TimeOfDay {
		let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: date)

	
        
        switch hour {
        case 6 ..< 12:
            return .Morning
        case 12:
            return .Noon
        case 13 ..< 17:
            return .Afternoon
        case 17 ..< 22:
            return .Night
        default:
            return .Night

            
            
        }
        
	}

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}

class ListViewController: UITableViewController {

	var allTheStuff = NSMutableArray()
	override func viewDidLoad() {
		super.viewDidLoad()
		if (NSUserDefaults.standardUserDefaults().objectForKey("stuff") == nil) {
			allTheStuff = NSMutableArray()
		} else {
            var temporary: NSArray = NSUserDefaults.standardUserDefaults().objectForKey("stuff") as! NSArray
            let descriptor: NSSortDescriptor = NSSortDescriptor(key: "time", ascending: false)
            temporary = temporary.sortedArrayUsingDescriptors([descriptor])
            allTheStuff = temporary.mutableCopy() as! NSMutableArray
            
            
        }
        
	}
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return allTheStuff.count
	}
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! InsulinCell
		let dictionary = allTheStuff.objectAtIndex(indexPath.row) as! NSMutableDictionary

		cell.loadItem(dictionary["glucose"] as! String, carbs: dictionary["carbs"] as! String, insulin: dictionary["insulin"] as! String, time: .Morning, date: dictionary["time"] as! NSDate)

		return cell
	}
    
    @IBAction func dismissYoSelf(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}