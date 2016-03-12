//
//  ColorInspectorViewController.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 13/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import UIKit

class ColorInspectorViewController: UIViewController, Inspector, ColorInspectorComponentViewDelegate {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var hexColorLabel: UILabel!
    @IBOutlet var componentSlidersStackView: UIStackView!

    var viewModel: InspectorViewModel? {
        get {
            return colorViewModel
        }
        set {
            if let colorViewModel = newValue as? ColorInspectorViewModel {
                self.colorViewModel = colorViewModel
            } else {
                preconditionFailure("Incompatible view model specified.")
            }
        }
    }

    private var colorViewModel: ColorInspectorViewModel? {
        didSet {
            if self.isViewLoaded() {
                configureWithViewModel(colorViewModel)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureWithViewModel(colorViewModel)
    }

    private func configureWithViewModel(viewModel: ColorInspectorViewModel?) {
        titleLabel.text = colorViewModel?.name
        hexColorLabel.text = colorViewModel?.value?.vv_hexStringValueRGBA()
        currentRepresentationType = .RGB
    }

    // MARK: - Component views

    private var currentRepresentationType: ColorRepresentationType? {
        didSet {
            if let representation = currentRepresentation {
                let componentViews = representation.dynamicType.componentTitles.map { title -> ColorInspectorComponentView in
                    guard let view = self.dynamicType.componentViewNib.instantiateWithOwner(nil, options: nil).first as? ColorInspectorComponentView else {
                        preconditionFailure("Invalid color component view instantiated.")
                    }

                    view.label.text = title
                    view.delegate = self

                    return view
                }

                for (index, view) in componentViews.enumerate() {
                    view.slider.value = Float(representation.components[index])
                }

                self.componentViews = componentViews
            } else {
                self.componentViews = [ ]
            }
        }
    }

    private static let componentViewNib = UINib(nibName: "ColorInspectorComponentView", bundle: nil)
    private static let componentViewHeight = CGFloat(50.0)

    private var componentViews = [ColorInspectorComponentView]() {
        willSet {
            componentViews.forEach { $0.removeFromSuperview() }
        }
        didSet {
            for view in componentViews {
                view.backgroundColor = UIColor.clearColor()
                view.translatesAutoresizingMaskIntoConstraints = false
                componentSlidersStackView.addArrangedSubview(view)

                view.heightAnchor.constraintEqualToConstant(self.dynamicType.componentViewHeight).active = true
            }
        }
    }

    @IBAction func showGrayscaleComponents(sender: AnyObject?) {
        currentRepresentationType = .Grayscale
    }

    @IBAction func showRGBComponents(sender: AnyObject?) {
        currentRepresentationType = .RGB
    }

    private var currentRepresentation: ColorRepresentation? {
        get {
            if let color = colorViewModel?.value {
                return currentRepresentationType?.representationWithColor(color)
            } else {
                return nil
            }
        }
        set {
            colorViewModel?.value = newValue?.color
            hexColorLabel.text = colorViewModel?.value?.vv_hexStringValueRGBA()
        }
    }

    // MARK: - ColorInspectorComponentViewDelegate

    func colorInspectorComponentView(componentView: ColorInspectorComponentView, didChangeValue value: Float) {
        if let index = componentViews.indexOf(componentView) {
            currentRepresentation?.components[index] = CGFloat(value)
        }
    }

}
