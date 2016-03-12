//
//  InspectorViewModel.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 12/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import Foundation

protocol InspectorViewModel {

    var name: String { get }
    var inspectorViewControllerIdentifier: String { get }

}

protocol InspectorViewModelWithValue: InspectorViewModel {

    typealias ValueType

    var value: ValueType? { get set }
    
}

protocol KeyedInspectorViewModel: InspectorViewModelWithValue {

    weak var inspectedObject: AnyObject? { get }
    var inspectedKey: String { get }

    func transformValue(value: ValueType?) -> ValueType?

}

extension KeyedInspectorViewModel {

    func transformValue(value: ValueType?) -> ValueType? { return value }

}

extension KeyedInspectorViewModel where ValueType: AnyObject {

    var value: ValueType? {
        get { return inspectedObject?.valueForKey(inspectedKey) as? ValueType }
        set { inspectedObject?.setValue(value, forKey: inspectedKey) }
    }

}

extension KeyedInspectorViewModel where ValueType: RawRepresentable, ValueType.RawValue == Int {

    var value: ValueType? {
        get {
            let number = inspectedObject?.valueForKey(inspectedKey) as? NSNumber
            return number.flatMap { ValueType(rawValue: $0.integerValue) }
        }
        set { inspectedObject?.setValue(value?.rawValue, forKey: inspectedKey) }
    }

}

protocol SelectableInspectorViewModel: InspectorViewModel {

    var selectedOptionIndex: Int? { get set }
    var titles: [String] { get }
    
}

protocol SelectableInspectorViewModelWithValue: InspectorViewModelWithValue {

    typealias ValueType: Hashable

    var values: [ValueType] { get }
    var titlesMapping: [ValueType : String] { get }

}

extension SelectableInspectorViewModel where Self: SelectableInspectorViewModelWithValue {

    var selectedOptionIndex: Int? {
        get {
            return value.flatMap { values.indexOf($0) }
        }
        set {
            value = newValue.flatMap { values[$0] }
        }
    }

    var titles: [String] {
        return values.map { titlesMapping[$0]! }
    }

}
