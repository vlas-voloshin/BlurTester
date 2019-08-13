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
    
    weak var delegate: MediaPickerSourceDelegate?
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
    
    func present(in viewController: UIViewController) {
        presentingViewController = viewController
        
        let documentMenu = UIDocumentMenuViewController(documentTypes: [ kUTTypeImage as String ], in: .import)
        documentMenu.delegate = self
        
        viewController.present(documentMenu, animated: true, completion: nil)
    }
    
    // MARK: UIDocumentMenuDelegate
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        
        if let presentingViewController = self.presentingViewController {
            presentingViewController.present(documentPicker, animated: true, completion: nil)
        } else {
            self.delegate?.mediaPickerSource(self, didFinishWith: .cancelled, presented: nil)
        }
    }
    
    func documentMenuWasCancelled(_ documentMenu: UIDocumentMenuViewController) {
        self.delegate?.mediaPickerSource(self, didFinishWith: .cancelled, presented: nil)
    }
    
    // MARK: UIDocumentPickerDelegate
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let result: MediaPicker.Result
        // Load the imported image
        if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
            result = .photo(image: image)
        } else {
            result = .importFailed
        }
        
        self.delegate?.mediaPickerSource(self, didFinishWith: result, presented: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.delegate?.mediaPickerSource(self, didFinishWith: .cancelled, presented: nil)
    }

}
