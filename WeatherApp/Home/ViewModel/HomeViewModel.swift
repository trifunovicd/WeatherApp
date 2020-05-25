//
//  HomeViewModel.swift
//  WeatherApp
//
//  Created by Internship on 15/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class HomeViewModel {
    
    weak var homeCoordinatorDelegate: HomeCoordinator?
    var location: LocationPreview!
    let locationRequest = PublishSubject<((Double, Double), Units)>()
    let fetchFinished = PublishSubject<Void>()
    let alertOfError = PublishSubject<Void>()
    var settings: TempSettings!
    var unit: Units!
    var defaultLocation: (Double, Double)!
    var locationLabel: String!
    var backgroundColor: (UIColor, UIColor)!
    
    func fetchSettingsData() {
        let settings = getSettings()
        self.settings = TempSettings(metric: settings.metric, imperial: settings.imperial, humidity: settings.humidity, wind: settings.wind, pressure: settings.pressure)
        self.unit = settings.metric ? Units.metric : Units.imperial
        self.defaultLocation = (settings.lat, settings.lng)
        self.locationLabel = settings.location
    }
    
    func initialize() -> Disposable{
        locationRequest
            .asObservable()
            .flatMap(getLocationObservale)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let location):
                    self?.location = location
                    self?.fetchFinished.onNext(())
                    self?.homeCoordinatorDelegate?.dismissModal()
                case .failure(let error):
                    print(error)
                    self?.homeCoordinatorDelegate?.dismissModal()
                    self?.alertOfError.onNext(())
                }
            })
    }
    
    private func getLocationObservale(defaultLocation: (Double, Double), unit: Units) -> Observable<Result<LocationPreview, Error>> {
        let observable: Observable<Location> = getRequest(url: makeUrl(lat: defaultLocation.0, lng: defaultLocation.1, units: unit))
        
        return observable.map { [unowned self] (location) -> Result<LocationPreview, Error> in
            let locationPreview = self.transform(location: location)
            return Result.success(locationPreview)
        }.catchError { (error) -> Observable<Result<LocationPreview, Error>> in
            let result = Result<LocationPreview, Error>.failure(error)
            return Observable.just(result)
        }
        
    }
    
    private func transform(location: Location) -> LocationPreview {
        var locationPreview: LocationPreview!
        
        for day in location.daily {
            if compareTime(time1: location.current.dt, time2: day.dt) {
                locationPreview = LocationPreview(temperature: location.current.temp, temperatureMin: day.temp.min, temperatureMax: day.temp.max, pressure: location.current.pressure, humidity: location.current.humidity, windSpeed: location.current.wind_speed, condition: location.current.weather[0].main, icon: getDarkSkyEquivalent(id: location.current.weather[0].id, icon: location.current.weather[0].icon))
                break
            }
        }
        
        if let preview = locationPreview {
            return preview
        }
        else {
            return LocationPreview(temperature: location.current.temp, temperatureMin: location.daily[0].temp.min, temperatureMax: location.daily[0].temp.max, pressure: location.current.pressure, humidity: location.current.humidity, windSpeed: location.current.wind_speed, condition: location.current.weather[0].main, icon: getDarkSkyEquivalent(id: location.current.weather[0].id, icon: location.current.weather[0].icon))
        }
        
    }
    
    private func compareTime(time1: Int64, time2: Int64) -> Bool {
        let datesAreEqual: Bool
        
        let date1 = time1.milisecondsToDate()
        let date2 = time2.milisecondsToDate()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        let dateOnly1 = dateFormatter.string(from: date1)
        let dateOnly2 = dateFormatter.string(from: date2)
        
        datesAreEqual = dateOnly1 == dateOnly2 ? true : false
        
        return datesAreEqual
    }
}
