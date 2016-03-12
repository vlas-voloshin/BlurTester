//
//  MainViewController.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 12/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, MediaPickerDelegate {

    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var tutorialLabel: UILabel!
    @IBOutlet var blurEffectView: UIVisualEffectView!
    @IBOutlet var vibrancyEffectView: UIVisualEffectView!
    @IBOutlet var normalLabel: UILabel!
    @IBOutlet var vibrantLabel: UILabel!

    @IBOutlet var blurredPanelProportionalHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        blurredPanelMinimumHeight = (blurredPanelProportionalHeightConstraint.firstItem as! UIView).systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    }

    private func presentImportFailedAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("Import failed", comment: "File import failed error title"),
            message: NSLocalizedString("Imported file is corrupted or unsupported.", comment: "File import failed error message"),
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Dismiss", comment: ""),
            style: .Cancel,
            handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Actions

    private var mediaPicker: MediaPicker?

    @IBAction func chooseBackgroundImage(sender: AnyObject?) {
        let picker = MediaPicker(mediaType: .Photo)
        picker.delegate = self
        self.mediaPicker = picker

        picker.presentPickerFromViewController(self)
    }

    @IBAction func exportComposition(sender: AnyObject?) {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 0.0)
        self.view.drawViewHierarchyInRect(self.view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let activityController = UIActivityViewController(activityItems: [ image ], applicationActivities: nil)
        self.presentViewController(activityController, animated: true, completion: nil)
    }

    @IBAction func openSettings(sender: AnyObject?) {
        // TODO: complete
    }

    // MARK: - Panel dragging

    private func blurredPanelHeightWithOffset(offset: CGFloat) -> CGFloat {
        return self.view.bounds.height * blurredPanelProportionalHeightConstraint.multiplier + offset
    }

    private var blurredPanelMinimumHeight = CGFloat(0)
    private var blurredPanelMinimumOffset: CGFloat {
        return blurredPanelMinimumHeight - blurredPanelHeightWithOffset(0.0)
    }

    private var blurredPanelMaximumHeight: CGFloat {
        return self.view.bounds.height
    }
    private var blurredPanelMaximumOffset: CGFloat {
        return blurredPanelMaximumHeight - blurredPanelHeightWithOffset(0.0)
    }

    private var blurredPanelDragInitialOffset: CGFloat?

    @IBAction func adjustBottomPanel(sender: UIPanGestureRecognizer!) {
        switch sender.state {
        case .Began:
            blurredPanelDragInitialOffset = blurredPanelProportionalHeightConstraint.constant

        case .Changed:
            guard let initialOffset = blurredPanelDragInitialOffset else {
                break
            }

            let offset = initialOffset - sender.translationInView(self.view).y
            if offset < blurredPanelMinimumOffset {
                blurredPanelProportionalHeightConstraint.constant = blurredPanelMinimumOffset
            } else if offset > blurredPanelMaximumOffset {
                blurredPanelProportionalHeightConstraint.constant = blurredPanelMaximumOffset
            } else {
                blurredPanelProportionalHeightConstraint.constant = offset
            }

        case .Ended:
            blurredPanelDragInitialOffset = nil

        default:
            break
        }
    }

    // MARK: - MediaPickerDelegate

    func mediaPicker(mediaPicker: MediaPicker, didFinishWithResult result: MediaPicker.Result) {
        guard mediaPicker === self.mediaPicker else {
            return
        }

        switch result {
        case .Photo(image: let image):
            backgroundImageView.image = image
            tutorialLabel.hidden = true

        case .ImportFailed:
            presentImportFailedAlert()

        case .Cancelled:
            break
        }

        self.mediaPicker = nil
    }

}

