//
//  Utilities.swift
//  WeatherApp
//
//  Created by Internship on 16/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import UIKit
import Hue
import RealmSwift

extension Int64 {
    func milisecondsToDate() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self))
    }
}

func getDarkSkyEquivalent(id: Int, icon: String) -> String {
    switch id {
    case 200, 201, 202, 210, 211, 212, 221, 230, 231, 232:
        return "thunderstorm"
    case 300, 301, 302, 310, 311, 312, 313, 314, 321, 500, 501, 502, 503, 504, 520, 521, 522, 531:
        return "rain"
    case 511:
        return "hail"
    case 611, 612, 613:
        return "sleet"
    case 600, 601, 602, 615, 616, 620, 621, 622:
        return "snow"
    case 701, 711, 721, 731, 741, 751, 761, 762:
        return "fog"
    case 771:
        return "wind"
    case 781:
        return "tornado"
    case 800:
        return icon.last == "d" ? "clear-day" : "clear-night"
    case 801, 802:
        return icon.last == "d" ? "partly-cloudy-day" : "partly-cloudy-night"
    case 803, 804:
        return "cloudy"
    default:
        return ""
    }
}

func setGradientToView(color1: UIColor, color2: UIColor, view: UIView) {
    let gradient = [color1, color2].gradient()
    gradient.frame = view.frame
    view.layer.addSublayer(gradient)
}


extension UIView {
    func addSubviews(views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
}

extension Float {
    func toCelsius(showWithSymbol: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        guard let formattedString = formatter.string(for: self) else { return "-"}
        
        if showWithSymbol {
            return R.string.localizable.celsius(formattedString)
        }
        else {
            return R.string.localizable.temp_degree(formattedString)
        }
    }
    
    func toFahrenheit(showWithSymbol: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        guard let formattedString = formatter.string(for: self) else { return "-"}
        
        if showWithSymbol {
            return R.string.localizable.fahrenheit(formattedString)
        }
        else {
            return R.string.localizable.temp_degree(formattedString)
        }
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightIcon(icon: UIImage, color: UIColor?, width: Int, height: Int, padding: Int) {
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: width+padding, height: height) )
        let iconView  = UIImageView(frame: CGRect(x: -padding, y: 0, width: width, height: height))
        iconView.image = icon.withRenderingMode(.alwaysTemplate)
        if let color = color { iconView.tintColor = color }
        outerView.addSubview(iconView)

        self.rightView = outerView
        self.rightViewMode = .always
    }
}

extension UIStackView {
    func setupView(axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution?, spacing: CGFloat?) {
        self.axis = axis
        self.alignment = alignment
        
        if let distribution = distribution {
            self.distribution = distribution
        }
        
        if let spacing = spacing {
            self.spacing = spacing
        }
    }
}

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
}

func getSettings() -> Settings {
    var settingsValues: Settings = Settings()
    
    do {
        let realm = try Realm()
        let settings = realm.object(ofType: Settings.self, forPrimaryKey: 0)
        
        if let settings = settings {
            settingsValues = settings
        }
        
    } catch {
        print(error)
    }
    
    return settingsValues
}
