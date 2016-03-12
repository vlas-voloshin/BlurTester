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
    var componentTitles: [String] { get }

}

struct GrayscaleColorRepresentation: ColorRepresentation {

    var color: UIColor {
        get {
            if components.count == 2 {
                return UIColor(white: components[0], alpha: components[1])
            } else {
                return UIColor.blackColor()
            }
        }
        set {
            var white = CGFloat(0.0)
            var alpha = CGFloat(0.0)
            newValue.getWhite(&white, alpha: &alpha)

            components = [ white, alpha ]
        }
    }

    var components: [CGFloat]
    let componentTitles = [ "White", "Alpha" ]

}

struct RGBColorRepresentation: ColorRepresentation {

    var color: UIColor {
        get {
            if components.count == 4 {
                return UIColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
            } else {
                return UIColor.blackColor()
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

    var components: [CGFloat]
    let componentTitles = [ "Red", "Green", "Blue", "Alpha" ]

}
