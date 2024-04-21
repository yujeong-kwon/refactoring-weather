//
//  WeatherView.swift
//  WeatherForecast
//
//  Created by Mac on 4/20/24.
//

import Foundation
import UIKit

protocol WeatherViewDelegate: AnyObject {
    func tableViewDidSelectRowAt(view: WeatherView, row: Int)
    func getWeatherForecastInfoCount() -> Int
    func getWeatherForecastInfo(row: Int) -> WeatherForecastInfo?
    func getTempUnit() -> String
    func convertDateToString(date: Date) -> String
    func getImageChacheObject(urlString: String) -> UIImage?
    func setImageChacheObject(image: UIImage, urlString: String)
    func refresh()
}

class WeatherView: UIView {
    private var tableView: UITableView!
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    private var icons: [UIImage]?
    
    var delegate: WeatherViewDelegate?
   
    func setTableView(){
        tableView.refreshControl = refreshControl
        tableView.register(WeatherTableViewCell.self, forCellReuseIdentifier: "WeatherCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableViewReloadData(){
        tableView.reloadData()
    }
    
    func refreshControlEndRefreshing(){
        refreshControl.endRefreshing()
    }
    
    func layTable() {
        tableView = .init(frame: .zero, style: .plain)
        self.addSubview(tableView)
        
        setTableViewConstraint()
    }
    
    func setTableViewConstraint() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea: UILayoutGuide = self.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }
    
    func refreshAddTarget(){
        refreshControl.addTarget(self,
                                 action: #selector(refresh),
                                 for: .valueChanged)
    }
   
    @objc private func refresh(){
        delegate?.refresh()
    }
}

extension WeatherView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.tableViewDidSelectRowAt(view: self, row: indexPath.row)
    }
}

extension WeatherView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let num = delegate?.getWeatherForecastInfoCount() else {return 0}
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath)
        
        guard let cell: WeatherTableViewCell = cell as? WeatherTableViewCell,
              let weatherForecastInfo = delegate?.getWeatherForecastInfo(row: indexPath.row) else {
            return cell
        }
        
        setCellLabel(cell: cell, weatherForecastInfo: weatherForecastInfo)
        
        let iconName: String = weatherForecastInfo.weather.icon
        let urlString: String = "https://openweathermap.org/img/wn/\(iconName)@2x.png"
        
        
        if let image = delegate?.getImageChacheObject(urlString: weatherForecastInfo.weather.icon) {
            cell.weatherIcon.image = image
            return cell
        }
        
        Task {
            guard let url: URL = URL(string: urlString),
                  let (data, _) = try? await URLSession.shared.data(from: url),
                  let image: UIImage = UIImage(data: data) else {
                return
            }
            
            delegate?.setImageChacheObject(image: image, urlString: urlString)
            
            if indexPath == tableView.indexPath(for: cell) {
                cell.weatherIcon.image = image
            }
            
        }
    
        return cell
    }
    
    func setCellLabel(cell: WeatherTableViewCell, weatherForecastInfo: WeatherForecastInfo) {
        cell.weatherLabel.text = weatherForecastInfo.weather.main
        cell.descriptionLabel.text = weatherForecastInfo.weather.description
        cell.temperatureLabel.text = "\(weatherForecastInfo.main.temp)\( delegate?.getTempUnit() ?? "")"
        
        let date: Date = Date(timeIntervalSince1970: weatherForecastInfo.dt)
        cell.dateLabel.text = delegate?.convertDateToString(date: date)
    }
    
    func setCellImage(cell: WeatherTableViewCell, weatherForecastInfo: WeatherForecastInfo) {
        
    }
}
