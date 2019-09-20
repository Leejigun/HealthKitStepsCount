//
//  HealthKitManager.swift
//  HealthKitStepsCount
//
//  Created by 이지건 on 02/09/2019.
//  Copyright © 2019 이지건. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitManager {
    
    let healthStore = HKHealthStore()
    
    static var instance: HealthKitManager?
    
    /// 싱글톤 인스턴스
    static var sharedInstance: HealthKitManager {
        get {
            if let instance = HealthKitManager.instance {
                return instance
            } else {
                let manager = HealthKitManager()
                HealthKitManager.instance = manager
                return manager
            }
        }
    }
    
    /// 권한 요청
    ///
    /// - Parameter finish: 권한 요청 결과
    func requestReadingPermission(finish: @escaping (Error?) -> Void) {
        
        guard let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount)
            else {
                finish(NSError(domain: "guard let fail", code: 0, userInfo: nil))
                return
        }
            let readType: Set<HKObjectType> = [stepCount]
        healthStore.requestAuthorization(toShare: nil,
                                         read: readType) { (success, error) in
                                            DispatchQueue.main.async {
                                                if success {
                                                    finish(nil)
                                                } else {
                                                    finish(error)
                                                }
                                            }
        }
    }
    
    /// 걸음수 일어오기
    ///
    /// - Parameters:
    ///   - startDate: 시작시점
    ///   - endDate: 종료시점 , 없다면 지금까지 데이터 읽어오기
    ///   - finish: 완료 이벤트 헨들러
    func readStepCount(startDate: Date, endDate: Date = Date(), WithComplete finish: @escaping (Error?,[(Date,[(String, Int)])]) ->Void) {
        let dispatchGroup = DispatchGroup()
        var countWithDate: [(Date,[(String, Int)])] = []
        
        // 스타트 타임이 엔드 타이을 넘어가는 경우 걸러내기
        if startDate > endDate {
            finish(nil, [])
            return
        }
        
        var current = startDate
        while current <= endDate {
            dispatchGroup.enter()
            getCountInDate(current) { (date, countWithHour) in
                countWithDate.append((date, countWithHour))
                dispatchGroup.leave()
            }
            
            // 다음날로 이동
            let now = Calendar.current.dateComponents(in: .autoupdatingCurrent, from: current)
            let tomorrow = DateComponents(year: now.year, month: now.month, day: now.day! + 1)
            current = Calendar.current.date(from: tomorrow)!
        }
        
        // 완료 핸들러
        dispatchGroup.notify(queue: .global(qos: .default)) {
            finish(nil, countWithDate)
        }
    }
    
    /// 해당 날짜의 걸음수 데이터를 시간별로 읽어오기
    ///
    /// - Parameters:
    ///   - date: 조회 날짜
    ///   - completion: 완료 핸들러
    private func getCountInDate(_ date: Date, withComplete completion: @escaping ((Date, [(String, Int)]) -> Void)) {
        // yyyy-MM-dd HH
        let stringDate = stringFromDate(date)
        // 모든 async task가 끝나는 시점을 판단하는 부분
        let dispatchGroup = DispatchGroup()
        var countArray: [(String, Int)] = []
        
        for i in 0...23 {
            let startTime = self.dateFromString("\(stringDate) \(i)")
            let endTime = self.dateFromString("\(stringDate) \(i+1)")
            // 꺼내올 데이터 타입
            guard let sampleSteps = HKSampleType.quantityType(forIdentifier: .stepCount) else { fatalError() }
            // 기간 설정
            let predicate = HKQuery.predicateForSamples(withStart: startTime, end: endTime, options: HKQueryOptions.strictStartDate)
            // 쿼리 실행
            let query = HKSampleQuery(sampleType: sampleSteps,
                                      predicate: predicate,
                                      limit: 0,
                                      sortDescriptors: nil) { (hkSamleQuery, hkSamleArray, error) in
                                        if let error = error {
                                            print(error.localizedDescription)
                                        } else {
                                            var steps = 0.0
                                            var queryDate = ""
                                            for sample: HKQuantitySample in (hkSamleArray as? [HKQuantitySample]) ?? [] {
                                                queryDate = self.withHHFromDate(sample.startDate)
                                                steps += sample.quantity.doubleValue(for: .count())
                                            }
                                            if steps == 0 {
                                                dispatchGroup.leave()
                                                return
                                            }
                                            let result = (queryDate, Int(steps))
                                            print("\(queryDate) : \(steps)")
                                            countArray.append(result)
                                        }
                                        
                                        dispatchGroup.leave()
            }
            dispatchGroup.enter()
            self.healthStore.execute(query)
        }
        
        // 완료 핸들러
        dispatchGroup.notify(queue: .global(qos: .default)) {
            completion(date, countArray)
        }
    }
    
    /// yyyy-MM-dd HH 형태의 String 으로 Date 생성
    private func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH"
        
        let gregorian = Calendar(identifier: .gregorian)
        dateFormatter.calendar = gregorian
        
        // 한국 설정
        dateFormatter.timeZone = .autoupdatingCurrent
        let locale = Locale(identifier: "ko_KR")
        dateFormatter.locale = locale
        
        return dateFormatter.date(from: dateString)
    }
    
    /// Date를 "yyyy-MM-dd HH" 형태로 수정
    private func stringFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let gregorian = Calendar(identifier: .gregorian)
        dateFormatter.calendar = gregorian
        
        // 한국 설정
        dateFormatter.timeZone = .autoupdatingCurrent
        let locale = Locale(identifier: "ko_KR")
        dateFormatter.locale = locale
        
        return dateFormatter.string(from: date)
    }
    /// Date를 "yyyy-MM-dd" 형태로 수정
    private func withHHFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH"
        
        let gregorian = Calendar(identifier: .gregorian)
        dateFormatter.calendar = gregorian
        
        // 한국 설정
        dateFormatter.timeZone = .autoupdatingCurrent
        let locale = Locale(identifier: "ko_KR")
        dateFormatter.locale = locale
        
        return dateFormatter.string(from: date)
    }
}
