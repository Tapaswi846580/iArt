//
//  PreviewViewController.swift
//  iArt
//
//  Created by Tapaswi on 18/10/19.
//  Copyright © 2019 SCS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Photos
import Toast_Swift

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var FiltersCollectionView: UICollectionView!
    
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    var image: UIImage!
    var processedImage: UIImage!
    var listOfImage: Array<String> = ["Colorize","Retro","Wave","Rain","Muse","Scream","Sketch","Udine"]
    var selectedIndexPath: IndexPath?
    var alert: UIAlertController?
    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        FiltersCollectionView.allowsMultipleSelection = false
        
        btnCancel.layer.cornerRadius = btnCancel.frame.width / 2
        btnCancel.layer.shadowColor = UIColor.black.cgColor
        btnCancel.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnCancel.layer.masksToBounds = false
        btnCancel.layer.shadowRadius = 5.0
        btnCancel.layer.shadowOpacity = 1
        
        
        btnSave.layer.cornerRadius = min(btnSave.frame.width, btnSave.frame.height) / 2
        btnSave.layer.shadowColor = UIColor.black.cgColor
        btnSave.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnSave.layer.masksToBounds = false
        btnSave.layer.shadowRadius = 5
        btnSave.layer.shadowOpacity = 1
       

        photo.image = self.image
        photo.contentMode = UIView.ContentMode.scaleAspectFit
        
        let longPressGesture = UILongPressGestureRecognizer(target: self , action: #selector(longPressGestureRecognised(longPressGesture:)))
        longPressGesture.numberOfTapsRequired = 0
        longPressGesture.numberOfTouchesRequired = 1
        longPressGesture.minimumPressDuration = 0.5
        self.view.addGestureRecognizer(longPressGesture)

        impactFeedbackGenerator.prepare()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            if let layout = FiltersCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .vertical
                self.FiltersCollectionView.collectionViewLayout = layout
            }
        }else{
            if let layout = FiltersCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
                self.FiltersCollectionView.collectionViewLayout = layout
            }
        }
    }

    // MARK:- Long Press Gesture
    @objc func longPressGestureRecognised(longPressGesture: UILongPressGestureRecognizer){
        if longPressGesture.state == .began{
            impactFeedbackGenerator.impactOccurred()
            UIView.transition(with: self.photo,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.photo.image = self.image
                                self.btnCancel.isHidden = true
                                self.btnSave.isHidden = true
                                self.FiltersCollectionView.isHidden = true
            },
                              completion: {(completed) in
                                
            })
            
        }else if longPressGesture.state == .ended{
            impactFeedbackGenerator.impactOccurred()
            UIView.transition(with: self.photo,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.photo.image = self.processedImage == nil ? self.image : self.processedImage
                                self.btnCancel.isHidden = false
                                self.btnSave.isHidden = false
                                self.FiltersCollectionView.isHidden = false
            },
                              completion: {(completed) in })
            
        }
    }
    
    
    // MARK:- Save Button
    @IBAction func btnSaveClicked(_ sender: UIButton) {
        impactFeedbackGenerator.impactOccurred()
        let status = PHPhotoLibrary.authorizationStatus()
        impactFeedbackGenerator.impactOccurred()
        if status == PHAuthorizationStatus.authorized{
            if let p = processedImage, let i = self.image{
                let actionSheet = UIAlertController(title: "Select an image type", message: "", preferredStyle: .actionSheet)
                actionSheet.addAction(UIAlertAction(title: "Styled Image", style: .default, handler: { (action) in
                    UIImageWriteToSavedPhotosAlbum(p, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }))
                actionSheet.addAction(UIAlertAction(title: "Raw Image", style: .default, handler: { (action) in
                    UIImageWriteToSavedPhotosAlbum(i, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }))
                
                actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
                self.present(actionSheet, animated: true, completion: nil)
            }else{
                UIImageWriteToSavedPhotosAlbum(self.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
            
        }else if (status == PHAuthorizationStatus.denied){
            let alert = UIAlertController(title: "Access Denied", message: "Please allow access to save photo", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dont Allow", style: .destructive, handler: nil))
            alert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { (action) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }))
            
            self.present(alert,animated: true,completion: nil)
            
        }else if (status == PHAuthorizationStatus.notDetermined){
            PHPhotoLibrary.requestAuthorization { (status) in
                if(status == PHAuthorizationStatus.authorized){
                    
                    if let p = self.processedImage, let i = self.image{
                        let actionSheet = UIAlertController(title: "Select an image type", message: "", preferredStyle: .actionSheet)
                        actionSheet.addAction(UIAlertAction(title: "Styled Image", style: .default, handler: { (action) in
                            UIImageWriteToSavedPhotosAlbum(p, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                        }))
                        actionSheet.addAction(UIAlertAction(title: "Raw Image", style: .default, handler: { (action) in
                            UIImageWriteToSavedPhotosAlbum(i, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                        }))
                        
                        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
                        self.present(actionSheet, animated: true, completion: nil)
                    }else{
                        UIImageWriteToSavedPhotosAlbum(self.image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }
                }
            }
            
        }else if (status == PHAuthorizationStatus.restricted){
            let alert = UIAlertController(title: "Access Denied", message: "Please allow access to save photo", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dont Allow", style: .destructive, handler: nil))
            alert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { (action) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }))
        }
    }
    
    // MARK:- Cancel Button
    @IBAction func btnCancelClicked(_ sender: UIButton) {
         dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error = error{
//            showAlertWith(title: "Error", message: error.localizedDescription)
            showCompletionAlert(controller: self, message: "Error: \(error._code)", seconds: 1)
        }else{
//            showAlertWith(title: "Image Saved", message: "")
            showCompletionAlert(controller: self, message: "Image Saved", seconds: 1)
        }
    }
    
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

}
// MARK:- Collection View Delegates Extension
extension PreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.contentView.layer.cornerRadius = 5.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true;
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width:0,height: 0)
        cell.layer.shadowRadius = 3.5
        cell.layer.shadowOpacity = 1
        cell.layer.masksToBounds = false
        
        let imageView = cell.imageView!
        imageView.image = UIImage(named: listOfImage[indexPath.row])
        
        let label = cell.lblTitle!
        label.text = listOfImage[indexPath.row]
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        impactFeedbackGenerator.impactOccurred()
        let url = "http://172.20.10.2:5000/tapaswi/\(listOfImage[indexPath.row])"
        var image = self.image
        image = image?.resized(toWidth: 700)
        let imageData = image?.jpegData(compressionQuality: 1)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData!, withName: "photo", fileName: "1.jpg", mimeType: "image/jpeg")
            
            }, to: url) { (result) in
            switch result{
            case .success(let upload, _, _):
                self.showToast()
                upload.uploadProgress{ progress in
//                    print("Upload Progress: \(progress.fractionCompleted)")
                }

                upload.downloadProgress { (progress) in
//                    print("Download Progress: \(progress.fractionCompleted)")
                    if progress.fractionCompleted == 1.0{
                        self.hideToast()
                    }
                }
                
                upload.response { (response) in
                    if let err = response.error{
                        if err._code == -1001{
                            self.hideToast()
                            let alert = UIAlertController(title: "Server didn't responded 😔", message: "Error code: \(err._code)", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                            
                            self.present(alert, animated: true, completion: { () in
                                UIView.transition(with: self.photo,
                                                  duration: 0.3,
                                                  options: .transitionCrossDissolve,
                                                  animations: { self.photo.image = self.image },
                                                  completion: nil)
                            })
                            
                        }else{
                           self.hideToast()
                            let alert = UIAlertController(title: "Something went wrong 😔", message: "Error code: \(err._code)", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                            
                            self.present(alert, animated: true, completion: { () in
                                UIView.transition(with: self.photo,
                                                  duration: 0.3,
                                                  options: .transitionCrossDissolve,
                                                  animations: { self.photo.image = self.image },
                                                  completion: nil)
                            })
                        }
                    }else{
                        self.processedImage = UIImage(data: response.data!)
                        UIView.transition(with: self.photo,
                                          duration: 0.3,
                                          options: .transitionCrossDissolve,
                                          animations: { self.photo.image = self.processedImage },
                                          completion: nil)
                    }
                    
                }
            case .failure(let error):
                self.hideToast()
                let alert = UIAlertController(title: "Something went wrong 😔", message: "Error code: \(error._code)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true, completion: { () in
                UIView.transition(with: self.photo, duration: 0.3, options: .transitionCrossDissolve,
                        animations: { self.photo.image = self.image },
                                  completion: nil)
                        })
            }
        }
        
        if selectedIndexPath != nil && selectedIndexPath != indexPath{
            collectionView.reloadItems(at: [selectedIndexPath!])
        }
        
        if selectedIndexPath != indexPath || selectedIndexPath == nil{
            selectedIndexPath = indexPath
            let selectedCell = FiltersCollectionView.cellForItem(at: indexPath) as? CollectionViewCell
            selectedCell?.isSelected = true
            collectionView.bringSubviewToFront(selectedCell!)
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 0, options: [], animations: {
                    selectedCell?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            })
        }
        
    }
    
    // MARK:- Toast
    func showToast(){
        self.view.makeToastActivity(.center)
    }
    
    func hideToast(){
        self.view.hideAllToasts(includeActivity: true, clearQueue: true)
    }
    
    func showCompletionAlert(controller: UIViewController, message : String, seconds: Double){
        alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert!.view.backgroundColor = .black
        alert!.view.alpha = 0.5
        alert!.view.layer.cornerRadius = 15
    
        controller.present(alert!, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            self.alert?.dismiss(animated: true, completion: nil)
        }
    }
    
    
}

// MARK:- UIImage extension
extension UIImage{
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}

