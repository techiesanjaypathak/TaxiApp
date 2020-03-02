//
//  LocationTableViewCell.swift
//  TaxiApp
//
//  Created by SanjayPathak on 16/02/20.
//  Copyright © 2020 Sanjay. All rights reserved.
//

import UIKit
import MapKit

class LocationTableViewCell: UITableViewCell {

    // MARK: - Properties
    let title: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.text = "123 ABC Street"
        return label
    }()
    let subTitle: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray2
        label.text = "123 ABC Street"
        return label
    }()
    var placemark: MKPlacemark? {
        didSet{
            title.text = placemark?.name
            subTitle.text = placemark?.address
        }
    }
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Helper Methods
    func configureUI(){
        let stackView = UIStackView(arrangedSubviews: [title,subTitle])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        addSubview(stackView)
        stackView.centerY(inView: self, left: leftAnchor, paddingLeft: 12)
    }
}
