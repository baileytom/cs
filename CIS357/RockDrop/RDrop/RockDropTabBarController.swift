//
//  RockDropTabBarController.swift
//  RDrop
//
//  Created by Gabe VanSolkema on 12/11/17.
//  Copyright © 2017 baileyth. All rights reserved.
//

import UIKit

class RockDropTabBarController: UITabBarController {

    @IBOutlet weak var navBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func addButtons() {
        let font = UIFontDescriptor(name: "DINPro", size: 12)
        
        let newRockBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 30))
        newRockBtn.setTitle("NEW ROCK", for: .normal)
        newRockBtn.titleLabel?.font = UIFont(descriptor: font, size: 12)
        newRockBtn.backgroundColor = UIColor.init(hex: "#555555")
        newRockBtn.layer.cornerRadius = 5
        newRockBtn.layer.masksToBounds = true
        newRockBtn.setTitleColor(THEME_COLOR7, for: .normal)
        newRockBtn.setTitleColor(THEME_COLOR2, for: .highlighted)
        newRockBtn.addTarget(self, action: #selector(newRockBtnPressed), for: UIControlEvents.touchUpInside)
        
        let logoutBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 30))
        logoutBtn.setTitle("LOGOUT", for: .normal)
        logoutBtn.titleLabel?.font = UIFont(descriptor: font, size: 12)
        logoutBtn.backgroundColor = UIColor.init(hex: "#555555")
        logoutBtn.layer.cornerRadius = 5
        logoutBtn.layer.masksToBounds = true
        logoutBtn.setTitleColor(THEME_COLOR5, for: .normal)
        logoutBtn.setTitleColor(THEME_COLOR1, for: .highlighted)
        logoutBtn.addTarget(self, action: #selector(logoutBtnPressed), for: UIControlEvents.touchUpInside)
        
        navBar.rightBarButtonItems = [UIBarButtonItem(customView: newRockBtn)]
        navBar.leftBarButtonItems = [UIBarButtonItem(customView: logoutBtn)]
    }
    
    @objc func newRockBtnPressed() {
        performSegue(withIdentifier: "newRock", sender: nil)
    }
    
    @objc func logoutBtnPressed() {
        performSegue(withIdentifier: "logout", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
