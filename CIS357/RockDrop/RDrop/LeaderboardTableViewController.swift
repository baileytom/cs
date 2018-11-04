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

class LeaderboardTableViewController: GradientTableViewController {
    
    @IBOutlet weak var leaderboardView: UITableView!
    
    fileprivate var ref : DatabaseReference?
    
    var rocks : [Rock]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = THEME_COLOR2
        
        
        self.ref = Database.database().reference()
        self.registerForFireBaseUpdates()
        
        //let model = RockModel()
        
        //.rocks = model.items
        
        self.leaderboardView.delegate = self
        self.leaderboardView.dataSource = self
        
        
        
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
                    
                    
                    
                    if (true) {
                        tmpItems.append(Rock(name: name!, id: id!, points: points!, description: description!, user: user!, lat: lat!, lng: lng!, dropped: dropped))
                    }
                    
                    //tmpItems.append(Rock(name: name!, description: description!, user: user!, lat: lat!, lng: lng!))
                }
                self.rocks = tmpItems.sorted() {$0.points! > $1.points!}
                self.leaderboardView.reloadData()
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
        let cell = self.leaderboardView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        let sortedrocks = self.rocks?.sorted() {$0.points! > $1.points!};
        if let rock = sortedrocks?[indexPath.row] {
            
            //let distance = rock.getLocation().distance(from: loc.location!)
            
            
            
            cell.textLabel?.text = rock.name! + " - \(rock.points!) points"
            cell.detailTextLabel?.text = ""
            cell.imageView?.image = #imageLiteral(resourceName: "rock")
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let rock = self.rocks![indexPath.row]
        
        var dialogMessage : UIAlertController
        
        dialogMessage = UIAlertController(title: rock.name, message: rock.description, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            return
        })
        dialogMessage.addAction(ok)

        
        
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




