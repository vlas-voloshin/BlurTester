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
            if self.isViewLoaded {
                configureWithViewModel(colorViewModel)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureWithViewModel(colorViewModel)
    }

    private func configureWithViewModel(_ viewModel: ColorInspectorViewModel?) {
        titleLabel.text = colorViewModel?.name
        hexColorLabel.text = colorViewModel?.value?.vv_hexStringValueRGBA()
        currentRepresentationType = .rgb
    }

    // MARK: - Component views

    private var currentRepresentationType: ColorRepresentationType? {
        didSet {
            if let representation = currentRepresentation {
                let componentViews = type(of: representation).componentTitles.map { title -> ColorInspectorComponentView in
                    guard let view = type(of: self).componentViewNib.instantiate(withOwner: nil, options: nil).first as? ColorInspectorComponentView else {
                        preconditionFailure("Invalid color component view instantiated.")
                    }

                    view.label.text = title
                    view.delegate = self

                    return view
                }

                for (index, view) in componentViews.enumerated() {
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
                view.backgroundColor = UIColor.clear
                view.translatesAutoresizingMaskIntoConstraints = false
                componentSlidersStackView.addArrangedSubview(view)

                view.heightAnchor.constraint(equalToConstant: type(of: self).componentViewHeight).isActive = true
            }
        }
    }

    @IBAction func showGrayscaleComponents(_ sender: Any?) {
        currentRepresentationType = .grayscale
    }

    @IBAction func showRGBComponents(_ sender: Any?) {
        currentRepresentationType = .rgb
    }

    private var currentRepresentation: ColorRepresentation? {
        get {
            if let color = colorViewModel?.value {
                return currentRepresentationType?.representation(with: color)
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

    func colorInspectorComponentView(_ componentView: ColorInspectorComponentView, didChangeValue value: Float) {
        if let index = componentViews.firstIndex(of: componentView) {
            currentRepresentation?.components[index] = CGFloat(value)
        }
    }

}
