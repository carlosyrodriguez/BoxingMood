// HealthKitManager.swift
import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()

    @Published var heartRate: Double = 0
    @Published var activeCalories: Double = 0
    @Published var isWorkoutActive = false

    init() {
        requestAuthorization()
    }

    func requestAuthorization() {
        let typesToShare: Set = [
            HKObjectType.workoutType()
        ]

        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.workoutType()
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if !success {
                // Handle error
                print("HealthKit Authorization Failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

}
