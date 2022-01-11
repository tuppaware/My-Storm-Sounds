//
//  NowPlaying.swift
//  My Storm
//
//  Created by Adam Ware on 27/12/21.
//

import Foundation


struct NowPlayingArray: Codable {
    var playing: [NowPlayingLocal]
}

struct NowPlayingLocal: Codable, Hashable {
    var id: Int
    var playing: Bool = false
    let identifier: UUID = UUID()

    func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }

    static func == (lhs: NowPlayingLocal, rhs: NowPlayingLocal) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

struct SoundLevelsArray: Codable {
    var levels: [SoundLevelsLocal]
}

struct SoundLevelsLocal: Codable {
    var id: Int
    var currentSoundLevel: Float = 0
}
