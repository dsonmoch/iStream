//
//  LiveViewController.swift
//  iStream
//
//  Created by Admin on 01/11/22.
//

import UIKit
import AVFoundation
import HaishinKit

class LiveViewController: UIViewController{
    
    @IBOutlet weak var fpsLabel: UILabel!
    @IBOutlet weak var cameraFlipButton: UIButton!
    @IBOutlet weak var cameraZoomSlider: UISlider!
    @IBOutlet weak var liveView: UIView!
    @IBOutlet weak var flashLightToggleButton: UIButton!
    @IBOutlet weak var pauseToggleButton: UIButton!
    
    let rtmpConnection = RTMPConnection()
    private var rtmpStream: RTMPStream!
    private var sharedObject: RTMPSharedObject!
    private var currentPosition: AVCaptureDevice.Position = .back
    private var audio: Float!
    private var video: Float!
    private var fps: Float!
    private var retryCount: Int = 0
    var rtmpUrl: String = ""
    var streamKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rtmpConfig()
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if Thread.isMainThread{
            fpsLabel?.text = "\(rtmpStream.currentFPS) FPS"
        }
    }
    
    @IBAction func didTouchSettingsButton(_ sender: Any) {
        let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        settingsVC.delegate = self
        settingsVC.audioBitrate = audio / 1000
        settingsVC.videoBitrate = video / 1000
        settingsVC.videoFps = Float(rtmpStream.currentFPS)
        settingsVC.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    @IBAction func didTouchCameraFlipButton(_ sender: Any) {
        let position: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
        rtmpStream.captureSettings[.isVideoMirrored] = position == .front
        rtmpStream.attachCamera(DeviceUtil.device(withPosition: position)) { error in print(error)}
        currentPosition = position
    }
    @IBAction func sliderValueDidChange(_ slider: UISlider){
        rtmpStream.setZoomFactor(CGFloat(slider.value), ramping: true, withRate: 5.0)
    }
    @IBAction func didTapStopButton(_ sender: Any) {
        rtmpConnection.close()
        rtmpConnection.removeEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpConnection.removeEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
        rtmpStream?.removeObserver(self, forKeyPath: "currentFPS")
        navigateToHome()
    }
    @IBAction func didTapFlashLightToggleButton(_ sender: UIButton){
        print(rtmpStream.torch)
        if(!rtmpStream.torch){
            flashLightToggleButton.tintColor = UIColor.accentColor
            print("torch active")
        }else{
            flashLightToggleButton.tintColor = UIColor.white
            print("torch off")
        }
        rtmpStream.torch.toggle()
    }
    @IBAction func didTapPauseButton(_ sender: UIButton) {
        print(rtmpStream.paused)
        if(!rtmpStream.paused){
            pauseToggleButton.tintColor = UIColor.accentColor
        }else{
            pauseToggleButton.tintColor = UIColor.white
        }
        rtmpStream.paused.toggle()
    }
}

extension LiveViewController{
    
    func rtmpConfig(){
        rtmpStream = RTMPStream(connection: rtmpConnection)
        rtmpStream?.attachAudio(AVCaptureDevice.default(for: .audio)){ error in print(error) }
        rtmpStream?.attachCamera(DeviceUtil.device(withPosition: currentPosition)){ error in print(error) }
        if let orientation = DeviceUtil.videoOrientation(by: UIDevice.current.orientation){
            rtmpStream.orientation = orientation
        }
        rtmpStream.captureSettings = [
            .sessionPreset: AVCaptureSession.Preset.hd1280x720,
            .continuousAutofocus: true,
            .continuousExposure: true
        ]
        rtmpStream.videoSettings = [
            .width: 720,
            .height: 1280
        ]
        audio = Float(RTMPStream.defaultAudioBitrate) / 1000
        video = Float(RTMPStream.defaultVideoBitrate) / 1000
        rtmpStream?.addObserver(self, forKeyPath: "currentFPS", options: .new, context: nil)
        
        let hkView = HKView(frame: view.bounds)
        hkView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        hkView.attachStream(rtmpStream)
        liveView.addSubview(hkView)
        
        rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpConnection.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
        rtmpConnection.connect(rtmpUrl)
    }
    
    @objc
    private func rtmpStatusHandler(_ notification: Notification){
        let event = Event.from(notification)
        guard let data: ASObject = event.data as? ASObject, let code: String = data["code"] as? String else {
            return
        }
        switch code{
        case RTMPConnection.Code.connectSuccess.rawValue:
            retryCount = 0
            rtmpStream?.publish(streamKey)
        case RTMPConnection.Code.connectFailed.rawValue, RTMPConnection.Code.connectClosed.rawValue:
            guard retryCount <= 5 else { return }
            Thread.sleep(forTimeInterval: pow(2.0, Double(retryCount)))
            rtmpConnection.connect(rtmpUrl)
            retryCount += 1
        default:
            break
        }
    }
    
    @objc
    private func rtmpErrorHandler(_ notification: Notification){
        print(notification)
        rtmpConnection.connect(rtmpUrl)
    }

    func navigateToHome(){
        guard let homeViewController = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else { return  }
        self.navigationController!.pushViewController(homeViewController, animated: true)
    }
}

extension LiveViewController: SettingsProtocol{
    func settingsData(audioBitrate: Float, videoBitrate: Float, videoFps: Float) {
        let streamStatus = UiHelper.isStreamActive(rtmpStream: rtmpStream, fps: videoFps)
        if(!streamStatus){
            present(UiHelper.showErrorAlert("Error", "Not a valid stream key or url!", .alert), animated: true)
            return
        }
        rtmpStream.audioSettings[.bitrate] = audioBitrate * 1000
        audio = audioBitrate
        rtmpStream.videoSettings[.bitrate] = videoBitrate * 1000
        video = videoBitrate
        rtmpStream.captureSettings[.fps] = videoFps
    }
    
}
