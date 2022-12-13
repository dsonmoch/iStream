//
//  Utilities.swift
//  iStream
//
//  Created by Admin on 31/10/22.
//

import Foundation
import UIKit

class Utilities{
    
    static func styleTextField(_ textField: UITextField){
    }
    
    static func styleHollowButton(_ button: UIButton){
        button.layer.cornerRadius = 25.0
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.accentColor?.cgColor
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        let passwordRegx = "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegx)
        return passwordTest.evaluate(with: password)
    }
}
