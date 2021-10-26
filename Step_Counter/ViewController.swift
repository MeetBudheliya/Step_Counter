//
//  ViewController.swift
//  Step_Counter
//
//  Created by Adsum MAC 1 on 26/10/21.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

    @IBOutlet weak var stepCount: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    var healthStore = HKHealthStore()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        img.layer.cornerRadius = 10
        
       
        let typesToShare = Set([
                HKObjectType.workoutType(),
                                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!])

            let typesToRead = Set([
                                    HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!])
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { auth, error in
            guard error == nil else{
                self.popup(msg: error!.localizedDescription)
                return
            }
        }
        
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateStep), userInfo: nil, repeats: true)
    }

    @objc func updateStep(){
        updateSteps { i in
            print(i)
            DispatchQueue.main.async {
                self.stepCount.text = "\(Int(i))"
            }
        }
    }


    
    func updateSteps(completion: @escaping (Double) -> Void) {
            let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

            let now = Date()
            let startOfDay = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

            let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
                var resultCount = 0.0

                guard let result = result else {
                    print("\(String(describing: error?.localizedDescription)) ")
                    completion(resultCount)
                    return
                }

                if let sum = result.sumQuantity() {
                    resultCount = sum.doubleValue(for: HKUnit.count())
                }

                DispatchQueue.main.async {
                    completion(resultCount)
                }
            }

            healthStore.execute(query)
        }
}


// MARK: popup
extension UIViewController{
    func popup(msg:String){
        let alertpopup = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(dismissAlert(timer:)), userInfo: nil, repeats: false)
        self.present(alertpopup, animated: true, completion: nil)
    }
    
    @objc func dismissAlert(timer:Timer){
        self.dismiss(animated: true, completion: nil)
        timer.invalidate()
    }
    
}

