//
//  AppMetrics.swift
//  My Storm
//
//  Created by Adam Ware on 10/7/2022.
//

import Foundation
import MetricKit
import os.log
/// A concrete implementation of `MXMetricManagerSubscriber` that listens for and processes daily app metrics.
class AppMetricManager: NSObject, MXMetricManagerSubscriber {
    
    // MARK: - Dependencies
    
    let metricManager: MXMetricManager
    
    // MARK: - Init/Deinit
     
    init(metricManager: MXMetricManager = MXMetricManager.shared) {
        self.metricManager = metricManager
        
        super.init()
         
        // subscribe to receive metrics
        metricManager.add(self)
    }
     
    deinit {
        metricManager.remove(self)
    }
    
    // MARK: - MXMetricManagerSubscriber
     
    // called at most once every 24hrs with daily app metrics
    func didReceive(_ payloads: [MXMetricPayload]) {
        os_log("Received Daily MXMetricPayload:", type: .debug)
        for metricPayload in payloads {
            if let metricPayloadJsonString = String(data: metricPayload.jsonRepresentation(), encoding: .utf8) {
                os_log("%@", type: .debug, metricPayloadJsonString)
 
                // Here you could upload these metrics (in JSON form) to your servers to aggregate app performance metrics
            }
        }
    }
     
    // called at most once every 24hrs with daily app diagnostics
    @available(iOS 14.0, *)
    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        os_log("Received Daily MXDiagnosticPayload:", type: .debug)
        for diagnosticPayload in payloads {
            if let diagnosticPayloadJsonString = String(data: diagnosticPayload.jsonRepresentation(), encoding: .utf8) {
                os_log("%@", type: .debug, diagnosticPayloadJsonString)
 
                // Here you could upload these metrics (in JSON form) to your servers to aggregate app performance metrics
            }
        }
    }
}
