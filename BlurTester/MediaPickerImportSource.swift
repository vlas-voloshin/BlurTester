//
//  MediaPickerImportSource.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 12/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import UIKit
import MobileCoreServices

class MediaPickerImportSource: NSObject, MediaPickerSource, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    
    var delegate: MediaPickerSourceDelegate?
    var actionTitle: String {
        return NSLocalizedString("Import Photo", comment: "Media Picker option")
    }
    
    private weak var presentingViewController: UIViewController?

    required override init() {
        super.init()
    }
    
    static func mediaPickerSources() -> [MediaPickerSource] {
        // "Import" option is always available
        return [ self.init() ]
    }
    
    func presentInViewController(viewController: UIViewController) {
        presentingViewController = viewController
        
        let documentMenu = UIDocumentMenuViewController(documentTypes: [ kUTTypeImage as String ], inMode: .Import)
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
        // Load the imported image
        if let imageData = NSData(contentsOfURL: url), image = UIImage(data: imageData) {
            result = .Photo(image: image)
        } else {
            result = .ImportFailed
        }
        
        self.delegate?.mediaPickerSource(self, didFinishWithResult: result, presentedNavigationController: nil)
    }
    
    func documentPickerWasCancelled(controller: UIDocumentPickerViewController) {
        self.delegate?.mediaPickerSource(self, didFinishWithResult: .Cancelled, presentedNavigationController: nil)
    }

}
