//
//  HealthKitDataItem.swift
//  healthKitExamples
//
//  Created by 서민영 on 2023/08/29.
//

import HealthKit
import CoreMotion

class HealThKitDataItem{
    let healthStore = HKHealthStore()
    var walkCounts: Double = 0.0
    @objc func getwalkCount(){
        guard let walkCount = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: walkCount, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_,result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("nono")
                return
            }
            DispatchQueue.main.async {
                var counts = sum.doubleValue(for: HKUnit.count())
                print("걸음\(counts)")
//                self.walkCounts = counts
//                self.walkCountLabel.text = String(format:"%.0f",counts) + "걸음"
                self.walkCounts = counts
                print("걸음1\(self.walkCounts)")
            }
        }
        healthStore.execute(query)
    }
}
