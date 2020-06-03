//
//  SettingsViewModel.swift
//  WeatherApp
//
//  Created by Internship on 23/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

class SettingsViewModel {
    weak var homeCoordinatorDelegate: ModalDelegate?
    var hasSafeArea: Bool!
    var settingsPreviews: [SectionItem] = []
    let settingsRequest = PublishSubject<(TempSettings,[SearchPreview]?)>()
    let fetchFinished = PublishSubject<Void>()
    let alertOfError = PublishSubject<Void>()
    let showSpinner = PublishSubject<Void>()
    let saveSettingsAction = PublishSubject<(TempSettings,[SearchPreview]?)>()
    let deleteLocationAction = PublishSubject<SearchPreview>()
    let changeSelectedLocation = PublishSubject<SearchPreview>()
    var tempSettings: TempSettings!
    var tempLocations: [SearchPreview]?
    var backgroundColor: (UIColor, UIColor)!
    
    func fetchSettingsData() {
        let settings = getSettings()
        self.tempSettings = TempSettings(metric: settings.metric, imperial: settings.imperial, humidity: settings.humidity, wind: settings.wind, pressure: settings.pressure)
        self.tempLocations = getSavedLocations()
    }
    
    func initialize() -> Disposable {
        settingsRequest
            .asObservable()
            .flatMap(getSettingsObservable)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let settingsPreviews):
                    self?.settingsPreviews = settingsPreviews
                    self?.fetchFinished.onNext(())
                case .failure(let error):
                    print(error)
                    self?.alertOfError.onNext(())
                }
            })
    }
    
    private func getSettingsObservable(settings: TempSettings, tempLocations: [SearchPreview]?) -> Observable<Result<[SectionItem], Error>> {
        var sectionItems: [SectionItem] = []
        var rowItems: [RowItem<RowType, Any>] = []
        
        guard let tempLocations = tempLocations else {
            return Observable<Result<[SectionItem], Error>>.just(.failure(DataError.noDataAvailable))
        }
            
        for location in tempLocations {
            let rowItem = RowItem<RowType, Any>(type: .location, data: location)
            rowItems.append(rowItem)
        }
        
        let locationsSection = SectionItem(items: rowItems, headerTitle: R.string.localizable.locations_label())
        sectionItems.append(locationsSection)
        
        let unitsSection = SectionItem(items: getUnitRows(settings), headerTitle: R.string.localizable.units_label())
        sectionItems.append(unitsSection)
        
        let conditionSection = SectionItem(items: getConditionsRow(settings), headerTitle: R.string.localizable.conditions_label())
        sectionItems.append(conditionSection)
        
        return Observable<Result<[SectionItem], Error>>.just(.success(sectionItems))
            
    }
    
    private func getSavedLocations() -> [SearchPreview]? {
        var searchPreviews: [SearchPreview] = []
        
        do {
            let realm = try Realm()
            let locations = realm.objects(SelectedLocation.self).sorted(byKeyPath: "dateSaved", ascending: false)
            
            for location in locations {
                let locationPreview = SearchPreview(id: location.id, isSelected: location.isSelected, placeName: location.placeName, placeNameWithCode: location.placeNameWithCode, lat: location.lat, lng: location.lng)
                
                searchPreviews.append(locationPreview)
            }
            
            return searchPreviews
            
        } catch {
            print(error)
            return nil
        }
    }
    
    private func getUnitRows(_ settings: TempSettings) -> [RowItem<RowType, Any>] {
        var rowItems: [RowItem<RowType, Any>] = []
        
        let metricPreview = UnitPreview(name: Units.metric.rawValue.firstUppercased, isSelected: settings.metric)
        let metricRow = RowItem<RowType, Any>(type: .unit, data: metricPreview)
        
        let imperialPreview = UnitPreview(name: Units.imperial.rawValue.firstUppercased, isSelected: settings.imperial)
        let imperialRow = RowItem<RowType, Any>(type: .unit, data: imperialPreview)
        
        rowItems.append(metricRow)
        rowItems.append(imperialRow)
        
        return rowItems
    }
    
    
    private func getConditionsRow(_ settings: TempSettings) -> [RowItem<RowType, Any>] {
        var rowItems: [RowItem<RowType, Any>] = []
        
        let conditionsPreview = ConditionsPreview(humidity: settings.humidity, wind: settings.wind, pressure: settings.pressure)
        let conditionsRow = RowItem<RowType, Any>(type: .condition, data: conditionsPreview)
        
        rowItems.append(conditionsRow)
           
        return rowItems
    }
    
    
    func setSaveOption() -> Disposable {
        saveSettingsAction.asObservable().subscribe(onNext: { [unowned self] (newSettings, locations) in
            self.showSpinner.onNext(())
            
            let settings = Settings()
            settings.id = 0
            settings.metric = newSettings.metric
            settings.imperial = newSettings.imperial
            settings.humidity = newSettings.humidity
            settings.wind = newSettings.wind
            settings.pressure = newSettings.pressure
            
            var currentlySelectedLocation: SearchPreview?
            
            do {
                let realm = try Realm()
                
                let oldLocations = realm.objects(SelectedLocation.self)
                let updatedData = self.getUpdatedData(locations: locations)
                let newLocations: [SelectedLocation] = updatedData.newLocations
                currentlySelectedLocation = updatedData.currentlySelectedLocation
                
                if let selected = currentlySelectedLocation {
                    settings.lat = selected.lat
                    settings.lng = selected.lng
                    settings.location = selected.placeName
                }
                else {
                    let oldSettings = getSettings()
                    settings.lat = oldSettings.lat
                    settings.lng = oldSettings.lng
                    settings.location = oldSettings.location
                }
                
                try realm.write {
                    realm.add(settings, update: .modified)
                    realm.delete(oldLocations)
                    realm.add(newLocations)
                }
                
                print(realm.objects(Settings.self))
                print(realm.objects(SelectedLocation.self))
                
            } catch  {
                print(error)
            }
            
            self.homeCoordinatorDelegate?.getWeatherForLocation()
        })
    }
    
    private func getUpdatedData(locations: [SearchPreview]?) -> (newLocations: [SelectedLocation], currentlySelectedLocation: SearchPreview?){
        var newLocations: [SelectedLocation] = []
        var currentlySelectedLocation: SearchPreview!
        
        if let locations = locations {
            if locations.count != 0 {
                let location = locations[0]
                currentlySelectedLocation = SearchPreview(id: nil, isSelected: nil, placeName: location.placeName, placeNameWithCode: location.placeNameWithCode, lat: location.lat, lng: location.lng)
            }
            
            var counter: Double = 0
            
            let sortedLocations = locations.sorted {(location1, location2) -> Bool in
                guard let id1 = location1.id, let id2 = location2.id else {return false}
                return id1 < id2
            }
            
            for location in sortedLocations {
                let newLocation = SelectedLocation()
                
                if let id = location.id {
                    newLocation.id = id
                }
                
                if let isSelected = location.isSelected {
                    newLocation.isSelected = isSelected
                    
                    if isSelected {
                        currentlySelectedLocation = SearchPreview(id: nil, isSelected: nil, placeName: location.placeName, placeNameWithCode: location.placeNameWithCode, lat: location.lat, lng: location.lng)
                    }
                }
                
                newLocation.placeName = location.placeName
                newLocation.placeNameWithCode = location.placeNameWithCode
                newLocation.lat = location.lat
                newLocation.lng = location.lng
                newLocation.dateSaved = Date() + counter
                
                newLocations.append(newLocation)
                
                counter += 1
            }
        }
        return (newLocations, currentlySelectedLocation)
    }
    
    func setDeleteLocationOption() -> Disposable {
        deleteLocationAction.asObservable().subscribe(onNext: { [unowned self] searchPreview in
            
            if let locations = self.tempLocations {
                for (index, location) in locations.enumerated() {
                    if location.id == searchPreview.id {
                        self.tempLocations?.remove(at: index)
                        break
                    }
                }
            }
            self.settingsRequest.onNext((self.tempSettings, self.tempLocations))
            
        })
    }
    
    func setChangeLocationOption() -> Disposable {
        changeSelectedLocation.asObservable().subscribe(onNext: { [unowned self] searchPreview in
            
            guard var locations = self.tempLocations else { return }
            
            for index in 0..<locations.count {
                if locations[index].isSelected == true {
                    locations[index].isSelected = false
                }
                
                if locations[index].id == searchPreview.id {
                    locations[index].isSelected = true
                }
            }
            self.tempLocations = locations
            self.settingsRequest.onNext((self.tempSettings, self.tempLocations))
        })
    }
}
