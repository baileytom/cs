//
//  RockOverlayView.swift
//  RDrop
//
//  Created by Admin on 11/13/17.
//  Copyright © 2017 baileyth. All rights reserved.
//

import UIKit
import Koloda

class RockOverlayView: OverlayView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "OverlayView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

}
