//
//  ViewController.swift
//  iArt
//
//  Created by Tapaswi on 17/10/19.
//  Copyright © 2019 SCS. All rights reserved.
//

import UIKit
import AVFoundation
    
class ViewController: UIViewController {

    
    @IBOutlet weak var btnCapture: UIButton!
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput : AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var movieFileOutput: AVCaptureMovieFileOutput?
    
    var image: UIImage?
    var accessGranted: Bool?
    var usingFrontCamera = false
    var flashON = false;
    
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 5.0
    var lastZoomFactor: CGFloat = 1.0
    
    var imagePicker = UIImagePickerController()
    
    private var flashMode: AVCaptureDevice.FlashMode = .off
    
    
    // MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        btnCapture.layer.borderColor = UIColor.white.cgColor
        btnCapture.layer.borderWidth = 5
        btnCapture.layer.cornerRadius = min(btnCapture.frame.width, btnCapture.frame.height) / 2
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            setupCaptureSession()
            setupDevice(camera: usingFrontCamera)
            setupInputOutput()
            setupPreviewLayer()
            startRunningCaptureSession()
            accessGranted = true
        }else {
            accessGranted = false
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized(tapGesture:)))
        tapGesture.numberOfTapsRequired = 2
        tapGesture.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureRecognized(pinch:)))
        self.view.addGestureRecognizer(pinchGesture)
        
        imagePicker.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.notDetermined {
            
            let alert = UIAlertController(title: "Let iArt Access Camera ?", message: "This lets you take photos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Give Access", style: .default, handler: { (action) in
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                    
                    if granted == true {
                        DispatchQueue.main.async {
                            self.setupCaptureSession()
                            self.setupDevice(camera: self.usingFrontCamera)
                            self.setupInputOutput()
                            self.setupPreviewLayer()
                            self.startRunningCaptureSession()
                            self.accessGranted = true
                        }

                    } else {
                     self.accessGranted = false
                    }
                })
            }))
            self.present(alert,animated: true, completion: nil)
            
        }else if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.denied {
            let alert = UIAlertController(title: "Let iArt Access Camera ?", message: "This lets you take photos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Give Access", style: .default, handler: { (action) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                
            }))
            self.present(alert,animated: true, completion: nil)
            
        }else if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.restricted {
            let alert = UIAlertController(title: "Let iArt Access Camera ?", message: "This lets you take photos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Give Access", style: .default, handler: { (action) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                
            }))
            self.present(alert,animated: true, completion: nil)
        }
    }
    
    
    //MARK:- Pinch Gesture Recognized
    @objc func pinchGestureRecognized(pinch: UIPinchGestureRecognizer)  {
        let device = currentCamera!
        
        // Return zoom value between the minimum and maximum zoom values
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }
        
        let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)
        
        switch pinch.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
        default: break
        }
        
    }
    
    //MARK:- Tap Gesture recognized
    @objc func tapGestureRecognized(tapGesture: UITapGestureRecognizer)  {
        usingFrontCamera = !usingFrontCamera
        cameraPreviewLayer?.removeFromSuperlayer()
        for i : AVCaptureDeviceInput in (self.captureSession.inputs as! [AVCaptureDeviceInput]){
            self.captureSession.removeInput(i)
        }
        captureSession.removeOutput(photoOutput!)
        captureSession.stopRunning()
        
        setupCaptureSession()
        setupDevice(camera: usingFrontCamera)
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let screenSize = self.view.bounds.size
        if let touchPoint = touches.first{
            let x = touchPoint.location(in: self.view).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: self.view).x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)
            
            if let device = currentCamera{
                do{
                    try device.lockForConfiguration()
                    if device.isFocusPointOfInterestSupported {
                        device.focusPointOfInterest = focusPoint
                        device.focusMode = .continuousAutoFocus
                        if device.isSmoothAutoFocusSupported{
                            device.isSmoothAutoFocusEnabled = true
                        }
                    }
                    if device.isExposurePointOfInterestSupported {
                        device.exposurePointOfInterest = focusPoint
                        device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                    }
                    device.unlockForConfiguration()
                }catch{
                    print(error)
                }
            }
        }
    }
    
    
    // MARK:- Flash button
    @IBAction func btnFlash(_ sender: UIButton) {
        sender.showsTouchWhenHighlighted = true
        flashON = !flashON
        sender.setImage((flashON ? UIImage(named: "flash_on") : UIImage(named: "flash_off")), for: .normal)
        flashMode = (flashON ? .on : .off)
    }
    
    // MARK:- Toggle Camera button
    @IBAction func btnSwitchCamera(_ sender: UIButton) {
        sender.showsTouchWhenHighlighted = true
        usingFrontCamera = !usingFrontCamera
        cameraPreviewLayer?.removeFromSuperlayer()
        for i : AVCaptureDeviceInput in (self.captureSession.inputs as! [AVCaptureDeviceInput]){
            self.captureSession.removeInput(i)
        }
        captureSession.removeOutput(photoOutput!)
        captureSession.stopRunning()
        
        setupCaptureSession()
        setupDevice(camera: usingFrontCamera)
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    
    //MARK:- Gallery button
    @IBAction func btnGallery(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK:- Capture button
    @IBAction func btnCaptureClicked(_ sender: UIButton) {
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(.warning)
        let colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        colorAnimation.fromValue = UIColor.white.cgColor
        colorAnimation.duration = 1  // animation duration
        sender.layer.add(colorAnimation, forKey: "ColorPulse")
        let settings = getSettings(camera: currentCamera!, flashMode: flashMode)
        photoOutput?.capturePhoto(with: settings, delegate: self)
        
    }
    
    //MARK:- Setting up Capture Session
    func setupCaptureSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    // MARK:- Setting up the AVCapture Device
    func setupDevice(camera: Bool){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        for device in devices {
            if device.position == AVCaptureDevice.Position.back{
                backCamera = device
            }else if device.position == AVCaptureDevice.Position.front{
                frontCamera = device
            }
        }
        currentCamera = (usingFrontCamera ? frontCamera : backCamera)
    }
    
    // MARK:- Setting up Output for AVCapturePhotoOutput
    func setupInputOutput(){
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        }catch {
            print("Error: \(error)")
        }
        
    }
    
    // MARK:- Setting up Preview Layer for AVCaptureVideoPreviewLayer
    func setupPreviewLayer(){
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    // MARK:- Starting Session
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }
    
    // MARK:- Getting settings for Flash
    private func getSettings(camera: AVCaptureDevice, flashMode: AVCaptureDevice.FlashMode) -> AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()

        if camera.hasFlash {
            settings.flashMode = flashMode
        }
        return settings
    }
    
    // MARK:- Preparing Segue for PreviewViewController for showing camera image
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotoSegue"{
            let previewVC = segue.destination as! PreviewViewController
            previewVC.image = self.image
        }
    }
}

// MARK:- Extension ViewController for all the delegates
extension ViewController: AVCapturePhotoCaptureDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(){
            image = UIImage(data: imageData)
            performSegue(withIdentifier: "showPhotoSegue", sender: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.image = pickedImage
        }
       
        dismiss(animated: true) {
            self.performSegue(withIdentifier: "showPhotoSegue", sender: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
