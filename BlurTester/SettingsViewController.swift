//
//  InspectorsContainerViewController.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 13/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var pageNameLabel: UILabel!
    @IBOutlet var inspectorsStackView: UIStackView!

    var viewModel: SettingsViewModel? {
        willSet {
            currentInspectorPageNumber = nil
        }
        didSet {
            if let viewModel = viewModel, viewModel.pages.isEmpty == false {
                currentInspectorPageNumber = 0
            }
        }
    }

    private var currentInspectorPageNumber: Int? {
        willSet {
            pageNameLabel.text = nil
            currentInspectorViewControllers = [ ]
        }
        didSet {
            if let page = currentInspectorPage {
                pageNameLabel.text = page.name
                currentInspectorViewControllers = page.inspectors.map { viewModel in
                    let viewController = self.storyboard!.instantiateViewController(withIdentifier: viewModel.inspectorViewControllerIdentifier)
                    if let inspector = viewController as? Inspector {
                        inspector.viewModel = viewModel
                    }

                    return viewController
                }
            }
        }
    }

    private var currentInspectorPage: SettingsPageViewModel? {
        get {
            if let viewModel = viewModel, let pageNumber = currentInspectorPageNumber {
                return viewModel.pages[pageNumber]
            } else {
                return nil
            }
        }
    }

    private var currentInspectorViewControllers = [UIViewController]() {
        willSet {
            for viewController in currentInspectorViewControllers {
                viewController.willMove(toParent: nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParent()
            }
        }
        didSet {
            for viewController in currentInspectorViewControllers {
                self.addChild(viewController)

                let inspectorView = viewController.view!
                inspectorView.backgroundColor = .clear
                inspectorView.translatesAutoresizingMaskIntoConstraints = false
                inspectorsStackView.addArrangedSubview(inspectorView)

                inspectorView.heightAnchor.constraint(equalToConstant: viewController.preferredContentSize.height).isActive = true

                viewController.didMove(toParent: self)
            }
        }
    }

    // MARK: - Actions

    @IBAction func showPreviousPage(_ sender: Any?) {
        guard let viewModel = viewModel, let currentPageNumber = currentInspectorPageNumber else {
            return
        }

        if currentPageNumber == 0 {
            currentInspectorPageNumber = viewModel.pages.count - 1
        } else {
            currentInspectorPageNumber = currentPageNumber - 1
        }
    }

    @IBAction func showNextPage(_ sender: Any?) {
        guard let viewModel = viewModel, let currentPageNumber = currentInspectorPageNumber else {
            return
        }

        if currentPageNumber < viewModel.pages.count - 1 {
            currentInspectorPageNumber = currentPageNumber + 1
        } else {
            currentInspectorPageNumber = 0
        }
    }

}
