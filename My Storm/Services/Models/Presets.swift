//
//  Sound.swift
//  My Storm
//
//  Created by Adam Ware on 27/12/21.
//

import Foundation


/// Main API returns a Preset with an array of [Sound]

// MARK: - Presets
struct Presets: Codable, Hashable {

    var sound: [Sound]
    var lastUpdated: Date?
    let identifier: UUID = UUID()

    func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }

    static func == (lhs: Presets, rhs: Presets) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    enum CodingKeys: String, CodingKey {
        case sound
    }

}


// MARK: - Sound
struct Sound: Codable, Hashable {
    let id: Int
    let createdAt: String
    let updatedAt: String
    let name: String
    let shortDescription: String
    let file: String?
    let fileHighres: String?
    let backgroundImage: String
    let size: Int
    let sizeHighres: Int
    let downloads: Int
    let fileLength: String
    var plays: Int? = 0
    let identifier: UUID = UUID()
    var downloaded: Bool? = false
    var downloadedFile: String?

    func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }

    static func == (lhs: Sound, rhs: Sound) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case name, shortDescription, file
        case fileHighres = "file_highres"
        case backgroundImage, size
        case sizeHighres = "size_highres"
        case downloads
        case fileLength = "file_length"
        case plays
        case downloaded
        case downloadedFile
    }
}
