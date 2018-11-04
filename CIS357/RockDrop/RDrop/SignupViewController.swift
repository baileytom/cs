//
//  SignupViewController.swift
//  RDrop
//
//  Created by Admin on 11/17/17.
//  Copyright © 2017 baileyth. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SignupViewController: LoginViewController {

    fileprivate var ref : DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        self.emailField.text = ""
        self.passwordField.text = ""
    }

    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SignupButtonWasPressed(_ sender: UIButton) {
        if self.validateFields() {
            Auth.auth().createUser(withEmail: self.emailField.text!, password: self.passwordField.text!) { (user, error) in
                if let  _ = user {
                    let newUser = self.ref?.child("user").child((user?.uid)!)
                    newUser?.setValue(["points" : NSNumber(value: 10)] as NSDictionary)
                    
                    self.login()
                    
                    //self.dismiss(animated: false, completion: nil)
                    
                } else {
                    self.passwordField.text = ""
                    self.passwordField.becomeFirstResponder()
                    DispatchQueue.main.async {
                        self.reportError(msg: (error?.localizedDescription)!)
                    }
                }
            }
        } else {
            self.reportError(msg: self.validationErrors)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
