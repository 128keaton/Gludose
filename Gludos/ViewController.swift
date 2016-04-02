//
//  ViewController.swift
//  Gludos
//
//  Created by Keaton Burleson on 4/1/16.
//  Copyright © 2016 Keaton Burleson. All rights reserved.
//

import UIKit
import HealthKit
let healthKitStore: HKHealthStore = HKHealthStore()

class ViewController: UIViewController {

	var bloodGlucoseLevel = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)
    var carbohydratesLevel = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates)
	var insulinUnits: String?
	@IBOutlet var insulinAmountField: UITextField?
	@IBOutlet var carbAmountField: UITextField?
	@IBOutlet var glucoseLevelField: UITextField?
   
     private var preferredUnits = [NSObject : AnyObject]()
    
	override func viewDidLoad() {
		super.viewDidLoad()
        

		// Do any additional setup after loading the view, typically from a nib.
	}

	override func viewDidAppear(animated: Bool) {
		self.authorizeHealthKit(nil)
         let healthKitTypes = Set<HKQuantityType>(arrayLiteral: bloodGlucoseLevel!)
        healthKitStore.preferredUnitsForQuantityTypes(healthKitTypes as Set, completion: { (preferredUnits, error) -> Void in
            if (error == nil) {
                NSLog("...preferred units %@", preferredUnits)
                self.preferredUnits = preferredUnits
     
            }
        })
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	func saveData(time: NSDate, glucose: Double, carbs: Double, insulin: Double) {

		// 1. Create a BMI Sample

		let glucoseQuantity = HKQuantity(unit: unit!, doubleValue: glucose)
    
		let glucoseSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)!, quantity: glucoseQuantity, startDate: time, endDate: time)

		// 2. Save the sample in the store
		healthKitStore.saveObject(glucoseSample, withCompletion: { (success, error) -> Void in
			if (error != nil) {
				print("Error saving Glucose sample: \(error!.localizedDescription)")
			} else {
				print("Glucose  sample saved successfully!")
			}
		})
	}
	@IBAction func saveTheGlucose() {
		saveData(NSDate(), glucose: Double((glucoseLevelField?.text)!)!, carbs: Double((carbAmountField?.text)!)!, insulin: Double((insulinAmountField?.text)!)!)
		print("saving glucose and the gang")
	}

	func authorizeHealthKit(completion: ((success: Bool, error: NSError!) -> Void)!)
	{
		// 1. Set the types you want to read from HK Store
		let healthRead = NSSet(object:bloodGlucoseLevel, carbo!)

		let healthWrite = NSSet(object: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)!)

		// 2. Set the types you want to write to HK Store

		// 3. If the store is not available (for instance, iPad) return an error and don't go on.
		if !HKHealthStore.isHealthDataAvailable()
		{
			let error = NSError(domain: "com.bittank.Gludos.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available in this Device"])
			if (completion != nil)
			{
				completion(success: false, error: error)
			}
			return;
		}

		// 4.  Request HealthKit authorization
		healthKitStore.requestAuthorizationToShareTypes(healthWrite as? Set<HKSampleType>, readTypes: healthRead as? Set<HKObjectType>) { (success, error) -> Void in

			if (completion != nil)
			{
				completion(success: success, error: error)
			}
		}
	}
}

