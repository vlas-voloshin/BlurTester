//
//  MediaPicker.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 12/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import UIKit

protocol MediaPickerDelegate: class {
    
    func mediaPicker(_ mediaPicker: MediaPicker, didFinishWith result: MediaPicker.Result)

}

class MediaPicker: MediaPickerSourceDelegate {
    
    /// Specifies the result of media picker
    enum Result {
        /// A photo has been picked. Associated value is the picked image.
        case photo(image: UIImage)
        /// Imported media could not be read.
        case importFailed
        /// User cancelled picking the media.
        case cancelled
    }
    
    weak var delegate: MediaPickerDelegate?
    
    private weak var presentingViewController: UIViewController?
    private var presentedSource: MediaPickerSource?
    
    func presentPicker(from viewController: UIViewController) {
        self.presentingViewController = viewController
        
        let sourceClasses = [ MediaPickerLocalSource.self, MediaPickerImportSource.self ] as [MediaPickerSource.Type]
        let sourceActions = sourceClasses
            .flatMap { $0.mediaPickerSources() }
            .map { source in
                UIAlertAction(title: source.actionTitle, style: .default) { _ in
                    self.presentSource(source)
                }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            self.complete(with: .cancelled)
        }
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for action in sourceActions + [ cancelAction ] {
            actionSheet.addAction(action)
        }
        
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    private func presentSource(_ source: MediaPickerSource) {
        guard let presentingViewController = self.presentingViewController else {
            complete(with: .cancelled)
            return
        }
        
        self.presentedSource = source
        
        source.delegate = self
        source.present(in: presentingViewController)
    }
    
    private func complete(with result: Result, afterDismissing viewController: UIViewController? = nil) {
        self.presentingViewController = nil
        
        type(of: self).performAfterDismissing(viewController) {
            self.delegate?.mediaPicker(self, didFinishWith: result)
        }
    }
    
    // MARK: Postprocessing
    
    private static func performAfterDismissing(_ viewController: UIViewController?, block: @escaping () -> Void) {
        if let viewController = viewController, let presentingViewController = viewController.presentingViewController {
            // Dismiss the provided view controller first
            presentingViewController.dismiss(animated: true) {
                block()
            }
        } else {
            // Can perform block immediately
            block()
        }
    }
    
    // MARK: MediaPickerSourceDelegate
    
    func mediaPickerSource(_ source: MediaPickerSource, didFinishWith result: MediaPicker.Result, presented navigationController: UINavigationController?) {
        guard source === self.presentedSource else {
            return
        }
        
        self.presentedSource = nil
        
        complete(with: result, afterDismissing: navigationController)
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
    func present(in viewController: UIViewController)
    
}

protocol MediaPickerSourceDelegate: AnyObject {
    
    /// Notifies the delegate that picker source has finished interacting with user.
    /// - parameter result: Result of the user interaction with the picker.
    /// - parameter navigationController: A navigation controller presented by the picker source, which delegate can either continue using to present additional UI or should dismiss. If `nil`, no such navigation controller is available.
    func mediaPickerSource(_ source: MediaPickerSource, didFinishWith result: MediaPicker.Result, presented navigationController: UINavigationController?)
    
}
