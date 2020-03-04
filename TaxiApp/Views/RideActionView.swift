//
//  RideActionView.swift
//  TaxiApp
//
//  Created by SanjayPathak on 02/03/20.
//  Copyright © 2020 Sanjay. All rights reserved.
//

import UIKit
import MapKit

protocol RideActionDelegate: class {
    func takeRide(_ sender: RideActionView)
}

class RideActionView: UIView {

    // MARK: - Public Properties

    weak var delegate: RideActionDelegate?

    var destinationPlacemark: MKPlacemark? {
        didSet {
            locationName.text = destinationPlacemark?.name
            locationAddress.text = destinationPlacemark?.shortAddress
        }
    }
    // MARK: - Private Properties

    private let locationName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Sample Location"
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()

    private let locationAddress: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Sample Address"
        label.textAlignment = .center
        label.textColor = .systemGray2
        return label
    }()

    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black

        let label = UILabel()
        label.text = "X"
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white

        view.addSubview(label)
        label.centerX(inView: view)
        label.centerY(inView: view)

        return view
    }()

    private let rideCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Toy Car"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("CONFIRM RIDE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(rideAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        addShadow()

        let stack = UIStackView(arrangedSubviews: [locationName, locationAddress])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually

        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor, paddingTop: 12)

        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 16)
        infoView.setWidthHeight(width: 60, height: 60)
        infoView.layer.cornerRadius = 60/2

        addSubview(rideCategoryLabel)
        rideCategoryLabel.centerX(inView: self)
        rideCategoryLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)

        let separatorView = UIView()
        separatorView.backgroundColor = .black
        addSubview(separatorView)
        separatorView.anchor(top: rideCategoryLabel.bottomAnchor,
                             left: leftAnchor, right: rightAnchor,
                             paddingTop: 12, height: 0.75)

        addSubview(actionButton)
        actionButton.anchor(top: separatorView.bottomAnchor, left: leftAnchor,
                            bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor,
                            paddingTop: 12, paddingLeft: 12, paddingBottom: 12, paddingRight: 12, height: 50)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Selectors

    @objc func rideAction() {
        delegate?.takeRide(self)
    }
}
