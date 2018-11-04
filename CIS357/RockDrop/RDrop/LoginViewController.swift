//
//  LgoinViewController.swift
//  TraxyApp
//
//  Created by Jonathan Engelsma on 11/2/16.
//  Copyright © 2016 Jonathan Engelsma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var validationErrors = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.view.backgroundColor = THEME_COLOR2
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // dismiss keyboard when tapping outside of text fields
        let detectTouch = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(detectTouch)
        
        // make this controller the delegate of the text fields.
        self.emailField.delegate = self
        self.passwordField.delegate = self
        
        
        let defaults = UserDefaults.standard
        if let email = defaults.string(forKey: defaultsKeys.email.rawValue) {
            self.emailField.text = email
        }
        if let pw = defaults.string(forKey: defaultsKeys.password.rawValue) {
            self.passwordField.text = pw
        }
        
        if ((self.emailField.text?.isEmpty)! || (self.passwordField.text?.isEmpty)!) {
            print("Not enough local user data found to attempt login")
        } else {
            login()
        }
        
        // Set placeholder text and color.
        emailField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                              attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(hex: "#BBBBBB")])
        
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                 attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(hex: "#BBBBBB")])
        //self.emailField.tintColor = UIColor.white
        
        // for dev
        //self.emailField.text = "tom@tom.com"
        //self.passwordField.text = "123456"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    func validateFields() -> Bool {
        
        self.validationErrors = ""
        
        let pwOk = self.isEmptyOrNil(str: self.passwordField.text)
        if !pwOk {
            self.validationErrors += "Password cannot be blank. "
        }
        
        let emailOk = self.isValidEmail(emailStr: self.emailField.text)
        if !emailOk {
            self.validationErrors += "Invalid email address."
        }
        
        return emailOk && pwOk
    }
    
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        login()
    }
    
    func login() {
        if self.validateFields() {
            print("Congratulations!  You entered correct values.")
            Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!) { (user, error) in
                if let _ = user {
                    let defaults = UserDefaults.standard
                    defaults.set(self.emailField.text, forKey: defaultsKeys.email.rawValue)
                    defaults.set(self.passwordField.text, forKey: defaultsKeys.password.rawValue)
                    self.performSegue(withIdentifier: "segueToMain", sender: self)
                } else {
                    DispatchQueue.main.async {
                        self.reportError(msg: (error?.localizedDescription)!)
                    }
                    self.passwordField.text = ""
                    self.passwordField.becomeFirstResponder()
                }
            }
        } else {
            DispatchQueue.main.async {
                self.reportError(msg: self.validationErrors)
            }
        }
    }
    
    // Unwind segue function
    @IBAction func logout(segue: UIStoryboardSegue) {
        print("Logged out")
        self.passwordField.text = ""
        let defaults = UserDefaults.standard
        defaults.set(self.emailField.text, forKey: defaultsKeys.email.rawValue)
        defaults.set("", forKey: defaultsKeys.password.rawValue)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -75 // Move view 75 points upward
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailField {
            self.passwordField.becomeFirstResponder()
        } else {
            if self.validateFields() {
                print("Congratulations!  You entered correct values.")
            }
        }
        return true
    }
}
