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

class ViewController: UIViewController, UITextFieldDelegate {

    private var objects = [HKQuantityType!]()
    private var preferredUnits = [NSObject : AnyObject]()
    private var healthStore = HKHealthStore()
    
    var allTheStuff = NSMutableArray()
    
	@IBOutlet var insulinAmountField: UITextField?
	@IBOutlet var carbAmountField: UITextField?
	@IBOutlet var glucoseLevelField: UITextField?
   
    
	override func viewDidLoad() {
		super.viewDidLoad()
        if(NSUserDefaults.standardUserDefaults().objectForKey("stuff") == nil){
            allTheStuff = NSMutableArray()
        }else{
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
	@IBAction func saveTheGlucose() {
		saveData(NSDate(), glucose: Double((glucoseLevelField?.text)!)!, carbs: Double((carbAmountField?.text)!)!, insulin: Double((insulinAmountField?.text)!)!)
        
        let biscuit: NSMutableDictionary = ["glucose" : (glucoseLevelField?.text)!, "carbs" : (carbAmountField?.text)!, "insulin" : (insulinAmountField?.text)!, "time" : NSDate()]
        allTheStuff.addObject(biscuit)
        NSUserDefaults.standardUserDefaults().setObject(allTheStuff, forKey: "stuff")
        NSUserDefaults.standardUserDefaults().synchronize()
        
		print("saving glucose and the gang")
	}
    func clearText(){
        
    }

	func authorizeHealthKit(completion: ((success: Bool, error: NSError!) -> Void)!)
	{
        let carbs = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates)
        let bloodGlucose = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)
        
        let healthKitTypes = Set<HKQuantityType>(arrayLiteral: carbs!, bloodGlucose!)
        
        self.healthStore.requestAuthorizationToShareTypes(healthKitTypes as Set, readTypes:healthKitTypes as Set) { (success, error) -> Void in
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