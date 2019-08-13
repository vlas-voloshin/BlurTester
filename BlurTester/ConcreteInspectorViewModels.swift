//
//  ConcreteInspectorViewModels.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 12/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import UIKit

class ColorInspectorViewModel: KeyedInspectorViewModel {

    typealias ValueType = UIColor

    let name: String
    weak var inspectedObject: NSObject?
    let inspectedKey: String

    let inspectorViewControllerIdentifier = "ColorInspector"

    required init(name: String, inspectedObject: NSObject, inspectedKey: String) {
        self.name = name
        self.inspectedObject = inspectedObject
        self.inspectedKey = inspectedKey
    }

    static func backgroundColorInspector(for view: UIView, name: String) -> ColorInspectorViewModel {
        return self.init(name: name, inspectedObject: view, inspectedKey: "backgroundColor")
    }

    static func tintColorInspector(for view: UIView, name: String) -> ColorInspectorViewModel {
        return self.init(name: name, inspectedObject: view, inspectedKey: "tintColor")
    }

    static func textColorInspector(for label: UILabel, name: String) -> ColorInspectorViewModel {
        return self.init(name: name, inspectedObject: label, inspectedKey: "textColor")
    }

}

class BooleanInspectorViewModel: KeyedInspectorViewModel {

    typealias ValueType = Bool

    let name: String
    weak var inspectedObject: NSObject?
    let inspectedKey: String
    let invert: Bool

    let inspectorViewControllerIdentifier = "BooleanInspector"

    func transformKeyedValue(_ value: Any?) -> ValueType? {
        if invert {
            return !(value as? Bool ?? false)
        } else {
            return value as? ValueType
        }
    }

    func transformToKeyedValue(_ value: ValueType?) -> Any? {
        if invert {
            return !(value ?? false)
        } else {
            return value
        }
    }

    required init(name: String, inspectedObject: NSObject, inspectedKey: String, invert: Bool = false) {
        self.name = name
        self.inspectedObject = inspectedObject
        self.inspectedKey = inspectedKey
        self.invert = invert
    }

    static func visibilityInspector(for view: UIView, name: String) -> BooleanInspectorViewModel {
        return self.init(name: name, inspectedObject: view, inspectedKey: "hidden", invert: true)
    }
    
}

class BarStyleInspectorViewModel: KeyedInspectorViewModel, SelectableInspectorViewModel, SelectableInspectorViewModelWithValue {

    typealias ValueType = UIBarStyle

    let name: String
    weak var inspectedObject: NSObject?
    let inspectedKey: String

    let inspectorViewControllerIdentifier = "SelectionInspector"
    let values: [ValueType] = [ .default, .black ]
    let titlesMapping: [ValueType : String] = [ .default : "Default", .black : "Black" ]

    required init(name: String, inspectedObject: NSObject, inspectedKey: String) {
        self.name = name
        self.inspectedObject = inspectedObject
        self.inspectedKey = inspectedKey
    }

    static func barStyleInspector(for navigationBar: UINavigationBar, name: String) -> BarStyleInspectorViewModel {
        return self.init(name: name, inspectedObject: navigationBar, inspectedKey: "barStyle")
    }

}

class BlurEffectStyleInspectorViewModel: SelectableInspectorViewModel, SelectableInspectorViewModelWithValue {

    typealias ValueType = UIBlurEffect.Style

    let name: String
    weak var blurView: UIVisualEffectView?
    weak var vibrancyView: UIVisualEffectView?
    var value: ValueType? {
        didSet {
            let blurEffect = value.flatMap { UIBlurEffect(style: $0) }
            let vibrancyEffect = blurEffect.flatMap { UIVibrancyEffect(blurEffect: $0) }

            blurView?.effect = blurEffect
            vibrancyView?.effect = vibrancyEffect
        }
    }

    let inspectorViewControllerIdentifier = "SelectionInspector"
    let values: [ValueType] = [ .dark, .light, .extraLight ]
    let titlesMapping: [ValueType : String] = [ .dark : "Dark", .light : "Light", .extraLight : "Extra Light" ]

    required init(name: String, blurView: UIVisualEffectView?, vibrancyView: UIVisualEffectView?, value: ValueType?) {
        self.name = name
        self.blurView = blurView
        self.vibrancyView = vibrancyView
        self.value = value
    }

}
