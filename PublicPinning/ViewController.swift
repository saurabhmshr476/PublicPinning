//
//  ViewController.swift
//  PublicPinning
//
//  Created by Saurabh Mishra on 24/06/20.
//  Copyright © 2020 Saurabh Mishra. All rights reserved.
//

import UIKit
import TrustKit

class ViewController: UIViewController,URLSessionDelegate {
    
    lazy var session: URLSession = {
        URLSession(configuration: URLSessionConfiguration.ephemeral,
                                         delegate: self,
                                         delegateQueue: OperationQueue.main)
    }()
    let baseURLYahoo = "https://www.yahoo.com/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testPublicKeyPinning(url: URL(string: baseURLYahoo)!)
        // Do any additional setup after loading the view.
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
    
    func testPublicKeyPinning(url: URL) {
        // Show loading view
        
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
}

