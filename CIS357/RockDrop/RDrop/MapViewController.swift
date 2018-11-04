//
//  MapViewController.swift
//  RDrop
//
//  Created by Admin on 11/27/17.
//  Copyright © 2017 baileyth. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseDatabase
//import MapKit
import FirebaseAuth

class MapViewController: GradientViewController {
    
    var tappedRock : Rock? = nil
    var locationManager : CLLocationManager!
    var currentLocation : CLLocation?
    var markers:[GMSMarker] = []
    
    
    fileprivate var ref : DatabaseReference?
    
    var rocks:[Rock]?
    
    override func viewDidLoad() {
        
        currentLocation = loc.location
        
        self.ref = Database.database().reference()
        self.registerForFireBaseUpdates()
        
        
        
        navigationItem.title = "Rock Map"
        
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.868,
                                             longitude: 151.2086,
                                             zoom: 14)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        //mapView.mapStyle = GMSMapStyle.
        let kMapStyle = "[" +
        "  {" +
        "    \"featureType\": \"poi.business\"," +
        "    \"elementType\": \"all\"," +
        "    \"stylers\": [" +
        "      {" +
        "        \"visibility\": \"off\"" +
        "      }" +
        "    ]" +
        "  }," +
        "  {" +
        "    \"featureType\": \"transit\"," +
        "    \"elementType\": \"labels.icon\"," +
        "    \"stylers\": [" +
        "      {" +
        "        \"visibility\": \"off\"" +
        "      }" +
        "    ]" +
        "  }" +
        "]"
        do {
            // Set the map style by passing a valid JSON string.
            mapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        
        let marker = GMSMarker()
        
        marker.position = camera.target
        marker.snippet = "hello world"
        //marker.appearAnimation = kGMS
        marker.map = mapView
        
        view = mapView
        
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
                    let dropped = entry["dropped"] as! Bool?
                    let user = entry["user"] as! String?
                    let lat = entry["lat"] as! Double?
                    let lng = entry["lng"] as! Double?
                    let id = entry["id"] as! String?
                    
                    let rock = Rock(name: name!, id: id!, points: points!, description: description!, user: user!, lat: lat!, lng: lng!, dropped: dropped!)
                    
                    //let distance = rock.getLocation().distance(from: loc.location!)
                    
                    if (/*user != Auth.auth().currentUser?.uid && dropped! && */(dropped!)) {
                        tmpItems.append(rock)
                    }
                    //tmpItems.append(Rock(name: name!, description: description!, user: user!, lat: lat!, lng: lng!))
                }
                self.rocks = tmpItems
                self.loadMarkersToMap()
                //self.view.reloa
                //self.endLabel?.isHidden = false
            } else {
                print("error getting data")
            }
        })
        
    }
    
    func loadMarkersToMap() {
        if let mapView = self.view as? GMSMapView {
            mapView.clear()
            self.markers.removeAll()
            if let rocks = self.rocks {
                for rock in rocks {
                    let distance = rock.getLocation().distance(from: loc.location!)
                    let marker = GMSMarker()
                    marker.position = rock.getLocation().coordinate
                    marker.title = rock.name
                    marker.snippet = rock.description! + " - \(floor(distance)) meters"
                    marker.userData = rock
                    marker.map = mapView
                    
                    marker.icon = #imageLiteral(resourceName: "biggerrock")
                    /*
                    if (rock.user == Auth.auth().currentUser?.uid) {
                        marker.icon = GMSMarker.markerImage(with: .green)
                    } else {
                        marker.icon = GMSMarker.markerImage(with: .gray)
                    }
                    */
                    markers.append(marker)
                }
                self.focusMapToShowMarkers(markers: markers)
            }
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.getCurrentLocation()
        registerForFireBaseUpdates()
        if let mapView = self.view as? GMSMapView {
            mapView.clear()
            /*
            self.markers.removeAll()
            if let rocks = self.rocks {
                for rock in rocks {
                    let marker = GMSMarker()
                    marker.position = rock.getLocation().coordinate
                    marker.title = rock.name
                    marker.snippet = "Hey"
                    marker.userData = rock
                    marker.map = mapView
                    markers.append(marker)
                }
            }
            
            self.focusMapToShowMarkers(markers: markers)
            */
            self.loadMarkersToMap()
        }
    }
    
    func focusMapToShowMarkers(markers: [GMSMarker]) {
    
        if let mapView = self.view as? GMSMapView {
            var bounds : GMSCoordinateBounds!
            if let current = self.currentLocation {
                bounds = GMSCoordinateBounds(coordinate: current.coordinate, coordinate: current.coordinate)
            } else {
                bounds = GMSCoordinateBounds ()
            }
            mapView.animate(with:GMSCameraUpdate.fit(bounds, withPadding: 15.0))
            
            
        }
        
    }





}

extension MapViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let data = marker.userData as? Rock {
            self.tappedRock = data
            //self.performSegue(withIdentifier: "showRockSegue", sender: self)
        } else {
            self.tappedRock = nil
        }
    }
}
    /*


    @IBOutlet weak var mymapview: GMSMapView!
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 3.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        
        mymapview = mapView
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
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

}
/*

*/*/
