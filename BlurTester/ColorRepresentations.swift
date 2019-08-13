//
//  ColorRepresentations.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 13/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import UIKit

protocol ColorRepresentation {

    var color: UIColor { get set }
    var components: [CGFloat] { get set }
    static var componentTitles: [String] { get }

    init(color: UIColor)

}

struct GrayscaleColorRepresentation: ColorRepresentation {

    var color: UIColor {
        get {
            if components.count == 2 {
                return UIColor(white: components[0], alpha: components[1])
            } else {
                return .black
            }
        }
        set {
            var white = CGFloat(0.0)
            var alpha = CGFloat(0.0)
            newValue.getWhite(&white, alpha: &alpha)

            components = [ white, alpha ]
        }
    }

    var components = [CGFloat]()
    static let componentTitles = [ "White", "Alpha" ]

    init(color: UIColor) {
        self.color = color
    }

}

struct RGBColorRepresentation: ColorRepresentation {

    var color: UIColor {
        get {
            if components.count == 4 {
                return UIColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
            } else {
                return .black
            }
        }
        set {
            var red = CGFloat(0.0)
            var green = CGFloat(0.0)
            var blue = CGFloat(0.0)
            var alpha = CGFloat(0.0)
            newValue.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

            components = [ red, green, blue, alpha ]
        }
    }

    var components = [CGFloat]()
    static let componentTitles = [ "Red", "Green", "Blue", "Alpha" ]

    init(color: UIColor) {
        self.color = color
    }

}

enum ColorRepresentationType {
    case grayscale
    case rgb

    func representation(with color: UIColor) -> ColorRepresentation {
        switch self {
        case .grayscale:
            return GrayscaleColorRepresentation(color: color)

        case .rgb:
            return RGBColorRepresentation(color: color)
        }
    }
}
