//
//  BooleanInspectorViewController.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 13/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import UIKit

class BooleanInspectorViewController: UIViewController, Inspector {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueSwitch: UISwitch!

    var viewModel: InspectorViewModel? {
        get {
            return booleanViewModel
        }
        set {
            if let booleanViewModel = newValue as? BooleanInspectorViewModel {
                self.booleanViewModel = booleanViewModel
            } else {
                preconditionFailure("Incompatible view model specified.")
            }
        }
    }

    var booleanViewModel: BooleanInspectorViewModel? {
        didSet {
            if self.isViewLoaded() {
                configureWithViewModel(booleanViewModel)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureWithViewModel(booleanViewModel)
    }

    private func configureWithViewModel(viewModel: BooleanInspectorViewModel?) {
        titleLabel.text = booleanViewModel?.name
        valueSwitch.on = booleanViewModel?.value?.boolValue ?? false
    }

    @IBAction func switchValueChanged(sender: UISwitch!) {
        booleanViewModel?.value = sender.on
    }

}
