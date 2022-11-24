//
//  SubscriptionViewController.swift
//  Wordix
//
//  Created by Ігор on 10/24/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit
import ApphudSDK
import StoreKit

class SubscriptionViewController: UIViewController {
    
    @IBOutlet weak var subscribeBtn : UIButton!
    @IBOutlet weak var priceLabel : UILabel!
    @IBOutlet weak var indicator : UIActivityIndicatorView!
    var products = [SKProduct]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.priceLabel.text = NSLocalizedString("continue_pro", comment: "")
        self.subscribeBtn.setTitle("", for: .normal)
        self.view.addGradient(colors: Constants.gradientColors1)
        Apphud.setDelegate(self)
        Apphud.setUIDelegate(self)
        
        
        if Apphud.products() == nil || Apphud.products()?.count == 0 {
            self.showIndicator(show: true)
            Apphud.productsDidFetchCallback { (products) in
                self.products = products
                self.reloadUI()
                self.showIndicator(show: false)
            }
        } else {
            self.products = Apphud.products()!
            self.reloadUI()
        }
        
        if Apphud.hasActiveSubscription(){
            print("Has active subscription")
        }
        
    }
    
    func reloadUI() {
        if products.count > 0 {
            let prod = self.products.first
                self.subscribeBtn.setTitle("\((prod?.price)!) \((prod?.priceLocale.currencySymbol)!) " + NSLocalizedString("per week", comment: "LOC_STR"), for: .normal)
        }
        else {
            self.subscribeBtn.setTitle("$2.99 " + NSLocalizedString("per week", comment: "LOC_STR"), for: .normal)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.products.count == 0 {
                self.subscribeBtn.setTitle("$2.99 " + NSLocalizedString("per week", comment: "LOC_STR"), for: .normal)
            }
        }
        
    }
    
    @IBAction func subscribeAction(){
        if products.count > 0 {
            self.purchaseProduct(product: (products.first)!)
        }
    }
    
    @IBAction func openUrl(btn:UIButton){
        var str = ""
        switch btn.tag {
        case 1:
            str = "https://pastebin.com/raw/jszgLH2A"
        case 2:
            str = "https://pastebin.com/raw/drLFXpcv"
        default:
            str = ""
        }
        guard let url = URL(string: str) else { return }
        UIApplication.shared.open(url)
    }

    func purchaseProduct(product : SKProduct) {
        self.showIndicator(show: true)
        Apphud.purchase(product) { result in
            if result.error != nil {
                //self.restore()
                print("Purchase error: \(result.error?.localizedDescription ?? "")")
            } else {
                UserDefaults.standard.setValue(true, forKey: hasActiveSubscriptionKey)
                UserDefaults.standard.synchronize()
                self.didSubscribe(title: NSLocalizedString("Subscribed successfully", comment: "LOC_STR"))
            }
            self.showIndicator(show: false)
        }
    }
    
    func showIndicator(show:Bool){
        self.subscribeBtn.isEnabled = !show
        if show  {
            self.indicator.startAnimating()
        } else {
            self.indicator.stopAnimating()
        }
        //self.view.isUserInteractionEnabled = !show
    }
    
    func didSubscribe(title:String){
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            self.closeAction()
        }
        alertController.addAction(action1)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func restore(){
        Apphud.restorePurchases { _, _, _ in
          if Apphud.hasActiveSubscription() {
            self.didSubscribe(title: NSLocalizedString("Subscription restored", comment: "LOC_STR"))
            UserDefaults.standard.setValue(true, forKey: hasActiveSubscriptionKey)
            UserDefaults.standard.synchronize()
          } else {
              // no active in-app purchases found
          }
      }
    }
    
    @IBAction func closeAction(){
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let nc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "start") as? UINavigationController
        appdelegate.window?.rootViewController = nc
    }
}


extension SubscriptionViewController: ApphudDelegate {

    func apphudDidChangeUserID(_ userID: String) {
        print("new apphud user id: \(userID)")
    }

    func apphudDidFetchStoreKitProducts(_ products: [SKProduct]) {
        print("apphudDidFetchStoreKitProducts")
     //   self.products = products
        self.reloadUI()
    }

    func apphudSubscriptionsUpdated(_ subscriptions: [ApphudSubscription]) {
        self.reloadUI()
        print("apphudSubscriptionsUpdated")
    }

    func apphudNonRenewingPurchasesUpdated(_ purchases: [ApphudNonRenewingPurchase]) {
        self.reloadUI()
        print("non renewing purchases updated")
    }

    func apphudShouldStartAppStoreDirectPurchase(_ product: SKProduct) -> ((ApphudPurchaseResult) -> Void)? {
        let callback: ((ApphudPurchaseResult) -> Void) = { result in
            // handle ApphudPurchaseResult
            self.reloadUI()
        }
        return callback
    }
}

extension SubscriptionViewController: ApphudUIDelegate {

    func apphudShouldPerformRule(rule: ApphudRule) -> Bool {
        return true
    }

    func apphudShouldShowScreen(screenName: String) -> Bool {
        return true
    }

    func apphudScreenPresentationStyle(controller: UIViewController) -> UIModalPresentationStyle {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .pageSheet
        } else {
            return .fullScreen
        }
    }

    func apphudDidDismissScreen(controller: UIViewController) {
        print("did dismiss screen")
    }

    func apphudDidPurchase(product: SKProduct, offerID: String?, screenName: String) {
        print("did purchase \(product.productIdentifier), offer: \(offerID ?? ""), screenName: \(screenName)")
    }

    func apphudDidFailPurchase(product: SKProduct, offerID: String?, errorCode: SKError.Code, screenName: String) {
        print("did fail purchase \(product.productIdentifier), offer: \(offerID ?? ""), screenName: \(screenName), errorCode:\(errorCode.rawValue)")
    }

    func apphudWillPurchase(product: SKProduct, offerID: String?, screenName: String) {
        print("will purchase \(product.productIdentifier), offer: \(offerID ?? ""), screenName: \(screenName)")
    }
}
