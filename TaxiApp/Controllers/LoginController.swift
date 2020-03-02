//
//  LoginController.swift
//  TaxiApp
//
//  Created by SanjayPathak on 13/02/20.
//  Copyright © 2020 Sanjay. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
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
    
    private let emailTextField: UITextField = {
        return UITextField().inputTextField(placeHolder: "Email", isSecureText: false)
    }()
    private let passwordTextField: UITextField = {
        return UITextField().inputTextField(placeHolder: "Password", isSecureText: true)
    }()
    private let loginButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        return button
    }()
    private let dontHaveAccountButton:UIButton = {
        let button = UIButton().customAttributedNavigationButton(withTitle: "Don't have an account? ", message: "Sign Up", self, action: #selector(showSignup))
        return button
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    @objc func showSignup(){
        let controller = SignupController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleSignIn(){
        guard let email = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error {
                debugPrint("Failed to register user with error \(error.localizedDescription)")
                return
            }
            if let sceneDelegate = self?.view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.setHomeControllerAsRoot()
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
        
        let entryStack = UIStackView(arrangedSubviews: [emailContainerView,passwordContainerView,loginButton])
        entryStack.axis = .vertical
        entryStack.alignment = .fill
        entryStack.spacing = 24
        view.addSubview(entryStack)
        entryStack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 8, height: 32)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bgViewTapAction(_ :))))
    }
    
    func configureNavigationBar(){
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    
}
