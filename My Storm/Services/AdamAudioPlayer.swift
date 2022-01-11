//
//  AdamAudioPlayer.swift
//  
//
//  Created by Adam Ware on 27/8/18.
//  Copyright © 2018 Adam Ware. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import Foundation
import AVFoundation
import Disk


 @objc class AdamAudioPlayer: NSObject, AVAudioPlayerDelegate {
     
    private var container = [String : AVAudioPlayer]()

    // MARK: - Shared Instantce
     @objc static let shared = AdamAudioPlayer()
    

    private override init() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: .mixWithOthers)
            try session.setActive(true)
        } catch let error {
            NotificationCenter.default.post(name: .errorObject, object: nil, userInfo: ["error": error.localizedDescription])
        }
    }
    
    private func returnAudioFile( fileName: String, inBundle: Bool = false )-> String? {
        let fixedFileName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        let soundFileComponents = fixedFileName.components(separatedBy: ".")
        if soundFileComponents.count < 2 {
            return nil
        }

        if !inBundle {
            let generalFilePath = "sounds/\(fileName)"
            if Disk.exists(generalFilePath, in: .caches) {
                do {
                    let url = try Disk.url(for: generalFilePath, in: .caches).path
                    return url
                } catch let error {
                    NotificationCenter.default.post(name: .errorObject, object: nil, userInfo: ["error": error.localizedDescription])
                }
            }
            return nil
        } else {
            guard let path = Bundle.main.path(forResource: soundFileComponents[0], ofType: soundFileComponents[1]) else {
                return nil
            }
            return path
        }
    }
    
    @objc public func play(identifier: String, fileName: String?, inBundle: Bool = false, looped: Bool) {
        if (UserDefaults.standard.contains(key: identifier) == false && fileName != nil ){
            // We havent stored this sound so we can go ahead and call it
            var player: AVAudioPlayer?
            if player == nil {
                do {
                    guard let filename = fileName, let resource = returnAudioFile(fileName: filename, inBundle: false), !resource.isEmpty else {
                        NotificationCenter.default.post(name: .errorObject, object: nil, userInfo: ["error": "adamPlayer error file not found"])
                        return
                    }
                    let urlFile = URL(fileURLWithPath: resource)
                    player = try AVAudioPlayer(contentsOf: urlFile)
                    container[identifier] = player

                    guard let player = player else {
                        return
                    }
                    if (looped) {
                        player.numberOfLoops = -1
                    } else {
                        player.numberOfLoops = 0
                    }
                    player.delegate = self
                    player.setVolume(0, fadeDuration: 0)
                    player.play()
                    player.setVolume(0.8, fadeDuration: 1)
                    NotificationCenter.default.post(name: .playing, object: nil, userInfo: nil)
                    UserDefaults.standard.set(1, forKey: identifier)
                   
                } catch let error {
                    print(error.localizedDescription)
                    UserDefaults.standard.removeObject(forKey: identifier)
                    NotificationCenter.default.post(name: .errorObject, object: nil, userInfo: ["error": error.localizedDescription])
                }
            }
        } else {
            // we have it already so play it from stored
            if let player = container[identifier] {
                player.setVolume(0, fadeDuration: 0)
                player.play()
                player.setVolume(0.8, fadeDuration: 1)
            } else {
                UserDefaults.standard.removeObject(forKey: identifier)
                self.play(identifier: identifier, fileName: fileName,inBundle: inBundle, looped: true)
            }
            NotificationCenter.default.post(name: .playing, object: nil, userInfo: nil)
        }
    }
    
    // This kills the object fyi
    @objc public func stopSound(identifier: String) {
        if (UserDefaults.standard.contains(key: identifier)){
            if let player = container[identifier] {
                if player.rate > 0 {
                    player.stop()
                    UserDefaults.standard.removeObject(forKey: identifier)
                    container.removeValue(forKey: identifier)
                }
            }
        }
        NotificationCenter.default.post(name: .playing, object: nil, userInfo: nil)
    }
    
    
    // this just pauses the sound but keeps the object
    func pauseSound(identifier: String) {
        if (UserDefaults.standard.contains(key: identifier)){
            if let player = container[identifier] {
                player.pause()
            }
        }
        NotificationCenter.default.post(name: .playing, object: nil, userInfo: nil)
    }
    
    // this just pauses the sound but keeps the object
   func pauseAll() {
        for (_, players) in container {
            players.pause()
        }
    print("adamPlayer Paused all")
       NotificationCenter.default.post(name: .playing, object: nil, userInfo: nil)
    }
    
    // this just pauses the sound but keeps the object
    func resumeAll() {
        for (_, players) in container {
            players.play()
        }
        print("adamPlayer Resumed all")
        NotificationCenter.default.post(name: .playing, object: nil, userInfo: nil)
    }
    
     // This kills all the players
    func stopAll() {
        for (key, players) in container {
            players.stop()
            UserDefaults.standard.removeObject(forKey: key)
            container.removeValue(forKey: key)
        }
        print("adamPlayer Stopped all")
        NotificationCenter.default.post(name: .playing, object: nil, userInfo: nil)
    }
    
    func whatsPlaying()-> Array<String>  {
        let componentArray = Array(container.keys)
        return componentArray
    }
    
    func changeVolumeOfAll(volume: Float, overTime:Int? = 0) {
        for (_, players) in container {
            players.setVolume(volume, fadeDuration: Double(overTime ?? 0))
        }
    }

     func isAnySoundPlaying()-> Bool {
         let arrayBool: [Bool] = container.compactMap({ $0.value.isPlaying })
         return arrayBool.contains(true)
     }
    
   func changeVolumeOf(identifier: String, volume: Float) {
        if (UserDefaults.standard.contains(key: identifier)){
            if let player = container[identifier] {
                player.setVolume(volume, fadeDuration: 0)
            }
        }
    }
    
    func isPlayingWith(identifier: String)->Bool {
        var thisIsPlaying = false
        if (UserDefaults.standard.contains(key: identifier)){
            if let player = container[identifier] {
                thisIsPlaying = player.isPlaying
            }
        }
        return thisIsPlaying
    }
    
    func volumeOfSoundWith(identifier: String)->Float {
        var volumeOfSound : Float = 0.0
        if (UserDefaults.standard.contains(key: identifier)){
            if let player = container[identifier] {
                volumeOfSound = player.volume
            }
        }
        return volumeOfSound
    }
}

extension UserDefaults {
    func contains(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}

