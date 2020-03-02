//
//  LocationInputView.swift
//  TaxiApp
//
//  Created by SanjayPathak on 14/02/20.
//  Copyright © 2020 Sanjay. All rights reserved.
//

import UIKit

protocol LocationInputViewDelegate {
    func backAction()
    func searchPlaces(forQueryString queryString:String)
}

class LocationInputView: UIView {
    
    // MARK: - Properties
    
    var user: User? {
        didSet {
            titleLabel.text = user?.fullname
        }
    }
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleTapAction(_:)), for: .touchUpInside)
        return button
    }()
    private let titleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .darkGray
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        return titleLabel
    }()
    private lazy var startLocationInputTextField:UITextField = {
        let textField = UITextField()
        textField.placeholder = "Current Location"
        textField.isEnabled = false
        textField.backgroundColor = .systemGroupedBackground
        
        let paddingView = UIView()
        paddingView.setWidthHeight(width: 8, height: 30)
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var finishLocationInputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Destination"
        textField.backgroundColor = .lightGray
        textField.delegate = self
        textField.returnKeyType = .search
        let paddingView = UIView()
        paddingView.setWidthHeight(width: 8, height: 30)
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    private let startDotView: UIView = {
        let dotView = UIView()
        dotView.backgroundColor = .darkGray
        return dotView
    }()
    private let finishDotView: UIView = {
        let dotView = UIView()
        dotView.backgroundColor = .black
        return dotView
    }()
    private let startToFinishLineView:UIView = {
        let lineView = UIView()
        lineView.backgroundColor = .darkGray
        return lineView
    }()
    var delegate:LocationInputViewDelegate? = nil
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addShadow()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selector
    
    @objc func handleTapAction(_ sender: UITapGestureRecognizer){
        delegate?.backAction()
    }
    
    // MARK: - Helper Methods
    
    func configureUI(){
        backgroundColor = .white
        addSubview(backButton)
        backButton.anchor(top:topAnchor, left: leftAnchor, paddingTop: 44, paddingLeft: 12, width: 24, height: 25)
        addSubview(titleLabel)
        titleLabel.centerY(inView: backButton)
        titleLabel.centerX(inView: self)
        configureLocationTextFieldsUI()
        configureLeftDotViewUI()
    }
    
    func configureLocationTextFieldsUI(){
        addSubview(startLocationInputTextField)
        startLocationInputTextField.anchor(top:backButton.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 30, paddingLeft: 50, paddingRight: 20, height: 30)
        addSubview(finishLocationInputTextField)
        finishLocationInputTextField.anchor(top:startLocationInputTextField.bottomAnchor, left: startLocationInputTextField.leftAnchor, right: startLocationInputTextField.rightAnchor, paddingTop: 20, height: 30)
    }
    
    func configureLeftDotViewUI(){
        addSubview(startDotView)
        startDotView.centerY(inView:startLocationInputTextField, left: leftAnchor, paddingLeft: 20, width: 6, height: 6)
        startDotView.layer.cornerRadius = 3
        
        addSubview(finishDotView)
        finishDotView.centerY(inView:finishLocationInputTextField, left: leftAnchor, paddingLeft: 20, width: 6, height: 6)
        finishDotView.layer.cornerRadius = 3
        
        addSubview(startToFinishLineView)
        startToFinishLineView.anchor(top:startDotView.bottomAnchor, bottom: finishDotView.topAnchor,
                                     paddingTop: 10, paddingBottom: 10, width: 0.5)
        startToFinishLineView.centerX(inView: startDotView)
    }
}

extension LocationInputView : UITextFieldDelegate {
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return true }
        delegate?.searchPlaces(forQueryString: query)
        self.endEditing(true)
        return true
    }
}
