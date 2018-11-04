//
//  RockDropButton.swift
//  RDrop
//
//  Created by Admin on 11/15/17.
//  Copyright © 2017 baileyth. All rights reserved.
//

import UIKit

class RockDropButton: UIButton {
    
    override func awakeFromNib() {
        self.backgroundColor = THEME_COLOR3
        self.tintColor = THEME_COLOR2
        self.layer.borderWidth = 1.0
        self.layer.borderColor = THEME_COLOR3.cgColor
        self.layer.cornerRadius = 5.0
    }
}

