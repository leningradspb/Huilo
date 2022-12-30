//
//  SettingsVC.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 26.12.2022.
//

import UIKit

class SettingsVC: GradientVC {
    private let logOutButton = VioletButton(text: "sing out 👋")
    private let deleteAccountButton = VioletButton(text: "delete account 🥹")

    override func viewDidLoad() {
        super.viewDidLoad()
        gradientContentView.addSubviews([logOutButton, deleteAccountButton])
        logOutButton.addTarget(self, action: #selector(singOut), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccount), for: .touchUpInside)
        
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

}
