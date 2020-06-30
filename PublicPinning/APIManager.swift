//
//  APIManager.swift
//  PublicPinning
//
//  Created by Saurabh Mishra on 30/06/20.
//  Copyright © 2020 Saurabh Mishra. All rights reserved.
//

import Foundation

import Alamofire


class APIManager{
    
     static  let sharedManager: SessionManager = {
          let serverTrustPolicies:[String:ServerTrustPolicy] = [
              "statefarmstg.sureify.com": .pinPublicKeys(publicKeys: ServerTrustPolicy.publicKeys(), validateCertificateChain: true, validateHost: true)
          ]
          
          // manager without delegate
          let manager = Alamofire.SessionManager(
           serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
          )
          
          

          return manager
    }()
}

