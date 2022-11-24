//
//  AppDelegate.swift
//  Wordix
//
//  Created by Ігор on 10/24/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
///

import UIKit
import RealmSwift
import ApphudSDK
import Darwin
import AVFoundation
import FBSDKCoreKit
import Firebase
import AdSupport
import AppTrackingTransparency
import AppsFlyerLib

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var realm : Realm?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //
        if #available(iOS 14, *) {
          ATTrackingManager.requestTrackingAuthorization { (status) in }
        }
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        self.configureAVAudioSession()
        self.configureRealm()
        FirebaseApp.configure()
        Apphud.start(apiKey: APPHUD_API_KEY)
        self.check()
        AppEvents.logEvent(AppEvents.Name(rawValue: "Wordix started."))
        // Appsflyer
        initAppsflyer(application: application)
        return false
    }
    
    
    func configureAVAudioSession(){
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        }
        catch let error as NSError {
            print("Error: Could not set audio category: \(error), \(error.userInfo)")
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError {
            print("Error: Could not setActive to true: \(error), \(error.userInfo)")
        }
    }
    
    func check(){
        UserDefaults.standard.setValue(false, forKey: "K_CONTENT_DID_LOADED")
        UserDefaults.standard.synchronize()
        let needShowOnboarding = UserDefaults.standard.bool(forKey: "APP_DID_LOADED") == false
        self.checkInternet { (internet) in
            if internet || !needShowOnboarding{
                self.showGameplay(needShowOnboarding: needShowOnboarding)
            } else {
                    let alertController = UIAlertController(title: NSLocalizedString("No internet connection", comment: "LOC_STR"), message: nil, preferredStyle: .alert)
                    let action1 = UIAlertAction(title: NSLocalizedString("Retry", comment: "LOC_STR"), style: .default) { (action:UIAlertAction) in
                        self.check()
                    }
                    alertController.addAction(action1)
                    self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func showGameplay(needShowOnboarding:Bool){
        let id = needShowOnboarding == true ? "Onboarding" : "Main"
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let nc = UIStoryboard(name: id, bundle: .main).instantiateViewController(identifier: "start") as? UINavigationController
        appdelegate.window?.rootViewController = nc
    }
    
    func checkInternet(_ closure: @escaping (Bool)->()) {
        let url = NSURL(string: "https://www.google.com/")
        let request = URLRequest(url: url! as URL)
        let session = URLSession.shared
        //request.httpMethod = "GET"
        session.dataTask(with: request) { (data, response, error) -> Void in
            DispatchQueue.main.async {
                let rsp = response as! HTTPURLResponse?
                closure(rsp?.statusCode == 200)
            }
        }.resume()
    }
    
    func configureRealm(){
        let configuration = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
            }
        )
        Realm.Configuration.defaultConfiguration = configuration
        realm = try! Realm()
    }

    
    // MARK: - Integrations actions
    private func initAppsflyer(application: UIApplication) {
        AppsFlyerLib.shared().appsFlyerDevKey = "WKWAZ28gbziF4detpwTWjX"
        AppsFlyerLib.shared().appleAppID = "1536743626"
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().isDebug = true
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
    }
}

extension AppDelegate {
    
    func application(_ application: UIApplication, handleOpenURL url: URL) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, sourceApplication: nil, withAnnotation: nil)
        return true
    }
    
    func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
        //_ = YMMYandexMetrica.handleOpen(url)
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
    }
    
    private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: restorationHandler)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }
    
    func application(_ application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppsFlyerLib.shared().handlePushNotification(userInfo)
    }
    
}

extension AppDelegate: AppsFlyerLibDelegate {
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        let installData = conversionInfo
        print("onConversionDataSuccess data:")
        for (key, value) in installData {
            print(key, ":", value)
        }
        if let status = installData["af_status"] as? String {
            if (status == "Non-organic") {
                if let sourceID = installData["media_source"],
                   let campaign = installData["campaign"] {
                    print("This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                }
            } else {
                print("This is an organic install.")
            }
            if let is_first_launch = installData["is_first_launch"] as? Bool,
               is_first_launch {
                print("First Launch")
            } else {
                print("Not First Launch")
            }
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        print(error)
    }
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        //Handle Deep Link Data
        print("onAppOpenAttribution data:")
        for (key, value) in attributionData {
            print(key, ":",value)
        }
    }
    func onAppOpenAttributionFailure(_ error: Error) {
        print(error)
    }
    
}
