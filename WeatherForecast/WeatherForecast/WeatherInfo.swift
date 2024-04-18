//
//  WeatherInfo.swift
//  WeatherForecast
//
//  Created by 권유정 on 2024/04/18.
//

import Foundation
import UIKit

protocol WeatherInfoDelegate {
    func refreshNavigationTitle(title: String)
}

final class WeatherInfo {

    private var delegate: WeatherInfoDelegate
    
    init(delegate: WeatherInfoDelegate) {
        self.delegate = delegate
    }
    
    func fetchWeatherJSON() -> WeatherJSON? {
        
        let jsonDecoder: JSONDecoder = .init()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

        guard let data = NSDataAsset(name: "weather")?.data else {
            return nil
        }
        
        let info: WeatherJSON
        do {
            info = try jsonDecoder.decode(WeatherJSON.self, from: data)
        } catch {
            print(error.localizedDescription)
            return nil
        }
        delegate.refreshNavigationTitle(title: info.city.name)
        return info
    }
}
