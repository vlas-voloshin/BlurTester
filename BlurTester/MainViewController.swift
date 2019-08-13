//
//  MainViewController.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 12/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, MediaPickerDelegate {

    @IBOutlet var contentView: UIView!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var tutorialLabel: UILabel!
    @IBOutlet var blurEffectView: UIVisualEffectView!
    @IBOutlet var vibrancyEffectView: UIVisualEffectView!
    @IBOutlet var normalLabel: UILabel!
    @IBOutlet var vibrantLabel: UILabel!

    @IBOutlet var blurredPanelProportionalHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        blurredPanelMinimumHeight = (blurredPanelProportionalHeightConstraint.firstItem as! UIView).systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height

        loadSettings()
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        settingsViewController?.viewModel = settingsViewModel
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let swipeGesture = self.navigationController?.barHideOnSwipeGestureRecognizer {
            contentView.addGestureRecognizer(swipeGesture)
        }
    }

    private func presentImportFailedAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("Import failed", comment: "File import failed error title"),
            message: NSLocalizedString("Imported file is corrupted or unsupported.", comment: "File import failed error message"),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Dismiss", comment: ""),
            style: .cancel,
            handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Actions

    private var mediaPicker: MediaPicker?

    @IBAction func chooseBackgroundImage(_ sender: Any?) {
        self.setSettingsViewControllerDisplayed(false, animated: true)

        let picker = MediaPicker()
        picker.delegate = self
        self.mediaPicker = picker

        picker.presentPicker(from: self)
    }

    @IBAction func exportComposition(_ sender: Any?) {
        self.setSettingsViewControllerDisplayed(false, animated: true)

        UIGraphicsBeginImageContextWithOptions(contentView.bounds.size, true, 0.0)
        contentView.drawHierarchy(in: contentView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let activityController = UIActivityViewController(activityItems: [ image ], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }

    @IBAction func openSettings(_ sender: Any?) {
        setSettingsViewControllerDisplayed(!settingsViewControllerDisplayed, animated: true)
    }

    // MARK: - Settings

    private var settingsViewController: SettingsViewController?

    private func loadSettings() {
        guard let settings = self.storyboard!.instantiateViewController(withIdentifier: "Settings") as? SettingsViewController else {
            return
        }

        self.addChild(settings)

        let settingsView = settings.view!
        settingsView.alpha = 0.0
        settingsView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(settingsView)

        NSLayoutConstraint.activate([
            settingsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            settingsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            settingsView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor),
            settingsView.heightAnchor.constraint(equalToConstant: settings.preferredContentSize.height)
        ])

        settings.didMove(toParent: self)
        settingsViewController = settings
    }

    private var settingsViewModel: SettingsViewModel? {
        guard let navigationBar = self.navigationController?.navigationBar else {
            return nil
        }

        let generalSettings = SettingsPageViewModel(name: "General", inspectors: [
            BlurEffectStyleInspectorViewModel(name: "Blur", blurView: blurEffectView, vibrancyView: self.vibrancyEffectView, value: .dark),
            BarStyleInspectorViewModel.barStyleInspector(for: navigationBar, name: "Bar style")
        ])
        let backgroundSettings = SettingsPageViewModel(name: "Background", inspectors: [
            ColorInspectorViewModel.backgroundColorInspector(for: contentView, name: "Color")
        ])
        let underlaySettings = SettingsPageViewModel(name: "Underlay", inspectors: [
            ColorInspectorViewModel.backgroundColorInspector(for: blurEffectView, name: "Color")
        ])
        let overlaySettings = SettingsPageViewModel(name: "Overlay", inspectors: [
            ColorInspectorViewModel.backgroundColorInspector(for: blurEffectView.contentView, name: "Color")
        ])
        let normalTextSettings = SettingsPageViewModel(name: "Normal Text", inspectors: [
            BooleanInspectorViewModel.visibilityInspector(for: normalLabel, name: "Display"),
            ColorInspectorViewModel.textColorInspector(for: normalLabel, name: "Text Color")
        ])
        let vibrantTextSettings = SettingsPageViewModel(name: "Vibrant Text", inspectors: [
            BooleanInspectorViewModel.visibilityInspector(for: vibrantLabel, name: "Display"),
            ColorInspectorViewModel.tintColorInspector(for: vibrantLabel, name: "Tint Color")
        ])

        return SettingsViewModel(pages: [ generalSettings, backgroundSettings, underlaySettings, overlaySettings, normalTextSettings, vibrantTextSettings ])
    }

    private var settingsViewControllerDisplayed = false {
        didSet {
            settingsViewController?.view.alpha = settingsViewControllerDisplayed ? 1.0 : 0.0
        }
    }

    private func setSettingsViewControllerDisplayed(_ displayed: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.settingsViewControllerDisplayed = displayed
            }
        } else {
            self.settingsViewControllerDisplayed = displayed
        }
    }

    // MARK: - Panel dragging

    private func blurredPanelHeight(withOffset offset: CGFloat) -> CGFloat {
        return contentView.bounds.height * blurredPanelProportionalHeightConstraint.multiplier + offset
    }

    private var blurredPanelMinimumHeight = CGFloat(0)
    private var blurredPanelMinimumOffset: CGFloat {
        return blurredPanelMinimumHeight - blurredPanelHeight(withOffset: 0.0)
    }

    private var blurredPanelMaximumHeight: CGFloat {
        return contentView.bounds.height
    }
    private var blurredPanelMaximumOffset: CGFloat {
        return blurredPanelMaximumHeight - blurredPanelHeight(withOffset: 0.0)
    }

    private var blurredPanelDragInitialOffset: CGFloat?

    @IBAction func adjustBottomPanel(_ sender: UIPanGestureRecognizer!) {
        switch sender.state {
        case .began:
            blurredPanelDragInitialOffset = blurredPanelProportionalHeightConstraint.constant

        case .changed:
            guard let initialOffset = blurredPanelDragInitialOffset else {
                break
            }

            let offset = initialOffset - sender.translation(in: contentView).y
            if offset < blurredPanelMinimumOffset {
                blurredPanelProportionalHeightConstraint.constant = blurredPanelMinimumOffset
            } else if offset > blurredPanelMaximumOffset {
                blurredPanelProportionalHeightConstraint.constant = blurredPanelMaximumOffset
            } else {
                blurredPanelProportionalHeightConstraint.constant = offset
            }

        case .ended:
            blurredPanelDragInitialOffset = nil

        default:
            break
        }
    }

    // MARK: - MediaPickerDelegate

    func mediaPicker(_ mediaPicker: MediaPicker, didFinishWith result: MediaPicker.Result) {
        guard mediaPicker === self.mediaPicker else {
            return
        }

        switch result {
        case .photo(image: let image):
            backgroundImageView.image = image
            tutorialLabel.isHidden = true

        case .importFailed:
            presentImportFailedAlert()

        case .cancelled:
            break
        }

        self.mediaPicker = nil
    }

}

