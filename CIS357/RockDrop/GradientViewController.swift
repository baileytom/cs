//
//  GradientViewController.swift
//  
//
//  Created by Admin on 12/8/17.
//
//

import UIKit
import CATransform3DMakeRotation
import CAGradientLayer

class GradientViewController: UIViewController {

    let grad = CAGradientLayer

    let colors = [UIColor(red: 0/255.0, green: 201/255.0, blue: 255/255.0, alpha: 1.0).cgColor, UIColor(red: 146/255.0, green: 254/255.0, blue: 157/255.0, alpha: 1.0).cgColor] as [Any]
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        grad.frame = self.view.frame

        grad.colors = colors
        
        grad.locations = [0.0,0.7]
        
        self.view.layer.addSublayer(grad)


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

