//
//  Request.swift
//  WeatherApp
//
//  Created by Internship on 15/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

enum Urls: String {
    case weatherUrl = "https://api.openweathermap.org/data/2.5/onecall?"
    case weatherApiToken = "&appid=b792925ae960b4ec5082c60826df31cc"
    
    case geoNamesUrl = "http://api.geonames.org/postalCodeSearch?type=json&placename="
    case geoApiToken = "&username=danijelt"
}

enum DataError: Error {
    case noDataAvailable
    case canNotProcessData
}

func makeUrl(lat: Double, lng: Double, units: Units) -> String {
    let url = Urls.weatherUrl.rawValue + R.string.localizable.location_lat(lat) + R.string.localizable.location_lng(lng) + R.string.localizable.units(units.rawValue) + Urls.weatherApiToken.rawValue
    return url
}

func makeUrl(location: String) -> String {
    let url = Urls.geoNamesUrl.rawValue + location + Urls.geoApiToken.rawValue
    guard let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return url }
    return urlString
}

func getRequest<Data: Codable> (url: String) -> Observable<Data> {
    
    return Observable.create { observer in
        
        let request = AF.request(url).validate().responseJSON { response in
            guard let jsonData = response.data else {
                observer.onError(DataError.noDataAvailable)
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let response = try decoder.decode(Data.self, from: jsonData)

                observer.onNext(response)
                observer.onCompleted()
            }
            catch{
                observer.onError(DataError.canNotProcessData)
            }
        }
        
        return Disposables.create{
            request.cancel()
        }
    }
}
