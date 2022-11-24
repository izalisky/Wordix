//
//  WordixObject.swift
//  Wordix
//
//  Created by Ihor Zaliskyj on 18.12.2020.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseStorage
import FirebaseUI

class WordixObject: Object {
    @objc dynamic var imageName : String = ""
    
    @objc func chacheImage(){
        if self.isDownloaded() == false {
        self.startDownload()
            let storageRef = Storage.storage().reference()//.reference(withPath: imageUrl())
            let reference = storageRef.child("image").child(self.imageName)
            reference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if error != nil {
              } else {
                if let image = UIImage(data: data!) {
                    self.saveImage(image: image, fileName: self.imageName)
                }
              }
                self.endDownload()
            }
        }
    }
    
    func isDownloaded() -> Bool{
        let sd = UserDefaults.standard.object(forKey: "K_START_DOWNLOADED") as? [String]
        return (sd?.contains(self.imageUrl())) == true
    }
    
    func startDownload(){
        var sd = UserDefaults.standard.object(forKey: "K_START_DOWNLOADED") as? [String]
        if sd == nil {
            sd = [String]()
        }
        if sd?.contains(self.imageUrl()) == false {
            sd?.append(self.imageUrl())
        }
        
        UserDefaults.standard.setValue(sd, forKey: "K_START_DOWNLOADED")
        UserDefaults.standard.synchronize()
        print("START \((sd?.count)!)")
    }
    
    func endDownload(){
        var sd = UserDefaults.standard.object(forKey: "K_END_DOWNLOADED") as? [String]
        if sd == nil {
            sd = [String]()
        }
        if sd?.contains(self.imageUrl()) == false {
            sd?.append(self.imageUrl())
        }
        UserDefaults.standard.setValue(sd, forKey: "K_END_DOWNLOADED")
        UserDefaults.standard.synchronize()
        print("END \((sd?.count)!)")
        
        
        let all = ((UserDefaults.standard.object(forKey: "K_START_DOWNLOADED") as? [String])?.count)!
        let progress  = sd!.count * 100 / all
        
        NotificationCenter.default.post(name: Notification.Name("K_DOWNLOADING_CONTENT_PROGRESS_DID_CHANGE"), object: nil, userInfo: ["progress":progress])
        
    }
    
    public func imageUrl() -> String {
        return (IMAGE_URL + imageName).encodeUrl
    }
    
    func saveImage(image:UIImage,fileName:String){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if let data = image.pngData(),
          !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                print("\(fileName) - file saved")
            } catch {
                print("\(fileName) - error saving file:", error)
            }
        }
    }
    
    func loadImageFromDocumentDirectory(fileName: String) -> UIImage? {

            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
            let fileURL = documentsUrl.appendingPathComponent(fileName)
            do {
                let imageData = try Data(contentsOf: fileURL)
                return UIImage(data: imageData)
            } catch {}
            return nil
    }
    
    var image: UIImage? {
        return self.loadImageFromDocumentDirectory(fileName: self.imageName )
    }

    
}

extension UIImage{
    var grayscaled: UIImage?{
        let ciImage = CIImage(image: self)
        let grayscale = ciImage?.applyingFilter("CIColorControls",
                                                parameters: [ kCIInputSaturationKey: 0.0 ])
        if let gray = grayscale{
            return UIImage(ciImage: gray)
        }
        else{
            return nil
        }
    }
    
    func resize(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
      }
}
