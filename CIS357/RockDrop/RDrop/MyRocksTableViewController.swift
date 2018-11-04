//
//  MyRocksTableViewController.swift
//  RDrop
//
//  Created by Admin on 11/13/17.
//  Copyright © 2017 baileyth. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MyRocksTableViewController: GradientTableViewController {

    @IBOutlet weak var myRocksTableView: UITableView!
    
    fileprivate var ref : DatabaseReference?
    
    let wAPI = DarkSkyWeatherService.getInstance()
    
    var rocks : [Rock]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = THEME_COLOR2
        
                
        self.ref = Database.database().reference()
        self.registerForFireBaseUpdates()

        //let model = RockModel()
        
        //.rocks = model.items
        
        self.myRocksTableView.delegate = self
        self.myRocksTableView.dataSource = self
        
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rocks = self.rocks {
            return rocks.count
        } else {
            return 0
        }
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
                    
                
                    
                    if (user == Auth.auth().currentUser?.uid) {
                        tmpItems.append(Rock(name: name!, id: id!, points: points!, description: description!, user: user!, lat: lat!, lng: lng!, dropped: dropped))
                    }
                    
                    //tmpItems.append(Rock(name: name!, description: description!, user: user!, lat: lat!, lng: lng!))
                }
                self.rocks = tmpItems
                self.myRocksTableView.reloadData()
            } else {
                /*
                let mylabel = UILabel()
                mylabel.text = "No more rocks near you :("
                self.myRocksTableView.addSubview(mylabel)
                */
            }
        })
        
    }
    func toDictionary(vals: Rock) -> NSDictionary {
        print(vals.dropped)
        return [
            "name": NSString(string: vals.name!),
            "points" : NSNumber(value: vals.points!),
            "description" : NSString(string: vals.description!),
            "id" : NSString(string: vals.id!),
            "user" : NSString(string: vals.user!),
            "lat" : NSNumber(value: vals.lat!),
            "lng" : NSNumber(value: vals.lng!),
            "dropped" : NSNumber(value: vals.dropped)
        ]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.myRocksTableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        if let rock = self.rocks?[indexPath.row] {
            
            let distance = rock.getLocation().distance(from: loc.location!)
            
            var temp : String?
            var conditions : String?
            cell.detailTextLabel?.text = ""
        
            wAPI.getWeatherForDate(date: Date(), forLocation: (rock.getLocation().coordinate.latitude, rock.getLocation().coordinate.longitude)) { (weather) in
                if let w = weather {
                    DispatchQueue.main.async {
                        temp = "\(w.temperature)"
                        conditions = "\(w.summary)"//.roundTo(places:2)) F"
                        // TODO: Bind the weather object attributes to the view here
                        cell.detailTextLabel?.numberOfLines = 3
                        cell.textLabel?.text = rock.name! + " - \(rock.points!) points"
                        let status = (rock.isDropped()) ? "Dropped" : "Not dropped"
                        
                        if (rock.isDropped()) {
                            
                            cell.detailTextLabel?.text = "\(status) - Distance: \(floor(distance)) m away\nTemperature: \(temp!) F\nConditions: \(conditions!)"
                        } else {
                            
                            cell.detailTextLabel?.text = "\(status)"
                        }
                        
                        //cell.detailTextLabel?.text = "\(status)"
                    }
                }
            }
            
            let status = (rock.isDropped()) ? "Dropped" : "Not dropped"
            cell.detailTextLabel?.numberOfLines = 3
            cell.textLabel?.text = rock.name! + " - \(rock.points!) points"
            //cell.detailTextLabel?.text = ""
            
            if (rock.isDropped()) {
                
                cell.detailTextLabel?.text = "\(status) - Distance: \(floor(distance)) m away\nTemperature:  F\nConditions: "
            } else {
                
                cell.detailTextLabel?.text = "\(status)"
            }
            
            cell.imageView?.image = #imageLiteral(resourceName: "rock")
            //cell.detailTextLabel?.text = ""
            /*
            cell.detailTextLabel?.numberOfLines = 3
            
            cell.textLabel?.text = rock.name
            let status = (rock.isDropped()) ? "dropped" : "not dropped"
            cell.detailTextLabel?.text = "Points: \(rock.points!) - Status: \(status) - Distance: \(floor(distance)) m away" + "\n" + "test"
            */
            //cell.detailTextLabel?.text = rock.location
            //if let defaultImage = UIImage(named: "logo") {
            //    cell.imageView?.image = defaultImage
            //}
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rock = self.rocks![indexPath.row]
        
        var dialogMessage : UIAlertController
        
        print(rock.name!)
        print(rock.dropped)
        
        var dropping = false
        
        if (rock.isDropped()) {
            
            let distance = rock.getLocation().distance(from: loc.location!)
            
            if (distance > 1000) {
                dialogMessage = UIAlertController(title: "Too far", message: "This rock is too far away!", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    return
                })
                dialogMessage.addAction(ok)
                self.present(dialogMessage, animated: true, completion: nil)
                return
            }
            
            
            
            dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to pick up this rock?", preferredStyle: .alert)
        } else {
            dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to drop this rock?", preferredStyle: .alert)
            dropping = true
        }
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
            
            let id = self.rocks![indexPath.row].id
            
            if (dropping) {
                let location = loc.location!
                self.ref?.child("/rocks/" + id!).updateChildValues(["dropped" : true, "lat" : location.coordinate.latitude, "lng" : location.coordinate.longitude])
                
            } else {
                self.ref?.child("/rocks/" + id!).updateChildValues(["dropped" : false])
            }

            //self.deleteRecord()
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
        
        
        
    }
}

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */




