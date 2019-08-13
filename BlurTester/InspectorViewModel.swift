//
//  InspectorViewModel.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 12/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import Foundation

protocol InspectorViewModel: class {

    var name: String { get }
    var inspectorViewControllerIdentifier: String { get }

}

protocol InspectorViewModelWithValue: InspectorViewModel {

    associatedtype ValueType

    var value: ValueType? { get set }
    
}

protocol KeyedInspectorViewModel: InspectorViewModelWithValue {

    var inspectedObject: NSObject? { get }
    var inspectedKey: String { get }

    func transformKeyedValue(_ value: Any?) -> ValueType?
    func transformToKeyedValue(_ value: ValueType?) -> Any?

}

extension KeyedInspectorViewModel {

    var value: ValueType? {
        get { return transformKeyedValue(inspectedObject?.value(forKey: inspectedKey)) }
        set { inspectedObject?.setValue(transformToKeyedValue(newValue), forKey: inspectedKey) }
    }

    func transformKeyedValue(_ value: Any?) -> ValueType? { return value as? ValueType }
    func transformToKeyedValue(_ value: ValueType?) -> Any? { return value }

}

extension KeyedInspectorViewModel where ValueType: RawRepresentable, ValueType.RawValue == Int {

    var value: ValueType? {
        get {
            let number = inspectedObject?.value(forKey: inspectedKey) as? Int
            return number.flatMap { ValueType(rawValue: $0) }
        }
        set { inspectedObject?.setValue(newValue?.rawValue, forKey: inspectedKey) }
    }

}

protocol SelectableInspectorViewModel: InspectorViewModel {

    var selectedOptionIndex: Int? { get set }
    var titles: [String] { get }
    
}

protocol SelectableInspectorViewModelWithValue: InspectorViewModelWithValue where ValueType: Hashable {

    var values: [ValueType] { get }
    var titlesMapping: [ValueType : String] { get }

}

extension SelectableInspectorViewModelWithValue where Self: SelectableInspectorViewModel {

    var selectedOptionIndex: Int? {
        get {
            return value.flatMap { values.firstIndex(of: $0) }
        }
        set {
            value = newValue.flatMap { values[$0] }
        }
    }

    var titles: [String] {
        return values.map { titlesMapping[$0]! }
    }

}
