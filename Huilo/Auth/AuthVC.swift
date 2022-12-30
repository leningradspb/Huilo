
import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import SnapKit
import FirebaseStorage

class AuthVC: GradientVC {
    private let girlImageView = UIImageView()
    private let welcomeLabel = FuturaLabel(text: "star you diving into AI world\ncreate awesome pictures🤩", fontSize: 40, color: .white, numberOfLines: 0)
    private var userID: String?
    
    private var isNeedCredentialsVC = false
    
    var setupMainUI:(()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAuthUI()
        setupSignInButton()
    }
    
    @objc private func showCredentialsVC() {
        guard let userID = userID else { return }
        let vc = CredentialsVC(userID: userID)
        vc.delegate = self
//        vc.showMainScreen = { [weak self] in
//            self?.showMainScreen()
//        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    private func setupAuthUI() {
        gradientContentView.addSubviews([girlImageView, welcomeLabel])
        view.backgroundColor = .black
        
        girlImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.equalToSuperview()
            $0.width.height.equalTo(200)
        }
        girlImageView.image = UIImage(named: "congratz")
        
        welcomeLabel.snp.makeConstraints {
            $0.top.equalTo(girlImageView.safeAreaLayoutGuide.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(Layout.leading)
            $0.trailing.equalToSuperview().offset(-Layout.leading)
        }
        welcomeLabel.textAlignment = .center
        
    }
    private func setupSignInButton() {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .white)
        button.addTarget(self, action: #selector(authTapped), for: .touchUpInside)
//        button.center = self.view.center
        gradientContentView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            make.height.equalTo(50)
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }

    @objc private func authTapped() {
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])

        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        return request
    }

    fileprivate var currentNonce: String?

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    
    private func showMainScreen() {
        setupMainUI?()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dismiss(animated: true) { [weak self] in
                self?.removeActivity()
            }
//        }
        
    }


}
// https://swiftsenpai.com/development/sign-in-with-apple-firebase-auth/
extension AuthVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)

            //                UserDefaults.standard.set(appleIDCredential.user, forKey: ConstantsAndNames.myID)

            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) {[weak self] (authResult, error) in
                guard let self = self else { return }
                if let error = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.view.showMessage(text: error.localizedDescription, isError: true)
                    }
                    return
                }
                
                guard let userID = authResult?.user.uid else {
                    DispatchQueue.main.async {
                        self.view.showMessage(text: "OOPS! authResult?.user.uid not found", isError: true)
                    }
                    return
                }

                print(authResult?.user.uid)
                print(appleIDCredential.user)
                self.userID = userID
//                KeyChainService.shared.set(key: KeyChainService.Keys.firebaseID, value: authResult?.user.uid ?? "")
//                KeyChainService.shared.set(key: KeyChainService.Keys.appleID, value: appleIDCredential.user)
//                KeyChainService.shared.set(key: KeyChainService.Keys.firebaseID, value: self.userID!)

//                if let givenName = appleIDCredential.fullName?.givenName {
////                    KeyChainService.shared.set(key: KeyChainService.Keys.givenName, value: givenName)
//                    self.isNeedCredentialsVC = true
//                }
//
//                if let familyName = appleIDCredential.fullName?.familyName {
////                    KeyChainService.shared.set(key: KeyChainService.Keys.familyName, value: familyName)
//                    self.isNeedCredentialsVC = true
//                }
//
//                guard let uid = authResult?.user.uid else {
//                    //TODO: show error
//                    return
//                }
//
//                if let givenName = appleIDCredential.fullName?.givenName, let familyName = appleIDCredential.fullName?.familyName {
//                }
                
                FirebaseManager.shared.firestore.collection(ReferenceKeys.users).document(userID).getDocument { snapshot, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.showMessage(text: error.localizedDescription, isError: true)
                        }
                        return
                    }
                    
                    if let data = snapshot?.data() {
                        self.showMainScreen()
                    } else {
                        self.createUserInFirestore(userID: userID, email: appleIDCredential.email)
                    }
                    
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
    private func createUserInFirestore(userID: String, email: String?) {
        var userData = [ReferenceKeys.userID: userID]
        if let email = email {
            userData[ReferenceKeys.email] = email
        }
        FirebaseManager.shared.firestore.collection(ReferenceKeys.users).document(userID).setData(userData) { error in
            if let err = error {
                self.removeActivity(withoutAnimation: true)
                self.view.showMessage(text: "Creation of new user failed, \(err.localizedDescription)", isError: true)
                return
            }
            self.removeActivity()
            self.showCredentialsVC()
        }
    }
}


extension AuthVC: CredentialsDelegate {
    func showMain() {
        showMainScreen()
    }
}
