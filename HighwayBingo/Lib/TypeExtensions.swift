///
/// TypeExtensions.swift
///

import Foundation
import Kingfisher
import UIKit

// MARK: - String
//
extension String {
    var firstWord: String {
        return components(separatedBy: " ").first ?? ""
    }
}

// MARK: - Array
//
extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

// MARK: - Dictionary



// MARK: - UIKit
//

extension UIButton {
    
    override func purpleBorder() {
        titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 5.0, 0.0)
        backgroundColor = .clear
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor(red:0.76, green:0.14, blue:1.00, alpha:1.0).cgColor
    }
}

extension UIViewController {
    
    var margin: UILayoutGuide {
        return view.layoutMarginsGuide
    }
    
    var screen: (height: CGFloat, width: CGFloat) {
        return (view.frame.size.height, view.frame.size.width)
    }
}

extension UIView {
    
    func freeConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func purpleBorder() {
        backgroundColor = .white
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor(red:0.76, green:0.14, blue:1.00, alpha:1.0).cgColor
    }
}

extension UIImage {
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIImageView {
    
    func kfSetPlayerImage(with url: URL, diameter: CGFloat) {
        let processor = RoundCornerImageProcessor(cornerRadius: diameter)
        kf.setImage(
            with: url,
            options: [
                .processor(processor),
                .transition(.fade(0.2))
            ]
        )
    }
}

extension UITextField {
    
    func underline() {
        layer.sublayerTransform = CATransform3DMakeTranslation(0, -5, 0)
        borderStyle = .none
        layer.backgroundColor = UIColor.white.cgColor
        layer.masksToBounds = false
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 0.0
    }
}




// MARK: - Overloads
//
func += <K, V> (left: [K : V], right: [K : V]) -> [K:V] {
    var leftCopy = left
    for (k, v) in right {
        leftCopy[k] = v
    }
    return leftCopy
}
