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

        view.addSubviews([closeButton, saveButton])
        let closeImage = UIImage(systemName: "chevron.backward.circle.fill", withConfiguration: iconConfig)
        closeButton.image = closeImage
        closeButton.tintColor = .commonGrey
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
    }
    
    private func createEasyTipView(forView: UIView, text: String, onTap: (()->Void)?) {
        let textLabel = UILabel()
        textLabel.font = .futura(withSize: 16)
        textLabel.textColor = .white
        textLabel.numberOfLines = 0
        textLabel.text = text
        
        let textMaxSize = CGSize(width: UIScreen.main.bounds.width - 64 - 12 - 8, height: CGFloat.greatestFiniteMagnitude)
        let textSize = textLabel.systemLayoutSizeFitting(textMaxSize)
        textLabel.frame = CGRect(origin: .zero, size: textSize)
        
        let closeButton = UIButton(frame: CGRect(x: textSize.width + 15, y: -6, width: 30, height: 30))
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
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 0, left: 16, bottom: 4, right: 16)
        preferences.positioning.contentInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        preferences.positioning.maxWidth = UIScreen.main.bounds.width - 64
        preferences.animating.dismissOnTap = true
        
        let tooltip = EasyTipView(contentView: contentView, preferences: preferences)
        
        DispatchQueue.main.async {
            tooltip.show(animated: true, forView: forView, withinSuperview: nil)
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

        } else {

            print("Success")
            self.createEasyTipView(forView: self.saveButton, text: "saved in photo") {
                print("Tapped")
            }
        }
    }
}
