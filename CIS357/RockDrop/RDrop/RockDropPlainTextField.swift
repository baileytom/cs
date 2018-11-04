//
//  RockDropPlainTextField.swift
//  RDrop
//
//  Created by Gabe VanSolkema on 12/10/17.
//  Copyright © 2017 baileyth. All rights reserved.
//

import UIKit

class RockDropPlainTextField: UITextField {

    override func awakeFromNib() {
        self.autocorrectionType = .no
        
        if #available(iOS 11, *) {
            // Disables the password autoFill accessory view.
            self.textContentType = UITextContentType("")
        }
    }
    

}
