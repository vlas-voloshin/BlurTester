//
//  ColorInspectorComponentView.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 13/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import UIKit

protocol ColorInspectorComponentViewDelegate: AnyObject {
    func colorInspectorComponentView(_ componentView: ColorInspectorComponentView, didChangeValue value: Float)
}

class ColorInspectorComponentView: UIView {

    @IBOutlet var slider: UISlider!
    @IBOutlet var label: UILabel!

    weak var delegate: ColorInspectorComponentViewDelegate?

    @IBAction func slideValueChanged(_ slider: UISlider!) {
        delegate?.colorInspectorComponentView(self, didChangeValue: slider.value)
    }

}
