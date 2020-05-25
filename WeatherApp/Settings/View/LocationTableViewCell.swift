//
//  LocationTableViewCell.swift
//  WeatherApp
//
//  Created by Internship on 23/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    private let tileView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "square_checkmark_uncheck"))
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tileInsideView: UIImageView = {
        let image = #imageLiteral(resourceName: "delete").withRenderingMode(.alwaysTemplate)
        let view = UIImageView(image: image)
        view.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let locationNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var onDeleteClicked: (() -> Void)?
    var onCellClicked: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            onCellClicked!()
        }
    }

    func configure(_ location: SearchPreview) {
        locationNameLabel.text = location.placeNameWithCode
        
        if let isSelected = location.isSelected, isSelected {
            locationNameLabel.textColor = .black
        }
        else {
            locationNameLabel.textColor = .white
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteClicked))
        tileView.addGestureRecognizer(gestureRecognizer) 
    }
    
    @objc private func deleteClicked(){
        onDeleteClicked!()
    }
    
    private func setupLayout() {
        contentView.addSubviews(views: [tileView, tileInsideView, locationNameLabel])
        
        NSLayoutConstraint.activate([
            tileView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tileView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            tileView.heightAnchor.constraint(equalToConstant: 35),
            tileView.widthAnchor.constraint(equalToConstant: 35),
            
            tileInsideView.centerXAnchor.constraint(equalTo: tileView.centerXAnchor),
            tileInsideView.centerYAnchor.constraint(equalTo: tileView.centerYAnchor),
            tileInsideView.heightAnchor.constraint(equalToConstant: 15),
            tileInsideView.widthAnchor.constraint(equalToConstant: 15),
            
            locationNameLabel.centerYAnchor.constraint(equalTo: tileView.centerYAnchor),
            locationNameLabel.leadingAnchor.constraint(equalTo: tileView.trailingAnchor, constant: 8)
        ])
    }
}
