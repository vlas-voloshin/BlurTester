//
//  SelectionInspectorViewController.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 13/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import UIKit

class SelectionInspectorViewController: UIViewController, Inspector {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var segmentedControl: UISegmentedControl!

    var viewModel: InspectorViewModel? {
        get {
            return selectionViewModel
        }
        set {
            if let selectionViewModel = newValue as? SelectableInspectorViewModel {
                self.selectionViewModel = selectionViewModel
            } else {
                preconditionFailure("Incompatible view model specified.")
            }
        }
    }

    var selectionViewModel: SelectableInspectorViewModel? {
        didSet {
            if self.isViewLoaded() {
                configureWithViewModel(selectionViewModel)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureWithViewModel(selectionViewModel)
    }

    private func configureWithViewModel(viewModel: SelectableInspectorViewModel?) {
        titleLabel.text = selectionViewModel?.name

        segmentedControl.removeAllSegments()
        if let viewModel = selectionViewModel {
            for (index, title) in viewModel.titles.enumerate() {
                segmentedControl.insertSegmentWithTitle(title, atIndex: index, animated: false)
            }

            segmentedControl.selectedSegmentIndex = viewModel.selectedOptionIndex ?? UISegmentedControlNoSegment
        }
    }

    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl!) {
        selectionViewModel?.selectedOptionIndex = sender.selectedSegmentIndex
    }
    
}
