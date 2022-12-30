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
    private let hideTimeButton = UIImageView()
    private let adminPanelButton = UIImageView()
    private let timeLabel = UILabel()
    private let dateLabel = UILabel()
    private let backgroundIconColor: UIColor = .white.withAlphaComponent(0.5)
    var tooltip: EasyTipView!
    
    private let image: UIImage
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let _ = tooltip {
            tooltip.dismiss()
        }
    }
    
    private func setupUI() {
        modalPresentationStyle = .fullScreen
        wallpaperImageView.image = image
        wallpaperImageView.contentMode = .scaleAspectFill
        
        view.addSubview(wallpaperImageView)
        wallpaperImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        view.addSubviews([closeButton, saveButton, timeLabel, dateLabel, hideTimeButton])
        let closeImage = UIImage(systemName: "chevron.backward.circle.fill", withConfiguration: iconConfig)
        closeButton.image = closeImage
        closeButton.tintColor = .black
        closeButton.backgroundColor = backgroundIconColor
        closeButton.layer.cornerRadius = 20
        closeButton.addTapGesture(target: self, action: #selector(closeTapped))
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Layout.leading)
            $0.leading.equalToSuperview().offset(Layout.leading)
            $0.width.equalTo(40)
            $0.height.equalTo(35)
        }
        
        hideTimeButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-5)
            $0.leading.equalToSuperview().offset(Layout.leading)
            $0.width.equalTo(40)
            $0.height.equalTo(35)
        }
        
        let eyeSlash = UIImage(systemName: "eye.slash.circle", withConfiguration: iconConfig)
        let eye = UIImage(systemName: "eye.circle", withConfiguration: iconConfig)
        hideTimeButton.image = eyeSlash
        hideTimeButton.highlightedImage = eye
        hideTimeButton.tintColor = .white.withAlphaComponent(0.7)
        hideTimeButton.backgroundColor = .black
        hideTimeButton.layer.cornerRadius = 20
        hideTimeButton.addTapGesture(target: self, action: #selector(hideTapped))
        let isHighlighted = UserDefaults.standard.bool(forKey: "hideTimeButton")
        hideTimeButton.isHighlighted = isHighlighted
        
        let saveImage = UIImage(systemName: "arrow.down.circle.fill", withConfiguration: iconConfig)
        saveButton.image = saveImage
        saveButton.tintColor = .black
        saveButton.backgroundColor = backgroundIconColor
        saveButton.layer.cornerRadius = 24
        saveButton.addTapGesture(target: self, action: #selector(saveImageTapped))
        
        saveButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-5)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.equalTo(46)
            $0.height.equalTo(40)
        }
        
        if FirebaseManager.shared.isAdmin {
            view.addSubview(adminPanelButton)
            let saveImage = UIImage(systemName: "a.circle.fill", withConfiguration: iconConfig)
            adminPanelButton.image = saveImage
            adminPanelButton.tintColor = .black
            adminPanelButton.backgroundColor = backgroundIconColor
            adminPanelButton.layer.cornerRadius = 24
            adminPanelButton.addTapGesture(target: self, action: #selector(adminPanelTapped))
            
            adminPanelButton.snp.makeConstraints {
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-5)
                $0.centerX.equalToSuperview()
                $0.width.equalTo(46)
                $0.height.equalTo(40)
            }
        }
        
        timeLabel.textColor = .white
        timeLabel.text = "9:41"
        //SFProRailsRegular
        timeLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 105)
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(130)
            $0.centerX.equalToSuperview()
        }
        timeLabel.isHidden = isHighlighted
        
        dateLabel.isHidden = isHighlighted
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
        
        tooltip = EasyTipView(contentView: contentView, preferences: preferences)
        
        DispatchQueue.main.async {
            self.tooltip.show(animated: true, forView: forView, withinSuperview: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.tooltip.dismiss()
            }
        }
    }
    
    @objc private func closeTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func adminPanelTapped() {
        if let documentID = AdminPanelHelper.shared.model[ReferenceKeys.photoID] as? String {
            adminPanelButton.isUserInteractionEnabled = false
            FirebaseManager.shared.firestore.collection(ReferenceKeys.categories).document(documentID).setData(AdminPanelHelper.shared.model, merge: true) { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    let alert = UIAlertController(title: "Ошибка блять", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(title: "Загружено блять", message: "молодец нахуй 🥳", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc private func hideTapped() {
        let newValue = !hideTimeButton.isHighlighted
        UserDefaults.standard.set(newValue, forKey: "hideTimeButton")
        hideTimeButton.isHighlighted = newValue
        timeLabel.isHidden = newValue
        dateLabel.isHidden = newValue
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


class AdminPanelHelper {
    static let shared = AdminPanelHelper()
    
    var model: [String: Any] = [:]
}
