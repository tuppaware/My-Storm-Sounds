//
//  MyStormData.swift
//  My Storm
//
//  Created by Adam Ware on 8/8/21.
//  Copyright © 2021 Adam Ware. All rights reserved.
//

import Foundation
import SwiftDate


/// Just a common datasource. 
class MyStormData {

    static let shared = MyStormData()

    func returnFeatured(_ id: Int)-> Sound? {
        return AppData.shared.featuredPresets?.sound.first(where: { $0.id == id })
    }

    func checkAndAddFeatured(_ objects: Presets) {
        if var totalObject = AppData.shared.featuredPresets {
            totalObject.lastUpdated = Date()
            let arrayIDs = totalObject.sound.compactMap({ $0.id })
            let muObject = objects.sound.filter({ !(arrayIDs.containsAny(searchTerms: Set(arrayLiteral: $0.id)) )})
            totalObject.lastUpdated = Date()
            totalObject.sound.append(contentsOf: muObject)
            AppData.shared.featuredPresets = totalObject
            print("# Checked and added \(muObject.count) Featured Presets")
        } else {
            var objectToSave = objects
            objectToSave.lastUpdated = Date()
            AppData.shared.featuredPresets = objectToSave
            print("# Checked and added \(objectToSave.sound.count) Featured Presets")
            return
        }
    }



    func toggleDownloadState(_ id: Int, downloaded: Bool, fileDownloaded: String? = "") {
        if var data = AppData.shared.featuredPresets {
            if var playsObject = data.sound.first(where: { $0.id == id }) {
                playsObject.downloaded = downloaded
                playsObject.downloadedFile = fileDownloaded
                data.sound.removeAll(where: { $0.id == id })
                data.sound.append(playsObject)
                AppData.shared.featuredPresets = data
            }
        }
    }

    func updateSoundLevel(_ soundObject: SoundLevelsLocal) {
        if var data = AppData.shared.soundLevels {
            data.levels.removeAll(where: { $0.id == soundObject.id })
            data.levels.append(soundObject)
            AppData.shared.soundLevels = data
        } else {
            let data = SoundLevelsArray(levels: [soundObject])
            AppData.shared.soundLevels = data
        }
    }

    func needsUpdating()-> Bool {
        if let lastUpdated = AppData.shared.featuredPresets?.lastUpdated, lastUpdated.isToday {
            return false
        } else {
            return true
        }
    }

    func getFeaturedForFrontPage()-> [Sound] {
        let object = AppData.shared.featuredPresets?.sound.sorted(by: { $0.id < $1.id })
        let dblobject: [Sound]? = object?.sorted(by: { ($0.downloaded == true) != ($1.downloaded == false) })
        return Array(dblobject ?? [])
    }

    func addNowPlaying(_ id: Int, playing: Bool) {
        if var data = AppData.shared.nowPlaying {
            if var packObject = data.playing.first(where: { $0.id == id }) {
                packObject.playing = playing
                data.playing.removeAll(where: { $0.id == id })
                data.playing.append(packObject)
                AppData.shared.nowPlaying = data
            } else {
                let add = NowPlayingLocal(id: id, playing: playing)
                data.playing.append(add)
                AppData.shared.nowPlaying = data
            }
        } else {
            // its empty so add it
            let add = NowPlayingLocal(id: id, playing: playing)
            let data = NowPlayingArray(playing: [add])
            AppData.shared.nowPlaying = data
        }
    }

    func incrementPlays(_ id: Int) {
        if var data = AppData.shared.featuredPresets {
            if var playsObject = data.sound.first(where: { $0.id == id }) {
                if var plays = playsObject.plays {
                    plays += 1
                    playsObject.plays = plays
                }
                data.sound.removeAll(where: { $0.id == id })
                data.sound.append(playsObject)
                AppData.shared.featuredPresets = data
            }
        }
    }

}
