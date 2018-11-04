//
//  SwipeViewController.swift
//  RDrop
//
//  Created by Admin on 11/13/17.
//  Copyright © 2017 baileyth. All rights reserved.
//

import UIKit
import Koloda
import FirebaseDatabase
import FirebaseAuth

class SwipeViewController: GradientViewController {
    
    fileprivate var ref : DatabaseReference?
    
    
    @IBOutlet weak var kolodaView: CustomKolodaView!
    
    var rocks : [Rock]?
    
    var endLabel : RockDropLabel?
    var swipeInstLabel : RockDropLabel?
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loc.requestWhenInUseAuthorization()
        
        endLabel = RockDropLabel(frame: CGRect(x:0/*(screenWidth/2)*/, y:50, width:UIScreen.main.bounds.width, height:50))
        endLabel?.textAlignment = NSTextAlignment.center
        endLabel?.text = "No more rocks nearby :("
        endLabel?.textColor = THEME_COLOR5
        endLabel?.isHidden = true
        endLabel?.font = UIFont(name: "DINPro", size: 12)
        self.kolodaView.addSubview(endLabel!)
        
        swipeInstLabel = RockDropLabel(frame: CGRect(x:0/*(screenWidth/2)*/, y:500, width:UIScreen.main.bounds.width, height:50))
        swipeInstLabel?.textAlignment = NSTextAlignment.center
        swipeInstLabel?.text = "If you like what you see, SWIPE RIGHT ;)"
        swipeInstLabel?.textColor = THEME_COLOR5
        swipeInstLabel?.isHidden = false
        swipeInstLabel?.font = UIFont(name: "DINPro", size: 12)
        self.kolodaView.addSubview(swipeInstLabel!)
        
        
        self.ref = Database.database().reference()
        self.registerForFireBaseUpdates()
    
        //self.view.backgroundColor = THEME_COLOR2
        
        //let model = RockModel()
        //self.rocks = model.items
        
        
        self.kolodaView.delegate = self
        self.kolodaView.dataSource = self
        
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            print(user.uid)
            print(user.email!)
            //let photoURL = user.photoURL
            // ...
        }

        // Do any additional setup after loading the view.
        //self.kolodaView.reloadData()
    }

    func incrementPointsForUserB(uid : String) -> Void {
        self.ref?.child("/user/" + uid).observe(.value, with: { snapshot in
            if let postDict = snapshot.value as? [String : AnyObject] {
                for (_,val) in postDict.enumerated() {
                    let entry = val
                    let points = entry.1 as! Int
                    self.ref?.child("/user/" + uid).updateChildValues(["points" : points+1])

                }
            } else {
                print("error getting data")
            }
        })
    }
    
    func incrementPointsForUser(uid : String) -> Void {
        self.ref?.child("/user/" + uid).observeSingleEvent(of: .value, with: { snapshot in
            let valString = snapshot.value as! NSDictionary
            var value = valString["points"] as! Int
            value = value + 1
            self.ref?.child("/user/" + uid).setValue(["points": value])
        })
    }

    // Database
    
    // Read updates from firebase
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
                    let dropped = entry["dropped"] as! Bool?
                    let user = entry["user"] as! String?
                    let lat = entry["lat"] as! Double?
                    let lng = entry["lng"] as! Double?
                    let id = entry["id"] as! String?
                    
                    let rock = Rock(name: name!, id: id!, points: points!, description: description!, user: user!, lat: lat!, lng: lng!, dropped: dropped!)
                    
                    let distance = rock.getLocation().distance(from: loc.location!)
                    
                    if (user != Auth.auth().currentUser?.uid && dropped! && (distance < 1000)) {
                        tmpItems.append(rock)
                    }
                    //tmpItems.append(Rock(name: name!, description: description!, user: user!, lat: lat!, lng: lng!))
                }
                self.rocks = tmpItems
                self.kolodaView.reloadData()
                self.endLabel?.isHidden = false
            } else {
                print("error getting data")
            }
        })
        
    }
    func toDictionary(vals: Rock) -> NSDictionary {
        return [
            "name": NSString(string: vals.name!),
            "points" : NSNumber(value: vals.points!),
            "description" : NSString(string: vals.description!),
            "id" : NSString(string: vals.id!),
            "user" : NSString(string: vals.user!),
            "lat" : NSNumber(value: vals.lat!),
            "lng" : NSNumber(value: vals.lng!)
        ]
    }
    // What happens when you swipe a card
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        print(direction)
        
        let rock = rocks![index]
        
        incrementPointsForUser(uid: (Auth.auth().currentUser?.uid)!)
        
        if (direction == SwipeResultDirection.right) {
            
            incrementPointsForUser(uid: rock.user!)
            
            self.ref?.child("/rocks/" + rock.id!).updateChildValues(["points" : rock.points!+1])
        } else {
            self.ref?.child("/rocks/" + rock.id!).updateChildValues(["points" : rock.points!-1])
        }
        
        
        
        /*
        let newChild = self.ref?.child("rocks").childByAutoId()
        newChild?.setValue(self.toDictionary(vals: rock))
        */
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

extension SwipeViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        koloda.reloadData()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
    }
}

extension SwipeViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        if let rocks = self.rocks {
            return rocks.count
        } else {
            return 0
        }
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .slow
    }
    
    
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        //let screenHeight = screenSize.height
        
        let rock = rocks![index]
        
        // UIView
        let frame = CGRect(x:1, y:1, width:1, height:1)
        let myview = UIView(frame: frame)
        myview.backgroundColor=UIColor.white
        myview.layer.cornerRadius = 25
        myview.layer.borderWidth = 2
        myview.layer.borderColor = UIColor.black.cgColor
        
        
        // Name label
        let nameLabel = RockDropLabel(frame: CGRect(x:(screenWidth/2)-125, y:10, width:200, height:50))
        nameLabel.textAlignment = NSTextAlignment.center
        nameLabel.text = rock.name
        myview.addSubview(nameLabel)
        
        // Description label
        let descLabel = RockDropLabel(frame: CGRect(x:(screenWidth/2)-125, y:30, width:200, height:50))
        descLabel.textAlignment = NSTextAlignment.center
        descLabel.text = rock.description
        myview.addSubview(descLabel)
        
        // Points label
        let pointLabel = RockDropLabel(frame: CGRect(x:(screenWidth/2)-75, y:50, width:100, height:50))
        pointLabel.textAlignment = NSTextAlignment.center
        pointLabel.text = "Points: \(rock.points!)"
        myview.addSubview(pointLabel)
        
        // Image view
        let myImage = UIImageView(image: #imageLiteral(resourceName: "hugerock"))
        myImage.clipsToBounds = true
        
        myImage.frame = CGRect(x: screenSize.width/2-125, y: screenSize.height/2-200, width: 200, height: 200)
        
        
        myview.addSubview(myImage)
        /*
        
        let text = rocks![index].name! + "\(rocks![index].points!)" as NSString
        
        let myrock = textToImage(drawText: text, inImage: #imageLiteral(resourceName: "rock_image"), atPoint: CGPoint(x:200, y:100))
        let myview = UIImageView(image: myrock)
        */
        return myview
    }
    
    func textToImage(drawText text: NSString, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica Bold", size: 24)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        let textFontAttributes = [
            NSAttributedStringKey.font.rawValue: textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            ] as! [NSAttributedStringKey : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    //func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
    //    return rocks![index] as OverlayView
     //       //Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)[0] as? OverlayView
    //}*/
}
