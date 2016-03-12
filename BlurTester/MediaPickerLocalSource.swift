//
//  MediaPickerLocalSource.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 12/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class MediaPickerLocalSource: NSObject, MediaPickerSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let mediaType: MediaPicker.MediaType
    let sourceType: UIImagePickerControllerSourceType
    
    required init(mediaType: MediaPicker.MediaType, sourceType: UIImagePickerControllerSourceType) {
        self.mediaType = mediaType
        self.sourceType = sourceType

        super.init()
    }
    
    var delegate: MediaPickerSourceDelegate?
    var actionTitle: String {
        return mediaType.actionStringForPickerSourceType(sourceType)
    }
    
    static func mediaPickerSourcesForMediaType(mediaType: MediaPicker.MediaType) -> [MediaPickerSource] {
        let possibleSourceTypes = [ .Camera, .PhotoLibrary ] as [UIImagePickerControllerSourceType]
        let availableSourceTypes = possibleSourceTypes.filter { self.shouldShowImagePickerSourceType($0, withMediaType: mediaType) }
        
        return availableSourceTypes.map { self.init(mediaType: mediaType, sourceType: $0) }
    }
    
    func presentInViewController(viewController: UIViewController) {
        // In case of Camera source type, check that user has given permission to access the camera
        if sourceType == .Camera {
            switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
            case .Restricted, .Denied:
                // Cancel: image picker would just show a black screen if access has been explicitly denied or restricted.
                self.dynamicType.presentCameraAccessDeniedAlertFromViewController(viewController) {
                    self.completeWithResult(.Cancelled, picker: nil)
                }
                return
                
            default:
                // We're good, can continue.
                break
            }
        }
        
        let imagePicker = UIImagePickerController()
        mediaType.configureImagePicker(imagePicker)
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        viewController.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Image picker handling
    
    private func completeWithResult(result: MediaPicker.Result, picker: UIImagePickerController?) {
        // We're handing the picker over to the delegate, but self may be deallocated soon. To avoid crashes, delegate should be cleared out (it's an unsafe-unretained reference).
        picker?.delegate = nil
        self.delegate?.mediaPickerSource(self, didFinishWithResult: result, presentedNavigationController: picker)
    }
    
    private func completeWithImageAssetURL(assetURL: NSURL, fromPicker picker: UIImagePickerController) {
        let request = PHAsset.fetchAssetsWithALAssetURLs([ assetURL ], options: nil)
        guard let fetchedAsset = request.firstObject as? PHAsset else {
            assertionFailure("Image picker provided inaccessible asset URL.")
            completeWithResult(.ImportFailed, picker: picker)
            return
        }
        
        let options = PHImageRequestOptions()
        // We need the high-quality image
        options.deliveryMode = .HighQualityFormat
        PHImageManager.defaultManager().requestImageForAsset(fetchedAsset, targetSize: PHImageManagerMaximumSize, contentMode: .Default, options: options) { image, info in
            if let image = image {
                self.completeWithResult(.Photo(image: image), picker: picker)
            } else {
                if let info = info, error = info[PHImageErrorKey] as? NSError {
                    print("Image Manager failed to deliver asset image: \(error).")
                }
                self.completeWithResult(.ImportFailed, picker: picker)
            }
        }
    }
    
    private static func shouldShowImagePickerSourceType(sourceType: UIImagePickerControllerSourceType, withMediaType mediaType: MediaPicker.MediaType) -> Bool {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            return false
        }
        
        let mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(sourceType)
        return mediaTypes?.contains(mediaType.UTI) ?? false
    }
    
    private static func presentCameraAccessDeniedAlertFromViewController(viewController: UIViewController, withCompletion completion: (Void) -> Void) {
        let alert = UIAlertController(
            title: NSLocalizedString("Camera access is disabled", comment: ""),
            message: NSLocalizedString("To allow taking photos, enable Camera in System Settings.", comment: ""),
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .Cancel) { _ in
                completion()
            })
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Settings", comment: ""),
            style: .Default) { _ in
                let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.sharedApplication().openURL(settingsURL)
                completion()
            })
        
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        switch self.mediaType {
        case .Photo:
            if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                completeWithResult(.Photo(image: originalImage), picker: picker)
            } else if let originalImageURL = info[UIImagePickerControllerReferenceURL] as? NSURL {
                // There seem to be scenarios where only image URL would be contained in the result...
                print("Image picker returned asset URL instead of original image.")
                completeWithImageAssetURL(originalImageURL, fromPicker: picker)
            } else {
                assertionFailure("Expecting either original image or asset URL from image picker.")
                completeWithResult(.ImportFailed, picker: picker)
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        completeWithResult(.Cancelled, picker: picker)
    }
    
}

// MARK: - MediaType extension

extension MediaPicker.MediaType {
    
    private func actionStringForPickerSourceType(sourceType: UIImagePickerControllerSourceType) -> String {
        switch sourceType {
        case .Camera:
            switch self {
            case .Photo:
                return NSLocalizedString("Take Photo", comment: "Media Picker option")
            }
            
        case .PhotoLibrary, .SavedPhotosAlbum:
            switch self {
            case .Photo:
                return NSLocalizedString("Choose Photo", comment: "Media Picker option")
            }
        }
    }
    
    private func configureImagePicker(imagePicker: UIImagePickerController) {
        imagePicker.mediaTypes = [ self.UTI ]
        switch self {
        case .Photo:
            imagePicker.allowsEditing = false
        }
    }
    
}
