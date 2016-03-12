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

    func transformKeyedValue(value: AnyObject?) -> ValueType?
    func transformToKeyedValue(value: ValueType?) -> AnyObject?

}

extension KeyedInspectorViewModel {

    var value: ValueType? {
        get { return transformKeyedValue(inspectedObject?.valueForKey(inspectedKey)) }
        set { inspectedObject?.setValue(transformToKeyedValue(newValue), forKey: inspectedKey) }
    }

    func transformKeyedValue(value: AnyObject?) -> ValueType? { return value as? ValueType }
    func transformToKeyedValue(value: ValueType?) -> AnyObject? { return value as? AnyObject }

}

extension KeyedInspectorViewModel where ValueType: RawRepresentable, ValueType.RawValue == Int {

    var value: ValueType? {
        get {
            let number = inspectedObject?.valueForKey(inspectedKey) as? NSNumber
            return number.flatMap { ValueType(rawValue: $0.integerValue) }
        }
        set { inspectedObject?.setValue(newValue?.rawValue, forKey: inspectedKey) }
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

extension SelectableInspectorViewModelWithValue where Self: SelectableInspectorViewModel {

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
