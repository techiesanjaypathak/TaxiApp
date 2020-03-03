//
//  Extensions.swift
//  TaxiApp
//
//  Created by SanjayPathak on 13/02/20.
//  Copyright © 2020 Sanjay. All rights reserved.
//

import UIKit
import MapKit

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        setWidthHeight(width: width, height: height)
    }
    func centerX(inView view: UIView, constant: CGFloat = 0,
                 top: NSLayoutYAxisAnchor? = nil, paddingTop: CGFloat = 0,
                 width: CGFloat? = nil, height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: constant).isActive = true
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        setWidthHeight(width: width, height: height)
    }
    func centerY(inView view: UIView, constant: CGFloat = 0,
                 left: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat = 0,
                 width: CGFloat? = nil, height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        setWidthHeight(width: width, height: height)
    }
    func setWidthHeight(width: CGFloat? = nil, height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    func inputContainer(withTextField textField: UITextField? = nil,
                        withSegmentedControl segmentedControl: UISegmentedControl? = nil,
                        image: UIImage) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        let imageView = UIImageView()
        imageView.image = image
        imageView.alpha = 0.87
        view.addSubview(imageView)

        if let textField = textField {
            imageView.centerY(inView: view)
            imageView.anchor(left: view.leftAnchor, paddingLeft: 8, width: 24, height: 24)

            view.addSubview(textField)
            textField.anchor(left: imageView.rightAnchor,
                             bottom: view.bottomAnchor,
                             right: view.rightAnchor,
                             paddingLeft: 8)
            textField.centerY(inView: view)

            let separatorView = UIView()
            separatorView.backgroundColor = .systemGray2
            view.addSubview(separatorView)
            separatorView.anchor(left: view.leftAnchor,
                                 bottom: view.bottomAnchor,
                                 right: view.rightAnchor,
                                 height: 0.75)

            view.anchor(height: 50)
        }

        if let segmentedControl = segmentedControl {
            imageView.anchor(top: view.topAnchor,
                             left: view.leftAnchor,
                             paddingTop: 8, paddingLeft: 8, width: 24, height: 24)

            view.addSubview(segmentedControl)
            segmentedControl.anchor(top: imageView.bottomAnchor,
                                    left: view.leftAnchor, right: view.rightAnchor,
                                    paddingLeft: 8, paddingRight: 8, height: 40)

            view.anchor(height: 75)
        }

        return view
    }
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowOffset =  CGSize(width: 0.5, height: 0.5)
        layer.masksToBounds = false
    }
    func animShow() {
        UIView.animate(withDuration: 2, delay: 0, options: [.curveEaseIn],
                       animations: {
                        self.center.y -= self.bounds.height
                        self.layoutIfNeeded()
        }, completion: nil)
        self.isHidden = false
    }
    func animHide() {
        UIView.animate(withDuration: 2, delay: 0, options: [.curveLinear],
                       animations: {
                        self.center.y += self.bounds.height
                        self.layoutIfNeeded()

        }, completion: {(_ completed: Bool) -> Void in
            self.isHidden = true
        })
    }
}

extension UITextField {
    func inputTextField(placeHolder: String, isSecureText: Bool) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .white
        textField.keyboardAppearance = .dark
        textField.isSecureTextEntry = isSecureText
        textField.attributedPlaceholder = NSAttributedString(
                                            string: placeHolder,
                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        return textField
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }

    static var backgroundColor: UIColor {
        return MaterialUI.backgroundColor
    }

    static var customButtonColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return MaterialUI.dmLoginNormalBlue
                } else {
                    return MaterialUI.loginNormalBlue
                }
            }
        } else {
            return MaterialUI.loginNormalBlue
        }
    }
}

extension UIButton {
    func customAttributedNavigationButton(withTitle title: String, message msg: String,
                                          _ target: Any?, action: Selector) -> UIButton {
        let button = UIButton()
        let attributedTitle = NSMutableAttributedString(string: title,
                                                        attributes: [NSAttributedString.Key.font:
                                                                        UIFont.boldSystemFont(ofSize: 16),
                                                                     NSAttributedString.Key.foregroundColor:
                                                                        UIColor.systemGray2])
        attributedTitle.append(NSAttributedString(string: msg,
                                                  attributes: [NSAttributedString.Key.font:
                                                                UIFont.boldSystemFont(ofSize: 16),
                                                               NSAttributedString.Key.foregroundColor:
                                                                UIColor.customButtonColor]))
        button.addTarget(target, action: action, for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }
}

private enum MaterialUI {
    static let backgroundColor = UIColor(named: "bgColor")!
    static let loginNormalBlue = UIColor.rgb(red: 17, green: 154, blue: 237)
    static let dmLoginNormalBlue = UIColor.rgb(red: 17, green: 154, blue: 237)
}

extension MKPlacemark {
    var address: String? {
        let localLocality = locality ?? ""
        let localSubLocality = subLocality ?? ""
        let localAdministrativeArea = administrativeArea ?? ""
        let localSubAdministrativeArea = subAdministrativeArea ?? ""

        return "\(shortAddress ?? ""), \(localLocality),"
            + " \(localSubLocality), \(localAdministrativeArea), \(localSubAdministrativeArea)"
    }

    var shortAddress: String? {
        let localStreetName = thoroughfare ?? ""
        let localSubThoroughfare = subThoroughfare ?? ""
        return "\(localSubThoroughfare) \(localStreetName)"
    }
}

extension MKMapView {
    func zoomToFit(annotations: [MKAnnotation]) {
//        let thisisaverylongvariablenametocheckhowtousehoundinaproject = "Sample"
        var zoomRect = MKMapRect.null
        annotations.forEach { (annotation) in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
        }
        let insets = UIEdgeInsets(top: 100, left: 100, bottom: 250, right: 100)
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
}
