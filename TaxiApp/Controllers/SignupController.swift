//
//  SignupController.swift
//  TaxiApp
//
//  Created by SanjayPathak on 13/02/20.
//  Copyright © 2020 Sanjay. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

class SignupController: UIViewController {

    
    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Taxi"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        return label
    }()
    private lazy var emailContainerView : UIView = {
        return UIView().inputContainer(withTextField: emailTextField, image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"))
    }()
    private lazy var passwordContainerView : UIView = {
        return UIView().inputContainer(withTextField: passwordTextField, image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"))
    }()
    private lazy var fullNameContainerView : UIView = {
        return UIView().inputContainer(withTextField: fullNameTextField, image: #imageLiteral(resourceName: "ic_account_box_white_2x"))
    }()
    private lazy var accountTypeContainerView : UIView = {
        return UIView().inputContainer(withSegmentedControl: accountTypeSegmentedControl, image: #imageLiteral(resourceName: "ic_account_box_white_2x"))
    }()
    private let emailTextField: UITextField = {
        return UITextField().inputTextField(placeHolder: "Email", isSecureText: false)
    }()
    private let passwordTextField: UITextField = {
        return UITextField().inputTextField(placeHolder: "Password", isSecureText: true)
    }()
    private let fullNameTextField: UITextField = {
        return UITextField().inputTextField(placeHolder: "Full Name", isSecureText: false)
    }()
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Rider", "Driver"])
        segmentedControl.backgroundColor = .backgroundColor
        segmentedControl.tintColor = UIColor(white: 1, alpha: 0.87)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    private let loginButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        return button
    }()
    private let alreadyHaveAccountButton:UIButton = {
        let button = UIButton().customAttributedNavigationButton(withTitle: "Already have an account? ", message: "Sign In", self, action: #selector(showSignIn))
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    
    @objc func showSignIn() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignup(){
        guard let email = emailTextField.text else {
            return
        }
        guard let fullName = fullNameTextField.text else {
            return
        }
        let accountType = accountTypeSegmentedControl.selectedSegmentIndex
        guard let password = passwordTextField.text else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                debugPrint("Failed to register user with error \(error.localizedDescription)")
                return
            }
            guard let uid = result?.user.uid else {
                return
            }
            
            let values = ["email": email, "fullname": fullName, "accountType": accountType] as [String:Any]
            
            if accountType == 1 { // Driver
                let geoFire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                guard let location = LocationHandler.shared.locationManager.location else { return }
                geoFire.setLocation(location, forKey: uid) { (error) in
                    self.registerUserAndShowHome(uid: uid, values: values)
                }
            } else {
                self.registerUserAndShowHome(uid: uid, values: values)
            }
        }
    }
    
    func registerUserAndShowHome(uid: String, values: [String:Any]){
        REF_USERS.child(uid).updateChildValues(values) { [weak self] (error, dbRef) in
            if let error = error {
                debugPrint("Failed in saving data with error \(error)")
            } else {
                if let sceneDelegate = self?.view.window?.windowScene?.delegate as? SceneDelegate {
                    sceneDelegate.setHomeControllerAsRoot()
                }
            }
        }
    }
    
    @objc func bgViewTapAction(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }

    // MARK: - Helper Functions
    func configureUI() {
        configureNavigationBar()
        
        view.backgroundColor = .backgroundColor
        
        self.view.addSubview(titleLabel)
        titleLabel.anchor(top:view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        let entryStack = UIStackView(arrangedSubviews: [fullNameContainerView,emailContainerView,passwordContainerView,accountTypeContainerView,loginButton])
        entryStack.axis = .vertical
        entryStack.alignment = .fill
        entryStack.spacing = 24
        view.addSubview(entryStack)
        entryStack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 8, height: 32)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bgViewTapAction(_ :))))
    }
    
    func configureNavigationBar(){
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
}
