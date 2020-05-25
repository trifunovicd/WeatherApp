//
//  SearchTableViewCell.swift
//  WeatherApp
//
//  Created by Internship on 22/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    private let tileView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "square_checkmark_uncheck"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tileLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var onLocationClicked: (() -> Void)?
    
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
            onLocationClicked!()
        }
    }

    func configure(_ location: SearchPreview) {
        tileLabel.text = location.placeNameWithCode.first?.uppercased()
        locationNameLabel.text = location.placeNameWithCode
    }
    
    private func setupLayout() {
        contentView.addSubviews(views: [tileView, tileLabel, locationNameLabel])
        
        NSLayoutConstraint.activate([
            tileView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tileView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            tileView.heightAnchor.constraint(equalToConstant: 30),
            
            tileLabel.centerXAnchor.constraint(equalTo: tileView.centerXAnchor),
            tileLabel.centerYAnchor.constraint(equalTo: tileView.centerYAnchor),
            
            locationNameLabel.centerYAnchor.constraint(equalTo: tileView.centerYAnchor),
            locationNameLabel.leadingAnchor.constraint(equalTo: tileView.trailingAnchor, constant: 8)
        ])
    }
}
