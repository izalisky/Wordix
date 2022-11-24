//
//  AuthViewController.swift
//  Wordix
//
//  Created by Ihor Zaliskyj on 04.02.2021.
//  Copyright © 2021 Igor Zalisky. All rights reserved.
//

import UIKit
import AuthenticationServices
import CryptoKit
import RealmSwift
import Firebase


class AuthViewController: UIViewController {
    
    @IBOutlet weak var signInBtn : UIButton!
    @IBOutlet weak var label1 : UILabel!
    @IBOutlet weak var label2 : UILabel!
    fileprivate var currentNonce: String?
    var viewModel  : AuthViewModelType?
    
    //@IBOutlet weak var indicator : UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = AuthViewModel()
        self.view.addGradient(colors: Constants.gradientColors1)
        self.signInBtn.setTitle(NSLocalizedString(" Sign in with Apple", comment: ""), for: .normal)
        self.label1.text = NSLocalizedString("It is very important to save your brain trainings progress", comment: "")
        self.label2.text = NSLocalizedString("Just sign in to the app using safest way without passwords", comment: "")
        self.setUpSignInAppleButton()
    }
    
    func setUpSignInAppleButton() {
        if #available(iOS 13.0, *) {
            signInBtn?.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func handleAppleIdRequest() {
        if #available(iOS 13.0, *) {
            
            let nonce = randomNonceString()
              currentNonce = nonce
              let appleIDProvider = ASAuthorizationAppleIDProvider()
              let request = appleIDProvider.createRequest()
              request.requestedScopes = [.fullName, .email]
              request.nonce = sha256(nonce)
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
        }
    }
    

    
    @IBAction func signInAction(){
        let controller = UIStoryboard(name: "Subscription", bundle: .main).instantiateViewController(identifier: "subscription") as? SubscriptionViewController
        self.navigationController?.pushViewController(controller!, animated: true)
    }

}

extension AuthViewController : ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email
                print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))")
                
                let name = ((fullName?.givenName ?? "") + " " + (fullName?.familyName ?? ""))
                if fullName != nil && name != " " {
                    var user = [String:String]()
                    user["name"] = name
                    user["email"] = appleIDCredential.email
                    SettingsManager.saveAppleUser(forUserID: userIdentifier, user: user)
                }
                let user = SettingsManager.appleUser(userID: userIdentifier)
                
                var params = [String:AnyObject]()
                params["name"] = user["name"] as AnyObject
                params["user_id"] = userIdentifier as AnyObject
                params["email"] = user["email"] as AnyObject
                
                if user["name"] == " " || user["name"] == nil {
                    params["name"] = "Test User" as AnyObject
                    params["email"] = "test@user.com" as AnyObject
                }
                
                guard let nonce = currentNonce else {
                  fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                  print("Unable to fetch identity token")
                  return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                  print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                  return
                }
                
                if Auth.auth().currentUser != nil {
                    self.reauth(idTokenString: idTokenString, nonce: nonce)
                } else {
                    self.auth(idTokenString: idTokenString, nonce: nonce)
                }
                
                //self.runAuthRequest(params:params)
            }
    }

    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error.localizedDescription)")
    }
    
    
    func runAuthRequest(params:[String:AnyObject]){
        self.signInAction()
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    
    func auth(idTokenString:String, nonce:String){
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        // Sign in with Firebase.
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if (error != nil) {
                print(error?.localizedDescription)
            return
          }
            
            self.addUserToDatabaseIfNeed()
        }
    }
    
    func reauth(idTokenString:String, nonce:String){
        let credential = OAuthProvider.credential(
          withProviderID: "apple.com",
            idToken: idTokenString,
          rawNonce: nonce
        )
        // Reauthenticate current Apple user with fresh Apple credential.
        Auth.auth().currentUser?.reauthenticate(with: credential) { (authResult, error) in
            if (error != nil) {
                print(error?.localizedDescription)
            return
          }
            self.addUserToDatabaseIfNeed()
        }
    }
    
    func logout(){
        let firebaseAuth = Auth.auth()
     do {
       try firebaseAuth.signOut()
     } catch let signOutError as NSError {
       print ("Error signing out: %@", signOutError)
     }
    }
    
    func addUserToDatabaseIfNeed(){
        if let user = Auth.auth().currentUser {
            let rootRef = Database.database().reference()
            let userRef = rootRef.child("users").child(user.uid)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
               
                print(snapshot.children)
                if snapshot.exists() == false {
                    userRef.setValue(["email":user.email,"uid":user.uid])
                }
                UserDefaults.standard.setValue(true, forKey: "APP_DID_LOADED")
                UserDefaults.standard.synchronize()
                
                self.viewModel?.loadUserInfo()
                self.viewModel?.userInfoDidLoad = {
                    self.signInAction()
                }
            })
        }
    }
}



