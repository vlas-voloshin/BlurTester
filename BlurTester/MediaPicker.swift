//
//  MediaPicker.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 12/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import UIKit

protocol MediaPickerDelegate: class {
    
    func mediaPicker(mediaPicker: MediaPicker, didFinishWithResult result: MediaPicker.Result)

}

class MediaPicker: MediaPickerSourceDelegate {
    
    /// Specifies the result of media picker
    enum Result {
        /// A photo has been picked. Associated value is the picked image.
        case Photo(image: UIImage)
        /// Imported media could not be read.
        case ImportFailed
        /// User cancelled picking the media.
        case Cancelled
    }
    
    var delegate: MediaPickerDelegate?
    
    private weak var presentingViewController: UIViewController?
    private var presentedSource: MediaPickerSource?
    
    func presentPickerFromViewController(viewController: UIViewController) {
        self.presentingViewController = viewController
        
        let sourceClasses = [ MediaPickerLocalSource.self, MediaPickerImportSource.self ] as [MediaPickerSource.Type]
        let sourceActions = sourceClasses
            .flatMap { $0.mediaPickerSources() }
            .map { source in
                UIAlertAction(title: source.actionTitle, style: .Default) { _ in
                    self.presentSource(source)
                }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel) { _ in
            self.completeWithResult(.Cancelled)
        }
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        for action in sourceActions + [ cancelAction ] {
            actionSheet.addAction(action)
        }
        
        viewController.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    private func presentSource(source: MediaPickerSource) {
        guard let presentingViewController = self.presentingViewController else {
            completeWithResult(.Cancelled)
            return
        }
        
        self.presentedSource = source
        
        source.delegate = self
        source.presentInViewController(presentingViewController)
    }
    
    private func completeWithResult(result: Result, afterDismissingViewController viewController: UIViewController? = nil) {
        self.presentingViewController = nil
        
        self.dynamicType.performAfterDismissingViewController(viewController) {
            self.delegate?.mediaPicker(self, didFinishWithResult: result)
        }
    }
    
    // MARK: Postprocessing
    
    private static func performAfterDismissingViewController(viewController: UIViewController?, block: (Void) -> Void) {
        if let viewController = viewController, presentingViewController = viewController.presentingViewController {
            // Dismiss the provided view controller first
            presentingViewController.dismissViewControllerAnimated(true) {
                block()
            }
        } else {
            // Can perform block immediately
            block()
        }
    }
    
    // MARK: MediaPickerSourceDelegate
    
    func mediaPickerSource(source: MediaPickerSource, didFinishWithResult result: MediaPicker.Result, presentedNavigationController navigationController: UINavigationController?) {
        guard source === self.presentedSource else {
            return
        }
        
        self.presentedSource = nil
        
        completeWithResult(result, afterDismissingViewController: navigationController)
    }

}

// MARK: - Source definitions

protocol MediaPickerSource: class {
    
    /// Title for the source displayed in the source options selector.
    var actionTitle: String { get }
    /// Source delegate.
    var delegate: MediaPickerSourceDelegate? { get set }
    
    /// Returns an array of picker sources applicable to the specified media type.
    static func mediaPickerSources() -> [MediaPickerSource]
    
    /// Presents UI of the picker source from the specified view controller.
    func presentInViewController(viewController: UIViewController)
    
}

protocol MediaPickerSourceDelegate: class {
    
    /// Notifies the delegate that picker source has finished interacting with user.
    /// - parameter result: Result of the user interaction with the picker.
    /// - parameter navigationController: A navigation controller presented by the picker source, which delegate can either continue using to present additional UI or should dismiss. If `nil`, no such navigation controller is available.
    func mediaPickerSource(source: MediaPickerSource, didFinishWithResult result: MediaPicker.Result, presentedNavigationController navigationController: UINavigationController?)
    
}
