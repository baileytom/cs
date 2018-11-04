//
//  NewRockViewController.swift
//  RDrop
//
//  Created by Admin on 11/18/17.
//  Copyright © 2017 baileyth. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class NewRockViewController: GradientViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var descTextView: UITextView!
    
    fileprivate var ref : DatabaseReference?
    
    var rocks : [Rock]?
    
    let user = Auth.auth().currentUser
    
    @IBAction func createRockButtonPressed(_ sender: Any) {
        
        let newChild = self.ref?.child("rocks").childByAutoId()
        
        let id = newChild?.key
        
        nameTextField.textColor = THEME_COLOR7
        
        let rock = Rock(name: nameTextField.text!, id: id, points: 0, description: descTextView.text!, user: user?.uid, lat : 0, lng : 0, dropped : false)
        
        if (!buyRock()) {
            
            let dialogMessage = UIAlertController(title: "Not enough points!", message: "It takes 5 points to get a new rock.", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                return
            })
            dialogMessage.addAction(ok)
            self.present(dialogMessage, animated: true, completion: nil)

            
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        if isValidRock(item: rock) {
            newChild?.setValue(self.toDictionary(vals: rock))
            
            let dialogMessage = UIAlertController(title: "Rock created.", message: "Your new rock was created!", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                return
            })
            dialogMessage.addAction(ok)
            self.present(dialogMessage, animated: true, completion: nil)
            
            registerForFireBaseUpdates()
            
            self.dismiss(animated: true, completion: nil)
            return


        } else {
            let dialogMessage = UIAlertController(title: "Name taken", message: "This name is taken!", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                return
            })
            dialogMessage.addAction(ok)
            self.present(dialogMessage, animated: true, completion: nil)
            
            
            self.dismiss(animated: true, completion: nil)
            return

        }
    }
    
    func getPointsForUser(uid : String) -> Int {
        var rpoints : Int?
        self.ref?.child("/user/" + uid).observe(.value, with: { snapshot in
            if let postDict = snapshot.value as? [String : AnyObject] {
                for (_,val) in postDict.enumerated() {
                    let entry = val.1 as! Dictionary<String,AnyObject>
                    let points = entry["points"] as! Int?
                    rpoints = points
             
                }
            } else {
                rpoints = -1
                print("error getting data")
            }
        })
        return rpoints!
    }

    func buyRock () -> Bool {
        let uid = user?.uid
        
        let points = Int(pointsLabel.text!)

        //if (points! < 5) {
        //    return false;
        //}
        
        self.ref?.child("/user/" + uid!).observeSingleEvent(of: .value, with: { snapshot in
            let valString = snapshot.value as! NSDictionary
            var value = valString["points"] as! Int
            value = value - 5
            self.ref?.child("/user/" + uid!).setValue(["points": value])
        })
        return true;
    }
    
    fileprivate func registerForFireBaseUpdates()
    {
        
        self.ref!.child("rocks").observe(.value, with: { snapshot in
            if let postDict = snapshot.value as? [String : AnyObject] {
                var tmpItems = [Rock]()
                for (_,val) in postDict.enumerated() {
                    let entry = val.1 as! Dictionary<String,AnyObject>
                    let name = entry["name"] as! String?
                    let points = entry["points"] as! Int?
                    let description = entry["description"] as! String?
                    let dropped = entry["dropped"] as! Bool
                    let user = entry["user"] as! String?
                    let lat = entry["lat"] as! Double?
                    let lng = entry["lng"] as! Double?
                    let id = entry["id"] as! String?
                    
                    tmpItems.append(Rock(name: name!, id: id!, points: points!, description: description!, user: user!, lat: lat!, lng: lng!, dropped: dropped))
                }
                self.rocks = tmpItems
            } else {
                print("error getting data")
            }
        })
        
    }
    
    func updatePointsLabel() -> Void {
        self.ref?.child("/user/" + (user?.uid)!).observe(.value, with: { snapshot in
            if let postDict = snapshot.value as? [String : AnyObject] {
                for (_,val) in postDict.enumerated() {
                    //let entry = val.0 as! Dictionary<String,AnyObject>
                    let points = val.1 as! Int
                    
                    self.pointsLabel.text = "\(points)"
                                    }
            } else {
                print("error getting data")
            }
        })
    }

    
    func isValidRock(item: Rock) -> Bool {
        if let _ = rocks {
            for a in rocks! {
                if (item.name == a.name) {
                    return false
                }
            }
        }
        return true
    }
    
    
    func toDictionary(vals: Rock) -> NSDictionary {
        return [
            "name": NSString(string: vals.name!),
            "points" : NSNumber(value: vals.points!),
            "description" : NSString(string: vals.description!),
            "id" : NSString(string: vals.id!),
            "user" : NSString(string: vals.user!),
            "lat" : NSNumber(value: vals.lat!),
            "lng" : NSNumber(value: vals.lng!),
            "dropped" : NSNumber(value: (vals.dropped))
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.ref = Database.database().reference()
        
        self.view.backgroundColor = THEME_COLOR8

        registerForFireBaseUpdates()
        
        updatePointsLabel()
        
        descTextView.layer.borderColor = UIColor.init(hex: "#777777").cgColor
        descTextView.layer.borderWidth = 1
        descTextView.backgroundColor = UIColor.init(hex: "#EEEEEE", alpha: 0.1)
        descTextView.layer.cornerRadius = 5
        nameTextField.layer.borderWidth = 0
        nameTextField.layer.borderColor = UIColor.clear.cgColor
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name",
                                                              attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(hex: "#BBBBBB")])
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBackBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
