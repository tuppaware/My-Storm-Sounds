//
//  HomePresenter.swift
//  My Storm
//
//  Created by Adam Ware on 27/12/21.
//  
//

import UIKit
import Foundation
import SwiftDate

protocol HomeDisplay: AnyObject {

    func setTitle(title: String)

    /// show loading indicator
    func showActivityIndicator()

    /// hide loading indicator
    func hideActivityIndicator()

    /// Load presets into view
    func loadPresets(presets : [Sound])
    
}

protocol HomePresenting: AnyObject {

    func viewDidLoad()

    func actionSound(_ preset: Sound)-> Bool?

    func reloadDatasource()-> Presets?

    func playButtonAction(isPlaying: Bool)
}

class HomePresenter: HomePresenting {
        
    weak var display: HomeDisplay?

    func viewDidLoad()  {
        display?.setTitle(title: "My Storm Sounds")
        loadPresetsFromEndpoint()
    }

    /// Load presets from AppData or fetch them from the endpoint as required
    func loadPresetsFromEndpoint() {
        let presets = MyStormData.shared.getFeaturedForFrontPage()
        // if always fetch data then ignore logic
        if AppData.shared.fetchFeedOnRestart {
            getData()
        } else {
            // check if data is older than 24 hours
            if MyStormData.shared.needsUpdating() {
                getData()
            } else if presets.count != 0 {
                display?.loadPresets(presets: presets)
            } else {
                getData()
            }
        }
    }

    func reloadDatasource()-> Presets? {
        if let presets = AppData.shared.featuredPresets {
            return presets
        }
        return nil
    }

    func playButtonAction(isPlaying: Bool){
        if isPlaying {
            AdamAudioPlayer.shared.pauseAll()
        } else {
            AdamAudioPlayer.shared.resumeAll()
        }
    }


    /// Plays/Pauses or downloads a particular sound, returning the updated state for the play button on the cell
    /// - Parameter preset: Preset object
    /// - Returns: Play state
    func actionSound(_ preset: Sound)-> Bool? {
        if preset.downloaded ?? false {
            // its downloaded play or pause the sound
            return togglePlayState(preset: preset)
        } else {
            downloadSound(preset: preset)
            return nil
        }
    }

    private func togglePlayState(preset: Sound)-> Bool {
        let presetID = "\(preset.id)"
        if AdamAudioPlayer.shared.isPlayingWith(identifier: presetID) {
            AdamAudioPlayer.shared.pauseSound(identifier: presetID)
            MyStormData.shared.incrementPlays(preset.id)
            return false
        } else {
            guard let downloadedFile = preset.downloadedFile, !downloadedFile.isEmpty else {
                print("error downloaded file not found")
                return false
            }
            AdamAudioPlayer.shared.play(identifier: presetID, fileName: downloadedFile, looped: true)
            MyStormData.shared.incrementPlays(preset.id)
            return true
        }
    }

    private func getData() {
        display?.showActivityIndicator()
        guard let uuid = AppData.shared.uuid else {
            print("feed error : UUID wasnt found")
            return
        }

        let urlString = "\(sounds.get)/\(uuid)"
        self.fetchData(urlString, completion: { (data) in
            DispatchQueue.main.async {
                self.display?.hideActivityIndicator()
                do {
                    var presetsSounds = try JSONDecoder().decode(Presets.self, from: data)
                    presetsSounds.lastUpdated = Date()
                    MyStormData.shared.checkAndAddFeatured(presetsSounds)
                    let updatedData = MyStormData.shared.getFeaturedForFrontPage()
                    self.display?.loadPresets(presets: updatedData)
                } catch let error {
                    print("feed error \(error)")
                }
            }
        })
    }

    private func downloadSound(preset: Sound) {
        DownloadService.shared.downloadSoundInt(soundInt: preset.id)
    }

    private func fetchData(_ url: String, completion: @escaping (Data) -> Void) {
        APIHelper.shared.fetchDataFromAPI(url: url, completionBlock: completion)
    }

}
