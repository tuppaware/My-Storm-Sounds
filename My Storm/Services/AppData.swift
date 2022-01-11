//
//  AppData.swift
//  My Storm
//
//  Created by Adam Ware on 9/1/20.
//  Copyright © 2020 Adam Ware. All rights reserved.
//

import Foundation
import Disk

class AppData {
    
    static let shared = AppData()
    
    var uuid: String? {
        didSet {
            UserDefaults.standard.set(uuid, forKey: "UUID")
        }
    }

    var playing: Bool {
        didSet {
            UserDefaults.standard.set(playing, forKey: "playing")
            print("playing:", playing)
        }
    }

    var highQuailtyEnabled: Bool {
        didSet {
            UserDefaults.standard.set(highQuailtyEnabled, forKey: "hifiFeaturedOption")
        }
    }

    var fetchFeedOnRestart: Bool {
        didSet {
            UserDefaults.standard.set(fetchFeedOnRestart, forKey: "fetchFeedOnRestart")
        }
    }

    var appMasterVolume: Float {
        didSet {
            UserDefaults.standard.set(appMasterVolume, forKey: "appRainVolume")
        }
    }

    var featuredPresets: Presets? {
        didSet {
            do {
                try UserDefaults.standard.setObject(featuredPresets, forKey: "FeaturedPresets")
                if AppData.shared.debug {
                    print("+ writing Featured")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    var soundLevels: SoundLevelsArray? {
        didSet {
            do {
                try UserDefaults.standard.setObject(soundLevels, forKey: "SoundLevelsArray")
                if AppData.shared.debug {
                    print("+ writing Levels")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }


    var nowPlaying: NowPlayingArray?
    var debug: Bool
    
    private init() {
        uuid = UserDefaults.standard.string(forKey: "UUID") ?? ""
        playing = false
        highQuailtyEnabled = UserDefaults.standard.bool(forKey: "hifiFeaturedOption")
        appMasterVolume = UserDefaults.standard.float(forKey: "appRainVolume")
        nowPlaying = NowPlayingArray(playing: [])
        debug = true //UserDefaults.standard.bool(forKey: "debug")
        fetchFeedOnRestart = UserDefaults.standard.bool(forKey: "fetchFeedOnRestart")
        do {
            featuredPresets = try UserDefaults.standard.getObject(forKey: "FeaturedPresets", castTo: Presets.self)
        } catch {
            print(error.localizedDescription)
        }
        do {
            soundLevels = try UserDefaults.standard.getObject(forKey: "SoundLevelsArray", castTo: SoundLevelsArray.self)
        } catch {
            print(error.localizedDescription)
        }

    }
    
}
