///
/// TypeExtensions.swift
///

import Foundation
import UIKit

// MARK: - String
//
extension String {
    var firstWord: String {
        return components(separatedBy: " ").first ?? ""
    }
}

// MARK: - UIKit
//

extension UIViewController {
    
    var margin: UILayoutGuide {
        return view.layoutMarginsGuide
    }
    
    var screen: (height: CGFloat, width: CGFloat) {
        return (view.frame.size.height, view.frame.size.width)
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

extension UITextField {
    
    func underline() {
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
