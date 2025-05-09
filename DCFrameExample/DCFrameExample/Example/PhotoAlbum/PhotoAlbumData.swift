//
//  PhotoAlbumData.swift
//  DCFrame_Example
//

import Foundation

class PhotoMonthData {
    var month = ""
    var photos = [String]()
}

class PhotoYearsData {
    var year = ""
    var months = [PhotoMonthData]()
}

class PhotoAlbumData {
    var years = [PhotoYearsData]()

    init() {
        for year in 0...10 {
            let yearData = PhotoYearsData()
            yearData.year = "\(2022 - year)年"
            for month in 0...11 {
                let monthData = PhotoMonthData()
                monthData.month = "\(12 - month)月"

                for photo in 1...(arc4random() % 9 + 1) {
                    monthData.photos.append("\(photo)")
                }

                yearData.months.append(monthData)
            }
            
            years.append(yearData)
        }
    }
}
