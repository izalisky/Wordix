//
//  ImageCacherManager.swift
//  Wordix
//
//  Created by Ігор on 11/11/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

class ImageCacher: NSObject {
    var urls:[String]?{
        didSet{
            for url in self.urls! {
                self.cachingImage(url: url)
            }
        }
    }
    
    func cachingImage(url:String){
        let iv = UIImageView()
        iv.af.setImage(withURL: URL(string: url)!, cacheKey: url, placeholderImage: UIImage())
        print("caching image: \(url)")
    }

}
