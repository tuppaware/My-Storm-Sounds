//
//  AppDelegate.swift
//  My Storm
//
//  Created by Adam Ware on 27/12/21.
//

import UIKit
import BackgroundTasks
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().customNavigationBar()
        self.setupUUID()
        setupAudioConfig()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: -  Setting up background tasks
    func setupBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.adamware.myStorm.fetch", using: nil) { (task) in
            guard let task = task as? BGProcessingTask else {
                print("task failure")
                return
            }
            self.handleAppRefreshTask(task: task)
        }
    }

    func setupAudioConfig() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try session.setActive(true)

        } catch let error {
            print(error)
        }
    }

    // MARK: - Background task setup
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskIdentifier.invalid)
    }

    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskIdentifier.invalid
    }

    private func handleAppRefreshTask(task: BGProcessingTask) {
        // we can add more here later if we wish
        task.setTaskCompleted(success: true)
    }

    /// Create and store a custom uuid on startup
    private func setupUUID() {
        if let uuid = AppData.shared.uuid, uuid.isEmpty {
            let uuid = UUID().uuidString
            AppData.shared.uuid = uuid
        }
    }

}

extension UINavigationBar {

    func customNavigationBar() {
        // cSet text to change on theme
        self.tintColor = UIColor.lightText
        self.barTintColor = .white
        self.isTranslucent = false
        self.prefersLargeTitles = true
        // Colour for labels to dark
        self.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkText]
        self.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkText]

        // Choice to remove shaddow
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
    }
}
