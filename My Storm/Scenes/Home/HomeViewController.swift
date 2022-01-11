//
//  HomeViewController.swift
//  My Storm
//
//  Created by Adam Ware on 27/12/21.
//  
//

import UIKit
import Foundation


class HomeViewController: UIViewController, HomeDisplay {
        
    // MARK: - Properties
    @IBOutlet weak var customnNavigationView: UIView!
    @IBOutlet weak var homeCollectionView: UICollectionView!
    @IBOutlet weak var headerLabel: UILabel!

    // Custom Navbar
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!

    static let DEF_HOME_CELL_REUSE_ID = "Home_cell"
    let presenter: HomePresenting
    var datasource: [Sound]? // refactor to just ids?
    var isPlaying: Bool = false {
        didSet {
            self.playButton.isSelected = isPlaying
        }
    }
    var isLoading: Bool = true

    required init(presenter: HomePresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented for Home")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureCollectionView()
        presenter.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived(_:)), name: .downloadObject, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlaying), name: .playing, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Display

    func setTitle(title: String) {
        self.headerLabel.text = title
        self.title = title
    }

    func showActivityIndicator() {
        self.homeCollectionView.reloadData()
    }

    func hideActivityIndicator() {
        isLoading = false
    }

    func loadPresets(presets: [Sound]) {
        self.datasource = presets
        self.homeCollectionView.reloadData()
    }
    
    @IBAction func playButtonAction(_ sender: Any) {
        presenter.playButtonAction(isPlaying: isPlaying)
    }

    // MARK: - Setup

    private func setupUI() {
        self.homeCollectionView.backgroundColor = .clear
        self.view.backgroundColor = AppColours.shared.darkBackgroundColour
    }

    private func configureCollectionView() {
        self.homeCollectionView.delegate = self
        self.homeCollectionView.dataSource = self
        let cellNib = UINib(nibName: "HomeCollectionViewCell", bundle: nil)
        self.homeCollectionView.register(cellNib, forCellWithReuseIdentifier: HomeViewController.DEF_HOME_CELL_REUSE_ID)
    }


    /// Download notifcation action - tells the cell that a download is in progress and updates the progress bar
    /// - Parameter notification: notifcation
    @objc private func notificationReceived(_ notification: Notification) {
        guard let downloadObject = notification.object as? DownloadObject else {
            print("error in download object")
            return
        }

        if let cell = homeCollectionView.visibleCells.filter({ $0.tag == downloadObject.id }).first as? HomeCollectionViewCell {
            switch downloadObject.state {
            case .downloading:
                let roundedProgress = Float(round(100 * downloadObject.progress)/100)
                cell.downloadProgress(progress: roundedProgress)
            case .downloaded:
                if var preset = MyStormData.shared.returnFeatured(downloadObject.id) {
                    preset.downloaded = true
                    cell.configureCell(preset, cellState: .downloaded)
                }
            default:
                break
            }
        } else {
            print("cell not found")

        }
    }

    @objc private func updatePlaying() {
        isPlaying = AdamAudioPlayer.shared.isAnySoundPlaying()
    }

    @IBAction func profileButtonAction(_ sender: Any) {
        let presenter = SettingsPresenter()
        let viewController = SettingsViewController(presenter: presenter)
        presenter.display = viewController
        viewController.modalPresentationStyle = .automatic
        self.present(viewController, animated: true, completion: nil)
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLoading ? 6 : (self.datasource?.count ?? 0)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeViewController.DEF_HOME_CELL_REUSE_ID, for: indexPath) as? HomeCollectionViewCell else {
            return UICollectionViewCell()
        }

        if let cellData = datasource?[indexPath.row], let updatedSource = MyStormData.shared.returnFeatured(cellData.id) {
            let cellState: AudioCellState = (updatedSource.downloaded ?? false) ? .downloaded : .notDownloaded
            cell.configureCell(updatedSource, cellState: cellState)
        }

        return cell
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? HomeCollectionViewCell else {
            return
        }

        if let cellData = datasource?[indexPath.row], let updatedSource = MyStormData.shared.returnFeatured(cellData.id) {
            if let result = presenter.actionSound(updatedSource) {
                cell.setPlayState(isPlaying: result)
            } else {
                // sound is downloading
                cell.startDownloadActivity()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return returnCellSize()
    }

    // Distance Between Item Cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    // Cell Margin
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
    


    private func returnCellSize()-> CGSize {
        let divideBy: CGFloat = returnCellWidth()
        let padding: CGFloat = 32
        return CGSize(width: (homeCollectionView.frame.width/divideBy)-padding, height: 180)
    }

    private func returnCellWidth() -> CGFloat {
        let widthOfView = homeCollectionView.frame.width
        switch true {
        case (widthOfView < 560):
            return 1
        case (widthOfView >= 560 && widthOfView < 768):
            return 2
        case (widthOfView > 768):
            return 2
        default:
            return 2
        }
    }


}
