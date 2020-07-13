//
//  UIImageExtension.swift
//  Share
//
//  Created by Dominique Michael Abejar on 31/03/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{
    
    func setRound(){
        self.layer.cornerRadius = self.bounds.width/2
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 2
        self.clipsToBounds = true
    }
    
    func downloaded(from url: URL){
        
        let imageUrlString = url
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = data {
                DispatchQueue.main.async {
                    let imageToCache = UIImage(data: data!)
                    
                    if imageUrlString == url{
                        self.image = imageToCache
                    }
                    print(url)
                    imageCache.setObject(imageToCache!, forKey: url as AnyObject)
                }
            }
        }.resume()
    }
    
    func downloadedLink(from link: String){
        guard let url = URL(string: link) else { return }
        downloaded(from: url)
    }
    
    
}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}


