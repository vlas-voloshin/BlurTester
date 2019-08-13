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
import MobileCoreServices

class MediaPickerLocalSource: NSObject, MediaPickerSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let sourceType: UIImagePickerController.SourceType

    required init(sourceType: UIImagePickerController.SourceType) {
        self.sourceType = sourceType

        super.init()
    }
    
    weak var delegate: MediaPickerSourceDelegate?
    var actionTitle: String {
        return type(of: self).actionString(for: sourceType)
    }
    
    static func mediaPickerSources() -> [MediaPickerSource] {
        let possibleSourceTypes = [ .camera, .photoLibrary ] as [UIImagePickerController.SourceType]
        let availableSourceTypes = possibleSourceTypes.filter { self.shouldShow($0) }
        
        return availableSourceTypes.map { self.init(sourceType: $0) }
    }
    
    func present(in viewController: UIViewController) {
        // In case of Camera source type, check that user has given permission to access the camera
        if sourceType == .camera {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .restricted, .denied:
                // Cancel: image picker would just show a black screen if access has been explicitly denied or restricted.
                type(of: self).presentCameraAccessDeniedAlert(from: viewController) {
                    self.complete(with: .cancelled, picker: nil)
                }
                return
                
            default:
                // We're good, can continue.
                break
            }
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.mediaTypes = [ kUTTypeImage as String ]
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        viewController.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Image picker handling
    
    private func complete(with result: MediaPicker.Result, picker: UIImagePickerController?) {
        // We're handing the picker over to the delegate, but self may be deallocated soon. To avoid crashes, delegate should be cleared out (it's an unsafe-unretained reference).
        picker?.delegate = nil
        self.delegate?.mediaPickerSource(self, didFinishWith: result, presented: picker)
    }
    
    private func complete(withImageAssetURL assetURL: URL, from picker: UIImagePickerController) {
        let request = PHAsset.fetchAssets(withALAssetURLs: [ assetURL ], options: nil)
        guard let fetchedAsset = request.firstObject else {
            assertionFailure("Image picker provided inaccessible asset URL.")
            complete(with: .importFailed, picker: picker)
            return
        }
        
        let options = PHImageRequestOptions()
        // We need the high-quality image
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestImage(for: fetchedAsset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options) { image, info in
            if let image = image {
                self.complete(with: .photo(image: image), picker: picker)
            } else {
                if let info = info, let error = info[PHImageErrorKey] as? NSError {
                    print("Image Manager failed to deliver asset image: \(error).")
                }
                self.complete(with: .importFailed, picker: picker)
            }
        }
    }
    
    private static func shouldShow(_ sourceType: UIImagePickerController.SourceType) -> Bool {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            return false
        }
        
        let mediaTypes = UIImagePickerController.availableMediaTypes(for: sourceType)
        return mediaTypes?.contains(kUTTypeImage as String) ?? false
    }
    
    private static func presentCameraAccessDeniedAlert(from viewController: UIViewController, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: NSLocalizedString("Camera access is disabled", comment: ""),
            message: NSLocalizedString("To allow taking photos, enable Camera in System Settings.", comment: ""),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .cancel) { _ in
                completion()
            })
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Settings", comment: ""),
            style: .default) { _ in
                let settingsURL = URL(string: UIApplication.openSettingsURLString)!
                UIApplication.shared.openURL(settingsURL)
                completion()
            })
        
        viewController.present(alert, animated: true, completion: nil)
    }

    private static func actionString(for sourceType: UIImagePickerController.SourceType) -> String {
        switch sourceType {
        case .camera:
            return NSLocalizedString("Take Photo", comment: "Media Picker option")

        case .photoLibrary, .savedPhotosAlbum:
            return NSLocalizedString("Choose Photo", comment: "Media Picker option")

        @unknown default:
            return ""
        }
    }

    // MARK: UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[.originalImage] as? UIImage {
            complete(with: .photo(image: originalImage), picker: picker)
        } else if let originalImageURL = info[.referenceURL] as? URL {
            // There seem to be scenarios where only image URL would be contained in the result...
            print("Image picker returned asset URL instead of original image.")
            complete(withImageAssetURL: originalImageURL, from: picker)
        } else {
            assertionFailure("Expecting either original image or asset URL from image picker.")
            complete(with: .importFailed, picker: picker)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        complete(with: .cancelled, picker: picker)
    }
    
}
