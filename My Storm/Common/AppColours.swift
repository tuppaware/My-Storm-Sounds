//
//  AppColours.swift
//  My Storm
//
//  Created by Adam Ware on 27/12/21.
//

import Foundation
import UIKit

/// Shared Theming and colours for the app.
class AppColours {

    private static var _shared: AppColours = AppColours()

    public static var shared: AppColours {
        return _shared
    }

    let commonBackgroundColour = UIColor.systemGray6
    let darkBackgroundColour = UIColor.systemBackground

}
