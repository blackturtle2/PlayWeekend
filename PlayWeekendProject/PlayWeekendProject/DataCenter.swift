//
//  AppDelegate.swift
//  PlayWeekendProject
//
//  Created by leejaesung on 2017. 11. 1..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import Foundation

// 날씨: 날씨 클래스
struct WeatherSkyClass {
    var amCodeFriday: String
    var pmCodeFriday: String
    var amCodeSaturday: String
    var pmCodeSaturday: String
    var amCodeSunday: String
    var pmCodeSunday: String
    
    var amNameFriday: String
    var pmNameFriday: String
    var amNameSaturday: String
    var pmNameSaturday: String
    var amNameSunday: String
    var pmNameSunday: String
}

// 날씨: 기온 클래스
struct WeatherTemperatureClass {
    var tMaxFriday: Int
    var tMinFriday: Int
    var tMaxSaturday: Int
    var tMinSaturday: Int
    var tMaxSunday: Int
    var tMinSunday: Int
}

// 날씨: 날씨를 조회한 위치 클래스
struct WeatherGridClass {
    var city: String // 경기
    var county: String // 평택시
    var village: String // 안중읍
}

// 도시 클래스
struct cityClass {
    var name: String //서울특별시
    var latitude: String //37.56667
    var longitude: String //126.97806
}

// 관광 정보 클래스
struct tourInfoClass {
    var contentID: String
    var contentTypeID: String
    var title: String
    var address1: String
    var address2: String
    var firstImageURL: String
    var firstImage2URL: String
    
}
