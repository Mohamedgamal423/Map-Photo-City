//
//  MapVC.swift
//  Pixel City
//
//  Created by Mohamed on 5/23/20.
//  Copyright © 2020 Mohamed. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage


class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var pullupviewheightconstraint: NSLayoutConstraint!
    @IBOutlet weak var pullupview: UIView!
    var locationmanager = CLLocationManager()
    var status = CLLocationManager.authorizationStatus()
    @IBOutlet weak var mapVC: MKMapView!
    var spinner: UIActivityIndicatorView?
    var progresslbl: UILabel?
    var ImagesurlArray = [String]()
    var Imagesarray = [UIImage]()
    
    var Collectionview: UICollectionView?
    var Flowlayout = UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapVC.delegate = self
        locationmanager.delegate = self
        enablelocationservices()
        addDoubleTap()
        Collectionview = UICollectionView(frame: view.bounds, collectionViewLayout: Flowlayout)
        Collectionview?.register(PhotoCell.self, forCellWithReuseIdentifier: "photocell")
        Collectionview?.delegate = self
        Collectionview?.dataSource = self
        Collectionview?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pullupview.addSubview(Collectionview!)
        
        
        
    }

    @IBAction func centerBtnbressed(_ sender: Any) {
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            
            centermaponuser()
            
        }
        
                
        
    }
    func addDoubleTap() {
        let doubletap = UITapGestureRecognizer(target: self, action: #selector(addtap(sender:)))
        doubletap.numberOfTapsRequired = 2
        doubletap.delegate = self
        mapVC.addGestureRecognizer(doubletap)
        
        
    }
    
    func addswipe() {
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animatedown))
        swipe.direction = .down
        pullupview.addGestureRecognizer(swipe)
    }
    
    func animateviewup() {
        pullupviewheightconstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
   @objc func animatedown() {
        cancelallsessions()
        pullupviewheightconstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    func addspinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (view.frame.size.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.style = .large
        spinner?.startAnimating()
        pullupview.addSubview(spinner!)
    }
    func removespinner() {
        if spinner != nil   {
            spinner?.removeFromSuperview()
        }
}
    func addproglbl() {
        progresslbl = UILabel()
        progresslbl?.frame = CGRect(x: (pullupview.frame.size.width / 2) - 120, y: 175, width: 240, height: 40)
        progresslbl?.font = UIFont(name: "Avenir Next", size: 14)
        progresslbl?.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        progresslbl?.textAlignment = .center
        pullupview.addSubview(progresslbl!)
    }
    func removeproglbl() {
        
        if progresslbl != nil {
            progresslbl?.removeFromSuperview()
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    
    func centermaponuser() {
        guard let coordinate = locationmanager.location?.coordinate  else {return}
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapVC.setRegion(region, animated: true)
    }
    @objc func addtap(sender: UITapGestureRecognizer) {
       removepin()
       removespinner()
       removeproglbl()
       cancelallsessions()
       ImagesurlArray = []
       Imagesarray = []
       
       Collectionview?.reloadData()
        
       animateviewup()
       addswipe()
       addspinner()
       addproglbl()
       let touch = sender.location(in: mapVC)
       let tappedcoordinate = mapVC.convert(touch, toCoordinateFrom: mapVC)
       let pinannotation = Dropablepin(coordinate: tappedcoordinate, identifier: "droppin")
       mapVC.addAnnotation(pinannotation)
       let region = MKCoordinateRegion(center: tappedcoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
       mapVC.setRegion(region, animated: true)
       retrieveurls(withannotation: pinannotation) { (completed) in
        if completed {
            
            self.retrieveimages { (finished) in
                if finished {
                    self.removeproglbl()
                    self.removespinner()
                    self.Collectionview?.reloadData()
                    
                }
                
            }
        }
        
        }
        
    }
    func removepin() {
        for annot in mapVC.annotations {
            mapVC.removeAnnotation(annot)
        }
    }
    
}

extension MapVC: CLLocationManagerDelegate {
    
    func enablelocationservices() {
        if (status == .notDetermined) {
            
            locationmanager.requestAlwaysAuthorization()
        }
        else {
            return
        }
           
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centermaponuser()
    }
    
    func retrieveurls(withannotation annotation: Dropablepin, handler: @escaping (_ status: Bool) -> ()) {
        ImagesurlArray = []
        
        AF.request(flickrurl(withkey: apikey, withannotation: annotation, numperofphotos: 40)).responseJSON { (response) in
            
            guard let json = response.value as? Dictionary<String, AnyObject> else { return }
            let photosdictionary = json["photos"] as! Dictionary<String, AnyObject>
            let photodictarray = photosdictionary["photo"] as! [Dictionary<String, AnyObject>]
            
            
            for photoarr in photodictarray {
                
                let imgurl = "https://live.staticflickr.com/\(photoarr["server"]!)/\(photoarr["id"]!)_\(photoarr["secret"]!)_c_d.jpg"
                self.ImagesurlArray.append(imgurl)
            }
            handler(true)
        }
        
    }
    
    func retrieveimages(handler: @escaping (_ status: Bool) -> ()) {
        
        for imagearr in ImagesurlArray {
            AF.request(imagearr).responseImage { (response) in
                
                guard let image = response.value else { return }
                self.Imagesarray.append(image)
                self.progresslbl?.text = "\(self.Imagesarray.count)/40 IMAGES DOWNLOADED"
                if self.Imagesarray.count == self.ImagesurlArray.count {
                    
                    handler(true)
                }
                
            }
        }
    }
    
    func cancelallsessions() {
        
        Alamofire.Session.default.session.getTasksWithCompletionHandler{ (sessiondatatask, sessionuploadtask,sessiondownloadtask) in
            
            for session in sessiondatatask {
                session.cancel()
            }
            for session in sessiondownloadtask {
                session.cancel()
            }
        }
    }
    
}

extension MapVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Imagesarray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let photocell = collectionView.dequeueReusableCell(withReuseIdentifier: "photocell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        let imageview = UIImageView(image: Imagesarray[indexPath.row])
        photocell.addSubview(imageview)
        return photocell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let popvc = storyboard?.instantiateViewController(identifier: "popvc") as? PopVc else {return}
        popvc.initdata(image: Imagesarray[indexPath.row])
        present(popvc, animated: true, completion: nil)
    }
    
    
    
    
}

