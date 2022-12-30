

import UIKit
import FirebaseFirestore
import FirebaseStorage

protocol CredentialsDelegate: AnyObject {
    func showMain()
}

class CredentialsVC: GradientVC {
    private let imageView = UIImageView()
    private let textView = EmojiTextView()
    private let mainStack = VerticalStackView(spacing: 10)
    private let nameOrNickTextField = InsetTextField()
    private let createUserButton = VioletButton()
    private var typedNickName: String?
    
    weak var delegate: CredentialsDelegate?
    
    private let userID: String
    init(userID: String) {
        self.userID = userID
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startAvoidingKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopAvoidingKeyboard()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        gradientContentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.width.height.equalTo(200)
            $0.centerX.equalToSuperview()
        }
        gradientContentView.addSubview(textView)
        
        textView.snp.makeConstraints {
            $0.edges.equalTo(imageView.snp.edges)
        }
        
        textView.backgroundColor = .clear
        textView.tintColor = .clear
        textView.allowsEditingTextAttributes = true
        textView.delegate = self
        setPersonIcon()
        setupNameOrNick()
        setupCreateUserButton()
    }
    
    private func setPersonIcon() {
        let iconConfig = UIImage.SymbolConfiguration(scale: .large)
        let personIcon = UIImage(systemName: "person.fill.viewfinder", withConfiguration: iconConfig)
        imageView.image = personIcon
        imageView.tintColor = .white
    }
    
    private func setupNameOrNick() {
        let nameOrNickLabel = UILabel()
        nameOrNickLabel.text = "name or nick"
        nameOrNickLabel.textColor = .white
        nameOrNickLabel.font = .futura(withSize: 25)
        nameOrNickLabel.textAlignment = .center
        //$0.top.equalTo(imageView.snp.bottom).offset(20)
        view.addSubviews([nameOrNickLabel, nameOrNickTextField])
        nameOrNickLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.trailing.equalToSuperview().offset(-20)
        }
        
        nameOrNickTextField.snp.makeConstraints {
            $0.top.equalTo(nameOrNickLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(50)
        }
        nameOrNickTextField.backgroundColor = .commonGrey.withAlphaComponent(0.3)
        nameOrNickTextField.tintColor = .white
        nameOrNickTextField.textColor = .white
        nameOrNickTextField.layer.cornerRadius = 10
        nameOrNickTextField.delegate = self
        nameOrNickTextField.font = .futura(withSize: 18)
        nameOrNickTextField.textAlignment = .center
        nameOrNickTextField.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        setupTapRecognizer(for: view, action: #selector(hideKeyboard))
    }
    
    
    private func setupCreateUserButton() {
        view.addSubview(createUserButton)
        createUserButton.setTitle("Let's go 🚀", for: .normal)
        createUserButton.setTitle("Let's go 🚀", for: .selected)
        createUserButton.titleLabel?.font = .futura(withSize: 25)
        createUserButton.isEnabled = false
        createUserButton.addTarget(self, action: #selector(createUser), for: .touchUpInside)
        
        createUserButton.snp.makeConstraints {
//            $0.top.equalTo(mainStack.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(52)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
    }
    
    private func checkIsCreateUserEnabled() {
        if let text = nameOrNickTextField.text {
            createUserButton.isEnabled = (text.count > 1)
        } else {
            createUserButton.isEnabled = false
        }
    }
    
    
    private func showError() {
        view.showMessage(text: "choose memoji for your avatar")
        setPersonIcon()
    }
    
    @objc private func textFieldDidChanged() {
        checkIsCreateUserEnabled()
    }
    
    @objc private func createUser() {
        print("try create user")
        showActivity(animation: ActivityView.Animations.plane)
        uploadImage(completion: { [weak self] imageUrl in
            guard let self = self else { return }
      
            FirebaseManager.shared.firestore.collection(ReferenceKeys.users).document(self.userID).getDocument { snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.showMessage(text: error.localizedDescription, isError: true)
                    }
                    return
                }
                
                guard var data = snapshot?.data() else { return }
                data[ReferenceKeys.nickName] = self.typedNickName
                data[ReferenceKeys.profileImageURL] = imageUrl
                
                FirebaseManager.shared.firestore.collection(ReferenceKeys.users).document(self.userID).setData(data) { error in
                    if let err = error {
                        self.removeActivity()
                        self.view.showMessage(text: "Creation of new user failed")
                        return
                    }
                    self.removeActivity()
                    self.dismiss(animated: true, completion: nil)
                    self.delegate?.showMain()
                }
            }
        })
    }
    
    private func uploadImage(completion: @escaping ((String)->())) {
        let key = userID // ключ из эпл
        let child = "\(key).png"
        if let uploadData = imageView.image?.pngData() {
            FirebaseManager.shared.storage.child(ReferenceKeys.profileImageURL).child(child).putData(uploadData, metadata: nil) { [weak self] metadata, error in
                guard let self = self else { return }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.removeActivity()
                        self.view.showMessage(text: error.localizedDescription)
                    }
                } else {
                    // TODO клоужер для экрана с эплом
                    //                    self.view.showMessage(text: "Изображение загрузилось", isError: false)
                    FirebaseManager.shared.storage.child(ReferenceKeys.profileImageURL).child(child).downloadURL { [weak self] url, error in
                        if let error = error {
                            DispatchQueue.main.async {
                                self?.view.showMessage(text: error.localizedDescription)
                            }
                        } else {
                            if let url = url?.absoluteString {
                                completion(url)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private func hideKeyboard() {
        nameOrNickTextField.endEditing(true)
    }
}

extension CredentialsVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        let range = NSRange(location: 0, length: textView.attributedText.length)
        if !textView.attributedText.containsAttachments(in: range) && !textView.text.isSingleEmoji {
            textView.endEditing(true)
            showError()
            return
        }
        textView.endEditing(true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.attributedText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: textView.attributedText.length), options: [], using: {(value,range,_) -> Void in
                        if (value is NSTextAttachment) {
                            let attachment: NSTextAttachment? = (value as? NSTextAttachment)
                            var image: UIImage?
         
                            if ((attachment?.image) != nil) {
                                image = attachment?.image
                            } else {
                                image = attachment?.image(forBounds: (attachment?.bounds)!, textContainer: nil, characterIndex: range.location)
                            }
         
                            guard let pasteImage = image else { return }
         
                            guard let pngData = pasteImage.pngData() else { return }
                            guard let pngImage = UIImage(data: pngData) else { return }
                            imageView.image = pngImage
                            textView.text.removeAll()
                            return
                        } else {
                            imageView.image = textView.text.textToImage()
                            textView.text.removeAll()
                        }
                    })
    }
}

class EmojiTextView: UITextView {

       // required for iOS 13
       override var textInputContextIdentifier: String? { "" } // return non-nil to show the Emoji keyboard ¯\_(ツ)_/¯

        override var textInputMode: UITextInputMode? {
           
            for mode in UITextInputMode.activeInputModes {
                if mode.primaryLanguage == "emoji" {
                    return mode
                }
            }
            return nil
        }
    }


extension CredentialsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        typedNickName = textField.text
        checkIsCreateUserEnabled()
    }
}
