//
//  DownloadService.swift
//  My Storm
//
//  Created by Adam Ware on 13/6/21.
//  Copyright © 2021 Adam Ware. All rights reserved.
//

import Foundation
import SDDownloadManager

struct DownloadObject {
    var id: Int
    var state: DownloadState
    var progress: Float
    var localURL: String
    var errorDescription: String?

    enum DownloadState: Int {
        case notDownloaded = 0
        case downloading = 1
        case downloaded = 3
    }

}


class DownloadService: NSObject {

    static let shared = DownloadService()
    private var downloadObject: DownloadObject? = nil
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    func downloadSoundInt(soundInt: Int) {

        let preSoundString = "\(audio.get)/%@"
        SDDownloadManager.shared.showLocalNotificationOnBackgroundDownloadDone = true
        SDDownloadManager.shared.localNotificationText = "All background downloads complete"
        let fileName = self.returnRightFile(id: soundInt)
        let urlString = String(format: preSoundString, fileName)

        appDelegate.registerBackgroundTask()

        self.downloadObject = DownloadObject(id: soundInt, state: .downloading, progress: 0, localURL: "", errorDescription: nil)

        guard let urlComplete = URL(string: urlString) else {
            return
        }
        let request = URLRequest(url: urlComplete)
        _ = SDDownloadManager.shared.downloadFile(withRequest: request,
                                                  inDirectory: "sounds",
                                                  withName: fileName,
                                                  shouldDownloadInBackground: true,
                                                  onProgress:  { [weak self] (progress) in
                                                    self?.downloadObject?.progress = Float(progress)
                                                    self?.downloadObject?.id = soundInt
                                                    self?.downloadObject?.state = .downloading
                                                    self?.advertiseDownloadObject()
                                                    print(progress)
                                                  }) { [weak self] (error, url) in
            if let error = error {

                self?.appDelegate.endBackgroundTask()
                self?.downloadObject?.progress = 0
                self?.downloadObject?.id = soundInt
                self?.downloadObject?.state = .notDownloaded
                self?.downloadObject?.errorDescription = error.localizedDescription
                self?.advertiseDownloadObject()
            } else {
                self?.appDelegate.endBackgroundTask()
                MyStormData.shared.toggleDownloadState(soundInt, downloaded: true, fileDownloaded: fileName)

                self?.downloadObject?.progress = 1
                self?.downloadObject?.state = .downloaded
                self?.advertiseDownloadObject()

            }
        }
    }

    private func advertiseDownloadObject() {
        if let downloadObj = self.downloadObject {
            NotificationCenter.default.post(name: .downloadObject, object: downloadObj, userInfo:  nil)
        }
    }

    private func returnRightFile(id: Int) -> String {
        guard let dataSource = MyStormData.shared.returnFeatured(id) else {
            print("error finding featured")
            return ""
        }
        let wantsHQ = AppData.shared.highQuailtyEnabled
        switch true {
        case (wantsHQ && !(dataSource.fileHighres?.isEmpty ?? true) && dataSource.fileHighres != "undefined"):
            return dataSource.fileHighres ?? ""
        default:
            return dataSource.file ?? ""
        }
    }
}
