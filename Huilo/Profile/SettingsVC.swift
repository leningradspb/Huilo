//
//  SettingsVC.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 26.12.2022.
//

import UIKit
import SafariServices

class SettingsVC: GradientVC {
    private let privacyButton = VioletButton(text: "privacy policy 🔐")
    private let logOutButton = VioletButton(text: "sign out 👋")
    private let deleteAccountButton = VioletButton(text: "delete account 😰")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(with: "settings")
        gradientContentView.addSubviews([logOutButton, deleteAccountButton, privacyButton])
        privacyButton.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
        logOutButton.addTarget(self, action: #selector(singOut), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccount), for: .touchUpInside)
        
        privacyButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Layout.leading)
            $0.trailing.equalToSuperview().offset(-Layout.leading)
            $0.bottom.equalTo(logOutButton.safeAreaLayoutGuide.snp.top).offset(-6)
        }
        
        logOutButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Layout.leading)
            $0.trailing.equalToSuperview().offset(-Layout.leading)
            $0.bottom.equalTo(deleteAccountButton.safeAreaLayoutGuide.snp.top).offset(-6)
        }
        
        deleteAccountButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Layout.leading)
            $0.trailing.equalToSuperview().offset(-Layout.leading)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-6)
        }
    }
    
    @objc private func singOut() {
        do {
            try FirebaseManager.shared.auth.signOut()
            let vc = AuthVC()
            vc.setupMainUI = { [weak self] in
                guard let self = self else { return }
            }
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    @objc private func deleteAccount() {
        FirebaseManager.shared.auth.currentUser?.delete(completion: { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.view.showMessage(text: error.localizedDescription, isError: true)
            } else {
                let vc = AuthVC()
                vc.setupMainUI = { [weak self] in
                    guard let self = self else { return }
                }
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false, completion: nil)
            }
        })
    }
    
    @objc private func privacyTapped() {
        let vc = SFSafariViewController(url: URL(string: "https://docs.google.com/document/d/1G4iy8Xom40GM0OzkmjRraas4Xbd4AW-wTmv0_fryeO8/edit?usp=sharing")!)
        
        vc.isModalInPresentation = true
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }

}
