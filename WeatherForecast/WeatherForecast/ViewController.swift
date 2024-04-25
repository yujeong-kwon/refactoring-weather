//
//  WeatherForecast - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class ViewController: UIViewController {
    var weatherJSON: WeatherJSON?
    let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.locale = .init(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd(EEEEE) a HH:mm"
        return formatter
    }()
    private let imageChache: NSCache<NSString, UIImage> = NSCache()
    var tempUnit: TempUnit = .metric
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
}

extension ViewController {
    @objc private func changeTempUnit() {
        switch tempUnit {
        case .imperial:
            tempUnit = .metric
            navigationItem.rightBarButtonItem?.title = "섭씨"
        case .metric:
            tempUnit = .imperial
            navigationItem.rightBarButtonItem?.title = "화씨"
        }
        refresh()
    }
    
    private func initialSetUp() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "화씨", image: nil, target: self, action: #selector(changeTempUnit))
        
        guard let weatherView: WeatherView = view as? WeatherView else {return}
        weatherView.delegate = self
        
        weatherView.layTable()
        
        weatherView.refreshAddTarget() 
        
        weatherView.configureTableView()
        
    }
    
}

extension ViewController: FetchWeatherInfoDelegate {
    func refreshNavigationTitle(title: String) {
        navigationItem.title = title
    }
}

extension ViewController: WeatherViewDelegate {
    func refresh() {
        let weatherInfo: FetchWeatherInfo = FetchWeatherInfo(delegate: self)
        weatherJSON = weatherInfo.fetchWeatherJSON()
        
        guard let weatherView: WeatherView = view as? WeatherView else {return}
        weatherView.tableViewReloadData()
        weatherView.refreshControlEndRefreshing()
    }
    
    func tableViewDidSelectRowAt(view: WeatherView, row: Int) {
        let detailViewController: WeatherDetailViewController = WeatherDetailViewController()
        detailViewController.weatherForecastInfo = weatherJSON?.weatherForecast[row]
        detailViewController.cityInfo = weatherJSON?.city
        detailViewController.tempUnit = tempUnit
        navigationController?.show(detailViewController, sender: self)
    }
    
    func getWeatherForecastInfoCount() -> Int {
        return weatherJSON?.weatherForecast.count ?? 0
    }
    
    func getWeatherForecastInfo(row: Int) -> WeatherForecastInfo? {
        return weatherJSON?.weatherForecast[row] ?? nil
    }
    
    func getTempUnit() -> String {
        return tempUnit.expression
    }
    
    func convertDateToString(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func getImageChacheObject(urlString: String) -> UIImage? {
        if let image = imageChache.object(forKey: urlString as NSString)
        {
            return image
        }
        
        return nil
    }
    
    func setImageChacheObject(image: UIImage, urlString: String) {
        imageChache.setObject(image, forKey: urlString as NSString)
    }
    
}
