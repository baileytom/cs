//
//  RockDropTextField.swift
//  RDrop
//
//  Created by Admin on 11/18/17.
//  Copyright © 2017 baileyth. All rights reserved.
//
import UIKit

class RockDropTextField: UITextField {
    
    override func awakeFromNib() {
        
        self.tintColor = THEME_COLOR3
        self.layer.borderWidth = 1.0
        self.layer.borderColor = THEME_COLOR3.cgColor
        self.layer.cornerRadius = 5.0
        
        self.textColor = THEME_COLOR3
        //self.backgroundColor = UIColor.clear
        self.borderStyle = .roundedRect
        
        guard let ph = self.placeholder  else {
            return
        }
        
        self.attributedPlaceholder =
            NSAttributedString(string: ph, attributes: [NSAttributedStringKey.foregroundColor :
                THEME_COLOR3])
    }
}

