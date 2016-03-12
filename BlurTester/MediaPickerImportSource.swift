//
//  MediaPickerImportSource.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 12/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import UIKit

class MediaPickerImportSource: NSObject, MediaPickerSource, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    
    let mediaType: MediaPicker.MediaType

    required init(mediaType: MediaPicker.MediaType) {
        self.mediaType = mediaType
        
        super.init()
    }
    
    var delegate: MediaPickerSourceDelegate?
    var actionTitle: String {
        return mediaType.actionStringForDocumentPicker()
    }
    
    private weak var presentingViewController: UIViewController?
    
    static func mediaPickerSourcesForMediaType(mediaType: MediaPicker.MediaType) -> [MediaPickerSource] {
        // "Import" option is always available
        return [ self.init(mediaType: mediaType) ]
    }
    
    func presentInViewController(viewController: UIViewController) {
        presentingViewController = viewController
        
        let documentMenu = UIDocumentMenuViewController(documentTypes: [ mediaType.UTI ], inMode: .Import)
        documentMenu.delegate = self
        
        viewController.presentViewController(documentMenu, animated: true, completion: nil)
    }
    
    // MARK: UIDocumentMenuDelegate
    
    func documentMenu(documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        
        if let presentingViewController = self.presentingViewController {
            presentingViewController.presentViewController(documentPicker, animated: true, completion: nil)
        } else {
            self.delegate?.mediaPickerSource(self, didFinishWithResult: .Cancelled, presentedNavigationController: nil)
        }
    }
    
    func documentMenuWasCancelled(documentMenu: UIDocumentMenuViewController) {
        self.delegate?.mediaPickerSource(self, didFinishWithResult: .Cancelled, presentedNavigationController: nil)
    }
    
    // MARK: UIDocumentPickerDelegate
    
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        let result: MediaPicker.Result
        switch self.mediaType {
        case .Photo:
            // Load the imported image
            if let imageData = NSData(contentsOfURL: url), image = UIImage(data: imageData) {
                result = .Photo(image: image)
            } else {
                result = .ImportFailed
            }
        }
        
        self.delegate?.mediaPickerSource(self, didFinishWithResult: result, presentedNavigationController: nil)
    }
    
    func documentPickerWasCancelled(controller: UIDocumentPickerViewController) {
        self.delegate?.mediaPickerSource(self, didFinishWithResult: .Cancelled, presentedNavigationController: nil)
    }

}

// MARK: - MediaType extension

extension MediaPicker.MediaType {
    
    private func actionStringForDocumentPicker() -> String {
        switch self {
        case .Photo:
            return NSLocalizedString("Import Photo", comment: "Media Picker option")
        }
    }
    
}
