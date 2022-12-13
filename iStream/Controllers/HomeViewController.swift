//
//  HomeViewController.swift
//  iStream
//
//  Created by Admin on 01/11/22.
//

import UIKit
import AVFoundation
import HaishinKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var rtmpUrlTextField: UITextField!
    @IBOutlet weak var streamKeyTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.handleKeyboardView()
        self.hideKeyboardWhenTappedAround() 
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let rtmpUrl = rtmpUrlTextField.text ?? ""
        let streamKey = streamKeyTextField.text ?? ""
        if(rtmpUrl == ""){
            present(UiHelper.showErrorAlert("Error", "Please Enter your stream url", .alert), animated: true)
            return
        }else if (streamKey == ""){
            present(UiHelper.showErrorAlert("Error", "Please Enter your stream key", .alert), animated: true)
            return
        }
        let liveVC = segue.destination as! LiveViewController
        liveVC.rtmpUrl = rtmpUrl
        liveVC.streamKey = streamKey
    }
}
