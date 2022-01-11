//
//  SettingsPresenter.swift
//  My Storm
//
//  Created by Adam Ware on 27/12/21.
//  
//

import UIKit
import Foundation

protocol SettingsDisplay: AnyObject {

}

protocol SettingsPresenting: AnyObject {

}

class SettingsPresenter: SettingsPresenting {
        
    weak var display: SettingsDisplay?
    
}
