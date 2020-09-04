//
//  PopVc.swift
//  Pixel City
//
//  Created by Mohamed on 6/13/20.
//  Copyright © 2020 Mohamed. All rights reserved.
//

import UIKit

class PopVc: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var imgview: UIImageView!
    
    var passedimage: UIImage?
    
    func initdata(image: UIImage) {
        
        passedimage = image
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imgview.image = passedimage
        adddoubletab()
        
        
    }
    
    func adddoubletab() {
        
        let doubtap = UITapGestureRecognizer(target: self, action: #selector(tap))
        doubtap.numberOfTapsRequired = 2
        doubtap.delegate = self
        view.addGestureRecognizer(doubtap)
    }
    
    @objc func tap() {
        
        self.dismiss(animated: true, completion: nil)
    }
    

    

}
