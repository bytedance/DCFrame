//
//  RefreshMockDataAPI.swift
//  DCFrame_Example
//

import Foundation

class RefreshMockDataAPI {
    static func refreshData(completion: @escaping (_ data: [String]) -> Void) {
        fetchData(offset: 0, completion: completion)
    }
    
    static func fetchData(offset: Int, completion: @escaping (_ data: [String]) -> Void) {
        var currentNumber = offset
        var data = [String]()

        DispatchQueue.global(qos: .default).async {
            // fake background loading task
            sleep(1)
            for _ in 0..<20 {
                currentNumber += 1
                data.append("\(currentNumber)")
            }
            DispatchQueue.main.async {
                completion(data)
            }
        }
    }
}
