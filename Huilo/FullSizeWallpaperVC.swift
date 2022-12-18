//
//  FullSizeWallpaperVC.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 15.12.2022.
//

import UIKit
import EasyTipView

class FullSizeWallpaperVC: UIViewController {
    private let wallpaperImageView = UIImageView()
    private let iconConfig = UIImage.SymbolConfiguration(scale: .large)
    private let closeButton = UIImageView()
    private let saveButton = UIImageView()
    private let timeLabel = UILabel()
    private let dateLabel = UILabel()
    
    private let image: UIImage
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        modalPresentationStyle = .fullScreen
        wallpaperImageView.image = image
//        wallpaperImageView.contentMode = .scaleAspectFill
        
        view.addSubview(wallpaperImageView)
        wallpaperImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        view.addSubviews([closeButton, saveButton, timeLabel, dateLabel])
        let closeImage = UIImage(systemName: "chevron.backward.circle.fill", withConfiguration: iconConfig)
        closeButton.image = closeImage
        closeButton.tintColor = .black
        closeButton.backgroundColor = .white.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 20
        closeButton.addTapGesture(target: self, action: #selector(closeTapped))
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Layout.leading)
            $0.leading.equalToSuperview().offset(Layout.leading)
            $0.width.equalTo(40)
            $0.height.equalTo(35)
        }
        
        let saveImage = UIImage(systemName: "arrow.down.circle.fill", withConfiguration: iconConfig)
        saveButton.image = saveImage
        saveButton.tintColor = .black
        saveButton.backgroundColor = .white.withAlphaComponent(0.5)
        saveButton.layer.cornerRadius = 24
        saveButton.addTapGesture(target: self, action: #selector(saveImageTapped))
        
        saveButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-5)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.equalTo(46)
            $0.height.equalTo(40)
        }
        
        timeLabel.textColor = .white
        timeLabel.text = "9:41"
        //SFProRailsRegular
        timeLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 105)
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(130)
            $0.centerX.equalToSuperview()
        }
        
        dateLabel.textColor = .white
        dateLabel.text = "Friday, December 16"
        dateLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 22)
        dateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(timeLabel.snp.top).offset(12)
        }
    }
    
    private func createEasyTipView(forView: UIView, text: String, onTap: (()->Void)?) {
        let textLabel = UILabel()
        textLabel.font = .futura(withSize: 16)
        textLabel.textColor = .white
        textLabel.numberOfLines = 0
        textLabel.text = text
        
        let textMaxSize = CGSize(width: UIScreen.main.bounds.width - 64 - 12 - 8, height: CGFloat.greatestFiniteMagnitude)
        let textSize = textLabel.systemLayoutSizeFitting(textMaxSize)
        textLabel.frame = CGRect(origin: CGPoint(x: 34, y: 0), size: textSize)  //CGRect(origin: .zero, size: textSize)
        
        let closeButton = UIButton(frame: CGRect(x: 0, y: -2, width: 24, height: 24))
        closeButton.setImage(UIImage(named: "libraryIcon"), for: .normal)
        
        let contentView = UIView()
        contentView.addSubview(textLabel)
        contentView.addSubview(closeButton)
        
        let contentSize = CGSize(width: textSize.width + 16 + closeButton.frame.width, height: textSize.height)
        contentView.frame = CGRect(origin: .zero, size: contentSize)
        
        var preferences = EasyTipView.Preferences()
        preferences.drawing.backgroundColor = .black.withAlphaComponent(0.5)
        preferences.drawing.arrowPosition = .bottom
        preferences.drawing.arrowWidth = 16
        preferences.drawing.arrowHeight = 8
        preferences.drawing.cornerRadius = 14
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 12)
        preferences.positioning.contentInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 12)
        preferences.positioning.maxWidth = UIScreen.main.bounds.width - 64
        preferences.animating.dismissOnTap = true
        
        let tooltip = EasyTipView(contentView: contentView, preferences: preferences)
        
        DispatchQueue.main.async {
            tooltip.show(animated: true, forView: forView, withinSuperview: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                tooltip.dismiss()
            }
        }
    }
    
    @objc private func closeTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func saveImageTapped() {
        self.shortVibrate()
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    //MARK: - Save Image callback

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

        if let error = error {

            print(error.localizedDescription)
            self.createEasyTipView(forView: self.saveButton, text: error.localizedDescription) {
                print("Tapped")
            }

        } else {

            print("Success")
            self.createEasyTipView(forView: self.saveButton, text: "saved in photo") {
                print("Tapped")
            }
        }
    }
}

import Kingfisher

class FullSizeWallpaperInitURLVC: UIViewController {
    private let wallpaperImageView = UIImageView()
    private let iconConfig = UIImage.SymbolConfiguration(scale: .large)
    private let closeButton = UIImageView()
    private let saveButton = UIImageView()
    private let timeLabel = UILabel()
    private let dateLabel = UILabel()
    
    private let urlString: String
    init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        modalPresentationStyle = .fullScreen
        wallpaperImageView.kf.indicatorType = .activity
        wallpaperImageView.kf.setImage(with: URL(string: urlString)!, options: [.transition(.fade(0.2))])
//        wallpaperImageView.contentMode = .scaleAspectFill
        
        view.addSubview(wallpaperImageView)
        wallpaperImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        view.addSubviews([closeButton, saveButton, timeLabel, dateLabel])
        let closeImage = UIImage(systemName: "chevron.backward.circle.fill", withConfiguration: iconConfig)
        closeButton.image = closeImage
        closeButton.tintColor = .black
        closeButton.backgroundColor = .white.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 20
        closeButton.addTapGesture(target: self, action: #selector(closeTapped))
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Layout.leading)
            $0.leading.equalToSuperview().offset(Layout.leading)
            $0.width.equalTo(40)
            $0.height.equalTo(35)
        }
        
        let saveImage = UIImage(systemName: "arrow.down.circle.fill", withConfiguration: iconConfig)
        saveButton.image = saveImage
        saveButton.tintColor = .black
        saveButton.backgroundColor = .white.withAlphaComponent(0.5)
        saveButton.layer.cornerRadius = 24
        saveButton.addTapGesture(target: self, action: #selector(saveImageTapped))
        
        saveButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-5)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.equalTo(46)
            $0.height.equalTo(40)
        }
        
        timeLabel.textColor = .white
        timeLabel.text = "9:41"
        //SFProRailsRegular
        timeLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 105)
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(130)
            $0.centerX.equalToSuperview()
        }
        
        dateLabel.textColor = .white
        dateLabel.text = "Friday, December 16"
        dateLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 22)
        dateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(timeLabel.snp.top).offset(12)
        }
    }
    
    private func createEasyTipView(forView: UIView, text: String, onTap: (()->Void)?) {
        let textLabel = UILabel()
        textLabel.font = .futura(withSize: 16)
        textLabel.textColor = .white
        textLabel.numberOfLines = 0
        textLabel.text = text
        
        let textMaxSize = CGSize(width: UIScreen.main.bounds.width - 64 - 12 - 8, height: CGFloat.greatestFiniteMagnitude)
        let textSize = textLabel.systemLayoutSizeFitting(textMaxSize)
        textLabel.frame = CGRect(origin: CGPoint(x: 34, y: 0), size: textSize)  //CGRect(origin: .zero, size: textSize)
        
        let closeButton = UIButton(frame: CGRect(x: 0, y: -2, width: 24, height: 24))
        closeButton.setImage(UIImage(named: "libraryIcon"), for: .normal)
        
        let contentView = UIView()
        contentView.addSubview(textLabel)
        contentView.addSubview(closeButton)
        
        let contentSize = CGSize(width: textSize.width + 16 + closeButton.frame.width, height: textSize.height)
        contentView.frame = CGRect(origin: .zero, size: contentSize)
        
        var preferences = EasyTipView.Preferences()
        preferences.drawing.backgroundColor = .black.withAlphaComponent(0.5)
        preferences.drawing.arrowPosition = .bottom
        preferences.drawing.arrowWidth = 16
        preferences.drawing.arrowHeight = 8
        preferences.drawing.cornerRadius = 14
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 12)
        preferences.positioning.contentInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 12)
        preferences.positioning.maxWidth = UIScreen.main.bounds.width - 64
        preferences.animating.dismissOnTap = true
        
        let tooltip = EasyTipView(contentView: contentView, preferences: preferences)
        
        DispatchQueue.main.async {
            tooltip.show(animated: true, forView: forView, withinSuperview: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                tooltip.dismiss()
            }
        }
    }
    
    @objc private func closeTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func saveImageTapped() {
        if let image = wallpaperImageView.image {
            self.shortVibrate()
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }

    //MARK: - Save Image callback

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

        if let error = error {

            print(error.localizedDescription)
            self.createEasyTipView(forView: self.saveButton, text: error.localizedDescription) {
                print("Tapped")
            }

        } else {

            print("Success")
            self.createEasyTipView(forView: self.saveButton, text: "saved in photo") {
                print("Tapped")
            }
        }
    }
}
