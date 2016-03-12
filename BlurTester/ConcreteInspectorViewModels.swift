//
//  ConcreteInspectorViewModels.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 12/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import UIKit

struct ColorInspectorViewModel: KeyedInspectorViewModel {

    typealias ValueType = UIColor

    let name: String
    weak var inspectedObject: AnyObject?
    let inspectedKey: String

    let inspectorViewControllerIdentifier = "ColorInspector"

    static func backgroundColorInspectorForView(view: UIView, name: String) -> ColorInspectorViewModel {
        return self.init(name: name, inspectedObject: view, inspectedKey: "backgroundColor")
    }

    static func tintColorInspectorForView(view: UIView, name: String) -> ColorInspectorViewModel {
        return self.init(name: name, inspectedObject: view, inspectedKey: "tintColor")
    }

}

struct BooleanInspectorViewModel: KeyedInspectorViewModel {

    typealias ValueType = NSNumber

    let name: String
    weak var inspectedObject: AnyObject?
    let inspectedKey: String
    let invert: Bool

    let inspectorViewControllerIdentifier = "BooleanInspector"

    func transformValue(value: NSNumber?) -> NSNumber? {
        if invert {
            return !(value?.boolValue ?? false)
        } else {
            return value
        }
    }

    static func visibilityInspectorForView(view: UIView, name: String) -> BooleanInspectorViewModel {
        return self.init(name: name, inspectedObject: view, inspectedKey: "hidden", invert: true)
    }
    
}

struct BarStyleInspectorViewModel: KeyedInspectorViewModel, SelectableInspectorViewModel, SelectableInspectorViewModelWithValue {

    typealias ValueType = UIBarStyle

    let name: String
    weak var inspectedObject: AnyObject?
    let inspectedKey: String

    let inspectorViewControllerIdentifier = "SelectionInspector"
    let values: [UIBarStyle] = [ .Default, .Black ]
    let titlesMapping: [UIBarStyle : String] = [ .Default : "Default", .Black : "Black" ]

    static func barStyleInspectorForNavigationBar(navigationBar: UINavigationBar, name: String) -> BarStyleInspectorViewModel {
        return self.init(name: name, inspectedObject: navigationBar, inspectedKey: "barStyle")
    }

}

struct BlurEffectStyleInspectorViewModel: SelectableInspectorViewModel, SelectableInspectorViewModelWithValue {

    typealias ValueType = UIBlurEffectStyle

    let name: String
    weak var blurView: UIVisualEffectView?
    weak var vibrancyView: UIVisualEffectView?
    var value: UIBlurEffectStyle? {
        didSet {
            let blurEffect = value.flatMap { UIBlurEffect(style: $0) }
            let vibrancyEffect = blurEffect.flatMap { UIVibrancyEffect(forBlurEffect: $0) }

            blurView?.effect = blurEffect
            vibrancyView?.effect = vibrancyEffect
        }
    }

    let inspectorViewControllerIdentifier = "SelectionInspector"
    let values: [UIBlurEffectStyle] = [ .Dark, .Light, .ExtraLight ]
    let titlesMapping: [UIBlurEffectStyle : String] = [ .Dark : "Dark", .Light : "Light", .ExtraLight : "Extra Light" ]

}
