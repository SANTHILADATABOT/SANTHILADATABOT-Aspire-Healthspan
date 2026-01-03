import Foundation
import HealthKit

class HealthKitBridge {
    static let shared = HealthKitBridge()
    let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
            // add others only if you truly need them
        ]
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            completion(success, error)
        }
    }

    func fetchRecentHeartRateSample(limit: Int = 10, completion: @escaping ([[String:Any]]?, Error?) -> Void) {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(nil, nil)
            return
        }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: hrType, predicate: nil, limit: limit, sortDescriptors: [sort]) { (_, samplesOrNil, error) in
            guard let samples = samplesOrNil as? [HKQuantitySample] else {
                completion(nil, error)
                return
            }
            let results = samples.map { sample -> [String:Any] in
                let bpm = sample.quantity.doubleValue(for: HKUnit.init(from: "count/min"))
                let start = sample.startDate.timeIntervalSince1970
                return ["bpm": bpm, "timestamp": start]
            }
            completion(results, nil)
        }
        healthStore.execute(query)
    }
}
