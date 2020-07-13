//  Boardwalk
//
//  Created by Dominique Michael Abejar on 17/03/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

extension UIViewController : NVActivityIndicatorViewable{
    
    class func displaySpinner(onView : UIView) -> UIView {
        
        let spinnerView = UIView.init(frame: onView.bounds)
        
        spinnerView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let ai = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50.0, height: 50.0), type: NVActivityIndicatorType.circleStrokeSpin, color: UIColor(red: 232, green: 171, blue: 9, alpha: 1))
        
        ai.startAnimating()
        ai.center = spinnerView.center
            
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner : UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
    
    //Add loading for image
   
}
