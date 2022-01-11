//
//  APIHelper.swift
//
//

import Foundation
import SystemConfiguration

class APIHelper {
    
    static let shared = APIHelper()

    
    // Returns string of the URL request with the user data in the header field for auth.
    ///
    /// - Parameters:
    ///   - url: The URL to request
    ///   - completionBlock: A completion block if it is successful with DATA 
    public func fetchDataFromAPI(url: String, completionBlock: @escaping (Data) -> Void) -> Void {
        if (self.isNetworkAvailable()) {
            guard let urlObject = URL(string: url) else {
                return
            }
            var request = URLRequest(url: urlObject)
            request.timeoutInterval = 30
            let vn = app.currentVersion
            request.setValue(server.accessKey, forHTTPHeaderField: "X-accessKey")
            request.setValue(vn, forHTTPHeaderField: "X-version")
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    if (error != nil) {
                        print(error as Any)
                    } else {
                        completionBlock(data)
                    }
                }
                }.resume()
        } else {
            print("Network down")
        }
    }
    
    
    private func isNetworkAvailable()->Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}

