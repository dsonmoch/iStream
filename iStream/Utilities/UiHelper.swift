//
//  UiHelper.swift
//  iStream
//
//  Created by Admin on 31/10/22.
//

import Foundation
import UIKit
import HaishinKit

class UiHelper{
    static func showErrorAlert(_ title: String,_ message: String,_ style: UIAlertController.Style) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.view.tintColor = UIColor.accentColor
        return alert
    }
    
    static func isStreamActive(rtmpStream: RTMPStream, fps: Float) -> Bool{
        if(rtmpStream.currentFPS < 10){
            return false
        }
        return true
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func handleKeyboardView(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y = -150
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0
    }
    
    
}
