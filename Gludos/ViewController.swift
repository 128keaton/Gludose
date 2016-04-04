//
//  ViewController.swift
//  Gludos
//
//  Created by Keaton Burleson on 4/1/16.
//  Copyright © 2016 Keaton Burleson. All rights reserved.
//

import UIKit
import HealthKit
import SwiftOverlays

let healthKitStore: HKHealthStore = HKHealthStore()

class ViewController: UIViewController, UITextFieldDelegate {

    let limitLength = 3
    
	private var objects = [HKQuantityType!]()
	private var preferredUnits = [NSObject: AnyObject]()
	private var healthStore = HKHealthStore()

	var allTheStuff = NSMutableArray()

	@IBOutlet var insulinAmountField: UITextField?
	@IBOutlet var carbAmountField: UITextField?
	@IBOutlet var glucoseLevelField: UITextField?

	@IBOutlet var annoyingNotificationView: UIView?
	@IBOutlet var savedIconStatus: UIImageView?

	@IBOutlet var goButton: UIButton?

	override func viewDidLoad() {
		super.viewDidLoad()
		if (NSUserDefaults.standardUserDefaults().objectForKey("stuff") == nil) {
			allTheStuff = NSMutableArray()
		} else {
			allTheStuff = NSUserDefaults.standardUserDefaults().objectForKey("stuff")?.mutableCopy() as! NSMutableArray
		}

		// Do any additional setup after loading the view, typically from a nib.
	}

	override func viewDidAppear(animated: Bool) {
		self.authorizeHealthKit(nil)
		let carbs = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates)
		let bloodGlucose = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)
		let healthKitTypes = Set<HKQuantityType>(arrayLiteral: carbs!, bloodGlucose!)
		healthKitStore.preferredUnitsForQuantityTypes(healthKitTypes as Set, completion: { (preferredUnits, error) -> Void in
			if (error == nil) {
				NSLog("...preferred units %@", preferredUnits)
				self.preferredUnits = preferredUnits
			}
		})
	}

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= limitLength
    }
    
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	func saveData(time: NSDate, glucose: Double, carbs: Double, insulin: Double) {

		// 1. Create a BMI Sample

		let glucoseQuantity = HKQuantity(unit: preferredUnits[HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)!] as! HKUnit, doubleValue: glucose)

		let glucoseSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)!, quantity: glucoseQuantity, startDate: time, endDate: time)

		let carbQuantity = HKQuantity(unit: preferredUnits[HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates)!] as! HKUnit, doubleValue: carbs)

		let carbSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates)!, quantity: carbQuantity, startDate: time, endDate: time)

		// 2. Save the sample in the store
		healthKitStore.saveObjects([glucoseSample, carbSample], withCompletion: { (success, error) -> Void in
			if (error != nil) {
				print("Error saving Glucose sample: \(error!.localizedDescription)")
			} else {
				print("Glucose  sample saved successfully!")
			}
		})
	}
	func checkIfTextExists(field: UITextField) -> Bool {
		if field.text == "" {
			field.layer.borderColor = UIColor.redColor().CGColor
			field.layer.borderWidth = 1
			field.layer.cornerRadius = 5
			return false
		}
		return true
	}
	@IBAction func saveTheGlucose() {

		var shouldContinue = true
		for field in self.view.subviews {
			if field is UITextField {
				if (checkIfTextExists(field as! UITextField) == false) {
					shouldContinue = false
				}
			}
		}

		if (shouldContinue == true) {
			saveData(NSDate(), glucose: Double((glucoseLevelField?.text)!)!, carbs: Double((carbAmountField?.text)!)!, insulin: Double((insulinAmountField?.text)!)!)

			let biscuit: NSMutableDictionary = ["glucose": (glucoseLevelField?.text)!, "carbs": (carbAmountField?.text)!, "insulin": (insulinAmountField?.text)!, "time": NSDate()]
			allTheStuff.addObject(biscuit)
			NSUserDefaults.standardUserDefaults().setObject(allTheStuff, forKey: "stuff")
			NSUserDefaults.standardUserDefaults().synchronize()

			NSBundle.mainBundle().loadNibNamed("AnnoyingNotification", owner: self, options: nil)
			annoyingNotificationView!.frame.size.width = self.view.bounds.width;
			savedIconStatus?.image = self.determineFriendlyName(NSDate())

			UIViewController.showNotificationOnTopOfStatusBar(annoyingNotificationView!, duration: 5)
			self.clearText()

			if (NSUserDefaults.standardUserDefaults().boolForKey("notif") == true) {
				let notification = UILocalNotification()
				notification.alertBody = "Have you logged your glucose?" // text that will be displayed in the notification
				notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
				notification.fireDate = NSDate().dateByAddingTimeInterval(5.0 * 60.0)
				notification.soundName = UILocalNotificationDefaultSoundName // play default sound
				notification.userInfo = ["UUID": NSDate(),] // assign a unique identifier to the notification so that we can retrieve it later
				notification.category = "TODO_CATEGORY"
				UIApplication.sharedApplication().scheduleLocalNotification(notification)
			}

			print("saving glucose and the gang")
		}
	}
	func clearText() {
        for field in self.view.subviews {
            if field is UITextField {
                let field = field as! UITextField
                field.layer.borderColor = UIColor.clearColor().CGColor
                field.text = ""
                field.resignFirstResponder()
            }
        }
	}

	func determineFriendlyName(date: NSDate) -> UIImage {
		let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: date)

		switch hour {
		case 6 ..< 12:
			return UIImage.init(named: "Morning.png")!
		case 12:
			return UIImage.init(named: "Noon.png")!
		case 13 ..< 17:
			return UIImage.init(named: "Afternoon.png")!
		case 17 ..< 22:
			return UIImage.init(named: "Night.png")!
		default:
			return UIImage()
		}
	}

	func authorizeHealthKit(completion: ((success: Bool, error: NSError!) -> Void)!)
	{
		let carbs = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates)
		let bloodGlucose = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)

		let healthKitTypes = Set<HKQuantityType>(arrayLiteral: carbs!, bloodGlucose!)

		self.healthStore.requestAuthorizationToShareTypes(healthKitTypes as Set, readTypes: healthKitTypes as Set) { (success, error) -> Void in
			if (success) {
				NSLog("HealthKit authorization success...")

				self.healthStore.preferredUnitsForQuantityTypes(healthKitTypes as Set, completion: { (preferredUnits, error) -> Void in
					if (error == nil) {
						NSLog("...preferred units %@", preferredUnits)
						self.preferredUnits = preferredUnits
					}
				})
			}
		}

		self.objects = [carbs, bloodGlucose]
	}
}