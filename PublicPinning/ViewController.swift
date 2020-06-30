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

 





class ViewController: UIViewController,URLSessionDelegate {
    

    //MARK: - Session Manager without  delegate


    let sessionManager: SessionManager = {
        
        
        let serverTrustPolicies:[String:ServerTrustPolicy] = [
            "statefarmstg.sureify.com": .pinPublicKeys(publicKeys: ServerTrustPolicy.publicKeys(), validateCertificateChain: true, validateHost: true)
        ]
        
        // manager without delegate
      
        let manager = Alamofire.SessionManager(
         serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        
        

        return manager
    }()

    //MARK: - Session Manager with custom delegate

     let sessionManagerWithCustomDelegate: SessionManager = {
        
        let serverTrustPolicies:[String:ServerTrustPolicy] = [
            "statefarmstg.sureify.com": .pinPublicKeys(publicKeys: ServerTrustPolicy.publicKeys(), validateCertificateChain: true, validateHost: true)
        ]
     
        
        let manager = Alamofire.SessionManager(
            delegate: PinningSessionDelegate(), // Feeding our own session delegate
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return manager
    }()
    
    
    lazy var session: URLSession = {
        URLSession(configuration: URLSessionConfiguration.ephemeral,
                                         delegate: self,
                                         delegateQueue: OperationQueue.main)
    }()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testWithAlmofirePublicPin()
        
        testWithAlmofirePublicPinUsingCustomDelegate()
        
        
        //testPublicKeyPinning(url: URL(string: baseURLYahoo)!)
    }

   
    
    
    //MARK: - TrustKit Pinning Reference
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Call into TrustKit here to do pinning validation
        if TrustKit.sharedInstance().pinningValidator.handle(challenge, completionHandler: completionHandler) == false {
            // TrustKit did not handle this challenge: perhaps it was not for server trust
            // or the domain was not pinned. Fall back to the default behavior
            completionHandler(.performDefaultHandling, nil)
        }
    }

    
    
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
    
 //MARK: - Display public pinning Success/Failure
    
    func displayAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
   //MARK: - Alamofire Public pinning without delegate
    
    func testWithAlmofirePublicPin(){

       /*
         let serverTrustPolicies:[String:ServerTrustPolicy] = [
            "statefarmstg.sureify.com": .pinPublicKeys(publicKeys: ServerTrustPolicy.publicKeys(), validateCertificateChain: true, validateHost: true)
        ]
        
        sessionManager = SessionManager(
            delegate: PinningSessionDelegate(), // Feeding our own session delegate
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        */
        
        
        APIManager.sharedManager.request("https://statefarmstg.sureify.com")
            
            .response{[weak self]
                res in
                
                if res.response != nil{
                    self?.displayAlert(withTitle: "Test Result",
                                       message: "Pinning validation succeeded")
                }else{
                    self?.displayAlert(withTitle: "Test Result",
                    message: "Pinning validation Failed")
                }
                
                
        }
    }
    
    //MARK: - Alamofire Public pinning using delegate
    
    func testWithAlmofirePublicPinUsingCustomDelegate(){
        
        APIManager.sharedManager.request("https://statefarmstg.sureify.com")
            .response{[weak self]
                res in
                
                if res.response != nil{
                    self?.displayAlert(withTitle: "Test Result",
                                       message: "Pinning validation succeeded")
                }else{
                    self?.displayAlert(withTitle: "Test Result",
                    message: "Pinning validation Failed")
                }
                
                
        }
    }
    
    
    //MARK: - Alamofire Public pinning configuration within the function
    
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

