//
//  HomeCollectionViewCell.swift
//  My Storm
//
//  Created by Adam Ware on 28/12/21.
//

import UIKit
import SDWebImage

enum AudioCellState {
    case downloading
    case notDownloaded
    case downloaded
}

class HomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var soundName: UILabel!
    @IBOutlet weak var soundSubtitle: UILabel!
    @IBOutlet weak var soundImageView: UIImageView!
    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var downloadProgress: UIProgressView!
    @IBOutlet weak var downloadPanel: UIView!
    @IBOutlet weak var downloadSizeLabel: UILabel!
    @IBOutlet weak var downloadingActivityIndicator: UIActivityIndicatorView!

    var isPlaying: Bool = false {
        didSet {
            self.playImage.image = isPlaying ? UIImage(systemName: "pause.fill") : UIImage(systemName: "play.fill")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - Override animation actions

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animate(isHighlighted: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animate(isHighlighted: false)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animate(isHighlighted: false)
    }

    func configureCell(_ sound: Sound, cellState: AudioCellState) {
        self.tag = sound.id
        self.soundName.text = sound.name
        self.soundSubtitle.text = sound.shortDescription
        self.downloadProgress.isHidden = true // in case of reuse
        self.downloadingActivityIndicator.isHidden = true
        if sound.downloaded ?? false {
            self.isPlaying = AdamAudioPlayer.shared.isPlayingWith(identifier: "\(sound.id)")
            self.downloadProgress.isHidden = true
        } else {
            if cellState == .notDownloaded {
                self.playImage.image = UIImage(systemName: "arrow.down.circle.fill")
            } else if cellState == .downloading {
                self.playImage.image = nil
                self.downloadProgress.isHidden = false
            }
        }
        if let url = URL(string: "\(images.get)\(sound.backgroundImage)") {
            soundImageView.sd_imageTransition = .fade
            soundImageView.sd_setImage(with: url)
        }
        configureDownloadPanel(size: sound.size, state: cellState)
    }

    func startDownloadActivity() {
        self.downloadingActivityIndicator.startAnimating()
        self.downloadingActivityIndicator.isHidden = false
        self.playImage.image = nil
    }

    func downloadProgress(progress: Float) {
        self.playImage.image = nil
        self.downloadProgress.isHidden = false
        self.downloadProgress.progress = progress
    }

    func setPlayState(isPlaying: Bool) {
        self.isPlaying = isPlaying
    }

    func setupUI() {
        self.backgroundColor = .clear
        self.playImage.tintColor = .white
        self.wrapperView.backgroundColor = AppColours.shared.commonBackgroundColour
        self.soundName.textColor = UIColor.darkText
        self.downloadPanel.layer.cornerRadius = 4
        applyShadow()
    }

    private func applyShadow() {
        wrapperView.layer.cornerRadius = 10
        wrapperView.layer.borderWidth = 1.0
        wrapperView.layer.borderColor = UIColor.clear.cgColor
        wrapperView.layer.masksToBounds = true
        contentView.layer.shadowColor = UIColor.gray.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        contentView.layer.shadowRadius = 10.0
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.masksToBounds = false
    }

    private func configureDownloadPanel(size: Int, state: AudioCellState) {
        downloadPanel.isHidden = state == .downloaded
        downloadSizeLabel.text = returnSize(size: size)
    }

    private func returnSize(size: Int)-> String {
        if ((size/1000000) < 1) {
            return "1"
        } else {
            return "\(size/1000000)" //mb
        }
    }


    private func animate(isHighlighted: Bool, completion: ((Bool) -> Void)?=nil) {
        let animationOptions: UIView.AnimationOptions = [.allowUserInteraction]
        if isHighlighted {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: animationOptions, animations: {
                self.transform = .init(scaleX: 0.95, y: 0.95)
            }, completion: completion)
        } else {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: animationOptions, animations: {
                self.transform = .identity
            }, completion: completion)
        }
    }

}
