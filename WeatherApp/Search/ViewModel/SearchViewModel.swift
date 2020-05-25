//
//  SearchViewModel.swift
//  WeatherApp
//
//  Created by Internship on 22/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

class SearchViewModel {
    weak var homeCoordinatorDelegate: ModalDelegate?
    var searchPreviews: [SearchPreview] = []
    let searchRequest = PublishSubject<String>()
    let fetchFinished = PublishSubject<Void>()
    let alertOfError = PublishSubject<Void>()
    let saveLocationAction = PublishSubject<SearchPreview>()
    var hasSafeArea: Bool!
    var backgroundColor: (UIColor, UIColor)!
    
    func initialize() -> Disposable {
        searchRequest
            .asObservable()
            .flatMap(getResultsObservale)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let searchPreviews):
                    self?.searchPreviews = searchPreviews
                    self?.fetchFinished.onNext(())
                case .failure(let error):
                    print(error)
                    self?.alertOfError.onNext(())
                }
            })
    }
    
    private func getResultsObservale(placeName: String) -> Observable<Result<[SearchPreview], Error>> {
        let observable: Observable<SearchResult> = getRequest(url: makeUrl(location: placeName))
        
        return observable.map { [unowned self] (result) -> Result<[SearchPreview], Error> in
            let searchPreviews = self.transform(result: result)
            return Result.success(searchPreviews)
        }.catchError { (error) -> Observable<Result<[SearchPreview], Error>> in
            let result = Result<[SearchPreview], Error>.failure(error)
            return Observable.just(result)
        }
        
    }
    
    private func transform(result: SearchResult) -> [SearchPreview] {
        var searchPreviews: [SearchPreview] = []
        
        for location in result.postalCodes {
            let searchPreview = SearchPreview(id: nil, isSelected: nil, placeName: location.placeName, placeNameWithCode: location.placeName + ", " + location.countryCode, lat: location.lat, lng: location.lng)
            
            searchPreviews.append(searchPreview)
        }
        
        return searchPreviews
    }
    
    
    func setSaveOption() -> Disposable {
        saveLocationAction.asObservable().subscribe(onNext: { searchPreview in
            let selectedLocation = SelectedLocation()
            selectedLocation.placeName = searchPreview.placeName
            selectedLocation.placeNameWithCode = searchPreview.placeNameWithCode
            selectedLocation.lat = searchPreview.lat
            selectedLocation.lng = searchPreview.lng
            selectedLocation.dateSaved = Date()
            
            let settings = getSettings()
            
            var oldSelectedLocation: SelectedLocation?
            
            do {
                let realm = try Realm()
                
                let locations = realm.objects(SelectedLocation.self).sorted(byKeyPath: "dateSaved", ascending: false)
                
                if locations.count > 0 {
                    print(locations[0].id)
                    selectedLocation.id = locations[0].id + 1
                    
                    let oldLocation = realm.objects(SelectedLocation.self).filter("isSelected = \(true)")
                    oldSelectedLocation = oldLocation[0]
                }
                
                try realm.write {
                    if let oldSelectedLocation = oldSelectedLocation {
                        oldSelectedLocation.isSelected = false
                    }
                    realm.add(selectedLocation)
                    
                    settings.lat = searchPreview.lat
                    settings.lng = searchPreview.lng
                    settings.location = searchPreview.placeName
                }
                
                print(realm.objects(SelectedLocation.self))
            } catch  {
                print(error)
            }
            
        })
    }
}
