//
//  Constants.swift
//  My Storm
//
//  Created by Adam Ware on 27/12/21.
//

import Foundation


struct app {
    static let currentVersion = "1"
    static let authorEmail = "tuppaware@gmail.com"
    static let authorLinkedin = "https://www.linkedin.com/in/tuppaware-bne"
}

struct server {
    static let domain       = "https://infiniterelax.com"
    static let api          = "https://infiniterelax.com/api/public"
    static let cdn          = "https://files.infiniterelax.com"

    /// This is the required key to return valid api of sounds.
    static let accessKey    = "19541954"
}

struct api {
    static let version = "is_v5"
}

struct sounds {
    static let get = "\(server.api)/\(api.version)/my-storm"
}

struct getBackgrounds {
    static let get = "\(server.cdn)/backgrounds"
    static let image = "\(server.api)/\(api.version)/backgrounds/image"
    static let endpoint = "\(server.api)/\(api.version)/backgrounds"
}

struct audio {
    static let get = "\(server.api)/\(api.version)/audio"
}

struct images {
    static let background = "\(server.cdn)/backgrounds/"
    static let get = "\(server.cdn)/images/"
    static let nonCDNbg  = "\(server.domain)/sounds/backgrounds/"
}


extension Notification.Name {
    public static let downloadObject    = Notification.Name(rawValue: "downloadObject")
    public static let errorObject       = Notification.Name(rawValue: "errorObject")
    public static let playing           = Notification.Name(rawValue: "playing")
    public static let reloadPresets     = Notification.Name(rawValue: "reloadPresets")
}
