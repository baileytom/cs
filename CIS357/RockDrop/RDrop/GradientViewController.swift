//
//  GradientViewController.swift
//  
//
//  Created by Admin on 12/8/17.
//
//

import UIKit

class GradientViewController: UIViewController {

    let grad = CAGradientLayer()

    //let colors = [UIColor(red: 36/255.0, green: 123/255.0, blue: 160/255.0, alpha: 1.0).cgColor, UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0).cgColor] as [Any]
    
    let colors = [UIColor(red: 60/255.0, green: 60/255.0, blue: 60/255.0, alpha: 1.0).cgColor, UIColor(red: 130/255.0, green: 130/255.0, blue: 130/255.0, alpha: 1.0).cgColor] as [Any]
    
    override func viewWillAppear(_ animated: Bool) {
        grad.frame = self.view.frame
        
        grad.colors = colors
        
        grad.locations = [0.2,0.8]
        
        self.view.layer.insertSublayer(grad, at: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        grad.frame = self.view.frame

        grad.colors = colors
        
        grad.locations = [0.2,0.8]
        
        self.view.layer.insertSublayer(grad, at: 0)


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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

