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
   
    func configureTableView(){
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
        
        configureTableViewConstraint()
    }
    
    func configureTableViewConstraint() {
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
        
        guard let cell: WeatherTableViewCell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as? WeatherTableViewCell,
              let weatherForecastInfo = delegate?.getWeatherForecastInfo(row: indexPath.row) else {
            return UITableViewCell()
        }
        
        setCellLabel(for: cell, with: weatherForecastInfo)
        updateWeatherIcon(for: cell, at: indexPath, with: weatherForecastInfo)

        return cell
    }
    
    func setCellLabel(for cell: WeatherTableViewCell, with weatherForecastInfo: WeatherForecastInfo) {
        let tempUnit = delegate?.getTempUnit() ?? ""
        let date: Date = Date(timeIntervalSince1970: weatherForecastInfo.dt)
        let dateStr = delegate?.convertDateToString(date: date) ?? ""
        
        cell.setCellLabel(weatherForecastInfo: weatherForecastInfo, tempUnit: tempUnit, dateStr: dateStr)
        
    }
    
    func updateWeatherIcon(for cell: WeatherTableViewCell, at indexPath: IndexPath, with weatherForecastInfo: WeatherForecastInfo) {
        let iconName: String = weatherForecastInfo.weather.icon
        let urlString = "https://openweathermap.org/img/wn/\(iconName)@2x.png"
        
        let image = delegate?.getImageChacheObject(urlString: iconName) ?? UIImage()
        
        cell.updateWeatherIcon(with: image)
        Task {
            guard let url: URL = URL(string: urlString),
                let (data, _) = try? await URLSession.shared.data(from: url),
                let image: UIImage = UIImage(data: data) else {
                return
                
            }
              
            delegate?.setImageChacheObject(image: image, urlString: urlString)
              
            if indexPath == tableView.indexPath(for: cell) {
                cell.updateWeatherIcon(with: image)
            }
        }
    }
    
}
