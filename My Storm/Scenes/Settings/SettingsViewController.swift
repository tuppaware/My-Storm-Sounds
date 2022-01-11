//
//  SettingsViewController.swift
//  My Storm
//
//  Created by Adam Ware on 27/12/21.
//  
//

import UIKit
import Foundation
import MessageUI
import StoreKit

class SettingsViewController: UIViewController, SettingsDisplay {
        
    // MARK: - Properties
    
    @IBOutlet weak var hiresSwitch: UISwitch!
    @IBOutlet weak var fetchFeedSwitch: UISwitch!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profilePanel: UIView!
    @IBOutlet weak var profileWrapper: UIView!

    // Other apps panels
    @IBOutlet weak var isImage: UIImageView!
    @IBOutlet weak var isPanel: UIView!
    @IBOutlet weak var isWrapp: UIView!
    @IBOutlet weak var otterPanel: UIView!
    @IBOutlet weak var otterWrapp: UIView!
    @IBOutlet weak var otterImage: UIImageView!

    let infiteStormStoreID = "576664798"
    let otterMailStoreID = "1457528880"

    let presenter: SettingsPresenting
    
    required init(presenter: SettingsPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented for Settings")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        hiresSwitch.isOn = AppData.shared.highQuailtyEnabled
        fetchFeedSwitch.isOn = AppData.shared.fetchFeedOnRestart
        informationLabel.text = "The sounds and api for this demo app are an off-shoot of the sounds and api used by the popular iOS app Infinite Storm. \n\nThe sounds are Creative Commons or copyright of the author."
        applyShadow()
        [profileImage, isImage, otterImage].forEach({ image in
            image.layer.cornerRadius = image.bounds.height/2
        })
    }

    private func applyShadow() {
        [isPanel, profilePanel, otterPanel].forEach({ view in
            view?.layer.shadowColor = UIColor.gray.cgColor
            view?.layer.shadowOffset = CGSize(width: 0, height: 0)
            view?.layer.shadowRadius = 10.0
            view?.layer.shadowOpacity = 0.5
            view?.layer.masksToBounds = false
        })
        [isWrapp, profileWrapper, otterWrapp].forEach({ view in
            view?.layer.cornerRadius = 10
            view?.layer.borderWidth = 1.0
            view?.layer.borderColor = UIColor.clear.cgColor
            view?.layer.masksToBounds = true
        })
    }

    @IBAction func fetchAction(_ sender: Any) {
        AppData.shared.fetchFeedOnRestart = fetchFeedSwitch.isOn
    }

    @IBAction func hiresAction(_ sender: Any) {
        AppData.shared.highQuailtyEnabled = hiresSwitch.isOn
    }

    @IBAction func emailMeAction(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([app.authorEmail])
            self.present(mail, animated: true, completion: nil)
        } else {
            // mail client didnt work
            let alert = UIAlertController(title: "No Mail Client Installed", message: "You dont have the native mail client installed - but you can email me at 'tuppaware@gmail.com'", preferredStyle: .alert)
            let action = UIAlertAction(title: "Close", style: .default, handler: { (_) in })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func gotToIS(_ sender: Any) {
        openStoreProductWithiTunesItemIdentifier(infiteStormStoreID)
    }

    @IBAction func gotToOM(_ sender: Any) {
        openStoreProductWithiTunesItemIdentifier(otterMailStoreID)
    }

    @IBAction func goToLinkedIn(_ sender: Any) {
        guard let url = URL(string: app.authorLinkedin) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}

extension SettingsViewController: SKStoreProductViewControllerDelegate {

    func openStoreProductWithiTunesItemIdentifier(_ identifier: String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self

        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
        storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, error) -> Void in
            if loaded {
                self?.present(storeViewController, animated: true, completion: nil)
            }
        }
    }
    private func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
