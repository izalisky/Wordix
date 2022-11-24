//
//  File.swift
//  Wordix
//
//  Created by Ігор on 10/28/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    @IBAction func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func alertWithTitle(title:String){
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
        }

       /* let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            print("You've pressed cancel");
        }

        let action3 = UIAlertAction(title: "Destructive", style: .destructive) { (action:UIAlertAction) in
            print("You've pressed the destructive");
        }

        alertController.addAction(action1)
        alertController.addAction(action2)*/
        alertController.addAction(action1)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension UIImage {
    func withColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let ctx = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return self }
        color.setFill()
        ctx.translateBy(x: 0, y: size.height)
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.clip(to: CGRect(x: 0, y: 0, width: size.width, height: size.height), mask: cgImage)
        ctx.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let colored = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        return colored
    }
}

extension Array where Element: Hashable {

    func after(item: Element) -> Element? {
        if let index = self.firstIndex(of: item), index + 1 < self.count {
            return self[index + 1]
        }
        return nil
    }
    
    func before(item: Element) -> Element? {
        if let index = self.firstIndex(of: item), index - 1 >= 0 {
            return self[index - 1]
        }
        return nil
    }
}

extension String{
    var encodeUrl : String
    {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
    var decodeUrl : String
    {
        return self.removingPercentEncoding!
    }
}

extension Date{
    func string()->String{
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy"
        return df.string(from: self)
    }
}

extension UIImage {
  func resizeImage(targetSize: CGSize) -> UIImage {
    let size = self.size
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
  }
}


extension UIView {
    func addGradient(colors:[CGColor]){
        if let view = self.viewWithTag(321) as? UIImageView {
        let layer0 = CAGradientLayer()
        layer0.colors = colors

        if colors.count == 3 {
        layer0.locations = [0, 0.49, 1]
        } else {
           layer0.locations =  [0, 1]
        }
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
        layer0.frame = self.bounds
        view.layer.addSublayer(layer0)
        }
    }
    
    func addTransparentGradient(colors:[CGColor]){
        let layer0 = CAGradientLayer()
        layer0.colors = colors
        layer0.locations =  [0, 1]
        layer0.startPoint = CGPoint(x: 0.0, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.85, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
        layer0.frame = self.bounds
        self.layer.addSublayer(layer0)
    }
}

extension Array
{
    func random() -> Element {
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {

        let pixelData = self.cgImage!.dataProvider!.data
              let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

              let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

              let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
              let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
              let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
              let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

              return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func cropImage(rect:CGRect) -> UIImage{
        let imageRef:CGImage = self.cgImage!.cropping(to: rect)!
        let cropped:UIImage = UIImage(cgImage:imageRef)
        return cropped
    }
    
  }

extension UIView {
    func toImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
