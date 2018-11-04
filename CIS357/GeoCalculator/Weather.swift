//
//  Weather.swift
//  
//
//  Created by Admin on 11/17/17.
//
//

import Foundation

struct Weather {
    var iconName : String
    var temperature : Double
    var summary : String
    
    init(iconName : String, temperature : Double, summary : String) {
        self.iconName = iconName
        self.temperature = temperature
        self.summary = summary
    }
}

protocol WeatherService {
    func getWeatherForDate(date: Date, forLocation location :(Double, Double), completion: @escaping (Weather?) -> Void)
}
