//
//  SettingsViewController.swift
//  iStream
//
//  Created by Admin on 02/11/22.
//

import UIKit

protocol SettingsProtocol{
    func settingsData(audioBitrate: Float, videoBitrate: Float, videoFps: Float)
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var fpsSegmentControl: UISegmentedControl!
    @IBOutlet weak var audioBitrateLabel: UILabel!
    @IBOutlet weak var audioBitrateSlider: UISlider!
    @IBOutlet weak var videoBitrateLabel: UILabel!
    @IBOutlet weak var videoBitrateSlider: UISlider!
    var audioBitrate: Float!
    var videoBitrate: Float!
    var videoFps: Float!
    var delegate: SettingsProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let audio = audioBitrate * 1000
        let video = videoBitrate * 1000
        let fps = videoFps
        delegate?.settingsData(audioBitrate: audio, videoBitrate: video, videoFps: fps!)
    }
    
    @IBAction func fpsDidChange(_ segment: UISegmentedControl) {
        switch segment.selectedSegmentIndex{
        case 0:
            videoFps = 15.0
        case 1:
            videoFps = 30.0
        case 2:
            videoFps = 60.0
        default:
            return
        }
    }
    
    @IBAction func onSliderValueChange(_ slider: UISlider) {
        if slider == audioBitrateSlider{
            audioBitrateLabel?.text = "\(Int(slider.value)) kbps"
            audioBitrate = slider.value / 1000
            audioBitrateSlider.value = audioBitrate * 1000
        }
        if slider == videoBitrateSlider{
            videoBitrateLabel?.text = "\(Int(slider.value)) kbps"
            videoBitrate = slider.value / 1000
            videoBitrateSlider.value = videoBitrate * 1000
        }
    }
    
    func setDefaults(){
        switch videoFps!{
        case 15.0..<25.0:
            fpsSegmentControl.selectedSegmentIndex = 0
        case 25.0..<32.0:
            fpsSegmentControl.selectedSegmentIndex = 1
        case 32.0..<60.0:
            fpsSegmentControl.selectedSegmentIndex = 2
        default:
            fpsSegmentControl.selectedSegmentIndex = 1
        }
        videoBitrateSlider.value = videoBitrate * 1000
        videoBitrateLabel?.text = "\(Int(videoBitrate * 1000)) kbps"
        audioBitrateSlider.value = audioBitrate * 1000
        audioBitrateLabel?.text = "\(Int(audioBitrate * 1000)) kbps"
    }
    
}
