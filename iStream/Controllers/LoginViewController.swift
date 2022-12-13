//
//  LoginViewController.swift
//  iStream
//
//  Created by Admin on 31/10/22.
//

import UIKit
import SkyFloatingLabelTextField

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.handleKeyboardView()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func didTapLogin(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else{
            present(UiHelper.showErrorAlert("Empty", "Email field should not be empty!", .alert), animated: true)
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else{
            present(UiHelper.showErrorAlert("Empty", "Password field should not be empty!", .alert), animated: true)
            return
        }
        if(isValidUser(email: email, password: password)){
            navigateToHome()
        }
    }
    
    func isValidUser(email: String, password: String) -> Bool{
       return true
    }
    
    func navigateToHome(){
        guard let homeViewController = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else { return  }
        self.navigationController!.pushViewController(homeViewController, animated: true)
    }
    
}
