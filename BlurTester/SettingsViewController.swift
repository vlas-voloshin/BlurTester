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
            if let viewModel = viewModel where viewModel.pages.isEmpty == false {
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
                    let viewController = self.storyboard!.instantiateViewControllerWithIdentifier(viewModel.inspectorViewControllerIdentifier)
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
            if let viewModel = viewModel, pageNumber = currentInspectorPageNumber {
                return viewModel.pages[pageNumber]
            } else {
                return nil
            }
        }
    }

    private var currentInspectorViewControllers = [UIViewController]() {
        willSet {
            for viewController in currentInspectorViewControllers {
                viewController.willMoveToParentViewController(nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParentViewController()
            }
        }
        didSet {
            for viewController in currentInspectorViewControllers {
                self.addChildViewController(viewController)

                let inspectorView = viewController.view
                inspectorView.backgroundColor = UIColor.clearColor()
                inspectorView.translatesAutoresizingMaskIntoConstraints = false
                inspectorsStackView.addArrangedSubview(inspectorView)

                inspectorView.heightAnchor.constraintEqualToConstant(viewController.preferredContentSize.height).active = true

                viewController.didMoveToParentViewController(self)
            }
        }
    }

    // MARK: - Actions

    @IBAction func showPreviousPage(sender: AnyObject?) {
        guard let viewModel = viewModel, currentPageNumber = currentInspectorPageNumber else {
            return
        }

        if currentPageNumber == 0 {
            currentInspectorPageNumber = viewModel.pages.count - 1
        } else {
            currentInspectorPageNumber = currentPageNumber - 1
        }
    }

    @IBAction func showNextPage(sender: AnyObject?) {
        guard let viewModel = viewModel, currentPageNumber = currentInspectorPageNumber else {
            return
        }

        if currentPageNumber < viewModel.pages.count - 1 {
            currentInspectorPageNumber = currentPageNumber + 1
        } else {
            currentInspectorPageNumber = 0
        }
    }

}
