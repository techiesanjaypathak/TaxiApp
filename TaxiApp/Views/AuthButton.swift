//
//  AuthButton.swift
//  TaxiApp
//
//  Created by SanjayPathak on 13/02/20.
//  Copyright © 2020 Sanjay. All rights reserved.
//

import UIKit

class AuthButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        backgroundColor = .customButtonColor
        layer.cornerRadius = 5
        setWidthHeight(height: 50)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
