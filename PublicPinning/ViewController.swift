//
//  ViewController.swift
//  PublicPinning
//
//  Created by Saurabh Mishra on 24/06/20.
//  Copyright © 2020 Saurabh Mishra. All rights reserved.
//

import UIKit
import TrustKit
import Alamofire


 let sharedManager: SessionManager = {
    
    let serverTrustPolicies:[String:ServerTrustPolicy] = [
        "statefarmstg.sureify.com": .pinPublicKeys(publicKeys: ServerTrustPolicy.publicKeys(), validateCertificateChain: true, validateHost: true)
    ]
    
    
    let manager = Alamofire.SessionManager(
     serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
    )
            return manager
}()





class ViewController: UIViewController,URLSessionDelegate {
    
    //var sessionManager = SessionManager()
    
    lazy var session: URLSession = {
        URLSession(configuration: URLSessionConfiguration.ephemeral,
                                         delegate: self,
                                         delegateQueue: OperationQueue.main)
    }()
    
    //let baseURLYahoo = "https://statefarmstg.sureify.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testWithAlmofirePublicPin()
        
        //testPublicKeyPinning(url: URL(string: baseURLYahoo)!)
    }

   
    
    
    // MARK: TrustKit Pinning Reference
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Call into TrustKit here to do pinning validation
        if TrustKit.sharedInstance().pinningValidator.handle(challenge, completionHandler: completionHandler) == false {
            // TrustKit did not handle this challenge: perhaps it was not for server trust
            // or the domain was not pinned. Fall back to the default behavior
            completionHandler(.performDefaultHandling, nil)
        }
    }

    
    // MARK: Test Control
    
    func testPublicKeyPinningWithTrustKit(url: URL) {
        
        // Load a URL with a good pinning configuration
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            guard error == nil else {
                // Display Error Alert
                self?.displayAlert(withTitle: "Test Result",
                                   message: "Pinning validation failed for \(url.absoluteString)\n\n\(error.debugDescription)")
                return
            }
            
            // Display Success Alert
            self?.displayAlert(withTitle: "Test Result",
                               message: "Pinning validation succeeded for \(url.absoluteString)")
        }
        
        task.resume()
    }
    
    
    func displayAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
    func testWithAlmofirePublicPin(){
        
        sharedManager.request("https://statefarmstg.sureify.com")
            .response{
                res in
                
                if res.response != nil{
                    self.displayAlert(withTitle: "Test Result",
                                       message: "Pinning validation succeeded")
                }else{
                    self.displayAlert(withTitle: "Test Result",
                    message: "Pinning validation Failed")
                }
                
                
        }
    }
    
    /*func testWithAlmofire(){
        
        let serverTrustPolicies:[String:ServerTrustPolicy] = [
            "statefarmstg.sureify.com": .pinPublicKeys(publicKeys: ServerTrustPolicy.publicKeys(), validateCertificateChain: true, validateHost: true)
        ]
        
        
        sessionManager = SessionManager(
         serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    sessionManager.request("https://statefarmstg.sureify.com").response{ res in
            if res.response != nil{
                self.displayAlert(withTitle: "Test Result",
                                   message: "Pinning validation succeeded")
            }else{
                self.displayAlert(withTitle: "Test Result",
                message: "Pinning validation Failed")
            }
            
        }
    }*/
}

