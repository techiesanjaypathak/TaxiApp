//
//  LocationInputActivationView.swift
//  TaxiApp
//
//  Created by SanjayPathak on 14/02/20.
//  Copyright © 2020 Sanjay. All rights reserved.
//

import UIKit

protocol LocationInputActivationViewDelegate {
    func locationInputActivationViewTouchAction()
}

class LocationInputActivationView: UIView {
    // MARK: - Properties
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Where to?"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .systemGray
        return label
    }()
    var delegate:LocationInputActivationViewDelegate? = nil
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper Functions
    func configureUI(){
        backgroundColor = .white
        addShadow()
        addSubview(indicatorView)
        indicatorView.layer.cornerRadius = 4
        indicatorView.centerY(inView: self, constant: 0, left: leftAnchor, paddingLeft: 8, width: 8, height: 8)
        
        addSubview(placeholderLabel)
        placeholderLabel.centerY(inView: self, constant: 0, left: indicatorView.rightAnchor, paddingLeft: 8)
        placeholderLabel.anchor(right:rightAnchor, paddingRight: 8, height: 40)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchHandler(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Selectors
    
    @objc func touchHandler(_ sender:UITapGestureRecognizer){
        delegate?.locationInputActivationViewTouchAction()
    }
    
}
