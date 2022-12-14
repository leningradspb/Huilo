//
//  ViewController.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 14.12.2022.
//

import UIKit
import Kingfisher
import Firebase

class GeneratorVC: GradientVC {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let sendMessageButton = UIButton()
    private let messageTextView = UITextView()
    private var filters: [GeneratorFilterModel.Filter] = []
    private var userSelectedFilters: [GeneratorFilterModel.Filter] = []
    private let placeholder = "Enter your prompt"
    private let minimumInteritemSpacingForSection: CGFloat = 12
    private let numberOfCollectionViewColumns: CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(with: "generator")
        setupUI()
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAvoidingKeyboard()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAvoidingKeyboard()
    }
    
    private func setupUI() {
        gradientContentView.addSubviews([collectionView, messageTextView, sendMessageButton])
  
        collectionView.backgroundColor = .clear
        collectionView.register(GeneratorFiltersCollectionViewCell.self, forCellWithReuseIdentifier: GeneratorFiltersCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: Layout.leading, bottom: Layout.leading, right: Layout.leading)
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 10
        }
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        messageTextView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        
        sendMessageButton.snp.makeConstraints {
            $0.width.height.equalTo(30)
            $0.bottom.equalTo(messageTextView.snp.bottom).offset(-5)
            $0.trailing.equalTo(messageTextView.snp.trailing).offset(-10)
        }
        let sendImage = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: iconConfig)
        sendMessageButton.setImage(sendImage, for: .normal)
        sendMessageButton.tintColor = .violet
        sendMessageButton.backgroundColor = .white
        sendMessageButton.layer.cornerRadius = 15
        sendMessageButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        
        messageTextView.delegate = self
        messageTextView.backgroundColor = .black
        messageTextView.layer.cornerRadius = 10
        messageTextView.layer.borderWidth = 2
        messageTextView.layer.borderColor = UIColor.white.cgColor
        messageTextView.text = placeholder
        messageTextView.textColor = .white
        messageTextView.autocorrectionType = .no
        messageTextView.keyboardAppearance = .dark
        messageTextView.isScrollEnabled = false
        messageTextView.font = UIFont.systemFont(ofSize: 16)
        messageTextView.returnKeyType = .search
        messageTextView.textContainerInset = UIEdgeInsets(top: 13, left: 10, bottom: 10, right: 40)
    }
    
    private func loadData() {
        FirebaseManager.shared.firestore.collection("Generator").document("filters").getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let snapshotData = snapshot?.data() else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: snapshotData) else { return }
            
            do {
                let model = try JSONDecoder().decode(GeneratorFilterModel.self, from: data)
                print(model)
                
                DispatchQueue.main.async {
                    self.filters = model.filters
                    self.filters.sort(by: {$0.name ?? "" < $1.name ?? ""})
                    self.collectionView.reloadData()
                }
            } catch let error {
                print(error)
            }
            
        }
    }
    
    @objc private func hideKeyboard() {
        print("hideKeyboard")
        view.endEditing(true)
    }
    
    @objc private func sendTapped() {
        print("sendMessage()")
        guard messageTextView.text != placeholder && !messageTextView.text.isEmpty else {return}
        hideKeyboard()
        showActivity(animation: ActivityView.Animations.plane)
        let key = "BACIke21YSH6KHkQ77sZIZBNZVJZnR4PAdNYYLz4JITelaJj0HmKOfE1mV7C"
        var prompts: [String] = []
        var negativePrompts: [String] = []
        userSelectedFilters.forEach {
            if let prompt = $0.prompt {
                prompts.append(prompt)
            }
            
            if let negative = $0.negativePrompt {
                negativePrompts.append(negative)
            }
        }
        
        let isPaperCut = userSelectedFilters.contains(where: {$0.name == "paper cut"})
        let filterPrompt = prompts.joined(separator: ", ")
        let filterNegativePrompts = negativePrompts.joined(separator: ", ")
        let prompt = messageTextView.text + " " + filterPrompt
        let model_id: String = isPaperCut ? "midjourney-papercut" : "midjourney"
        let requestModel = StableDiffusionFilterRequest(key: key, prompt: prompt, negative_prompt: filterNegativePrompts, model_id: model_id)
        
        APIService.requestPhotoBy(filter: requestModel) { [weak self] result, error in
            guard let self = self else { return }
            print(result, error)
            DispatchQueue.main.async {
                if let status = result?.status, status == "success", let output = result?.output?.first, let url = URL(string: output) {
                    let cacheImageView = UIImageView()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        cacheImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))]) { [weak self] r in
                            guard let self = self else { return }
                            switch r {
                            case .success(let response):
                                print(response)
                                self.writeInStorageAndUserHistory(with: cacheImageView.image)
                                let vc = FullSizeWallpaperVC(image: response.image)
                                self.removeActivity { [weak self] in
                                    self?.present(vc, animated: true)
                                }
                            case .failure(let error):
                                print(error)
                                self.removeActivity { [weak self] in
                                    guard let self = self else { return }
                                    print("completion removeActivity error in kingfisher")
                                    let modal = ErrorModal(errorText: "something went wrong???? we are terrible sorry???? if you see that message at first time please try again. if you see few times in a row please try later or change your prompt????")
                                    modal.tryAgainCompletion = { [weak self] in
                                        guard let self = self else { return }
                                        self.sendTapped()
                                    }
                                    self.window.addSubview(modal)
                                }
                            }
                        }
                    }
                } else {
                    self.removeActivity { [weak self] in
                        guard let self = self else { return }
                        print("completion removeActivity error")
                        let modal = ErrorModal(errorText: "something went wrong???? we are terrible sorry???? if you see that message at first time please try again. if you see few times in a row please try later or change your prompt????")
                        modal.tryAgainCompletion = { [weak self] in
                            guard let self = self else { return }
                            self.sendTapped()
                        }
                        self.window.addSubview(modal)
                    }
                }
            }
        }
    }
    
    private func writeInStorageAndUserHistory(with image: UIImage?) {
        if let uploadData = image?.pngData(), let id = myID {
            let uniqPath = UUID().uuidString
            FirebaseManager.shared.storage.child(ReferenceKeys.usersHistory).child(id).child(ReferenceKeys.photos).child(uniqPath).putData(uploadData, metadata: nil) { [weak self] metadata, error in
                guard let self = self else { return }
                
                if let error = error {
//                    DispatchQueue.main.async {
//                        self.removeActivity()
//                        self.view.showMessage(text: error.localizedDescription)
//                    }
                } else {
                    FirebaseManager.shared.storage.child(ReferenceKeys.usersHistory).child(id).child(ReferenceKeys.photos).child(uniqPath).downloadURL { [weak self] url, error in
                        if let error = error {
//                            DispatchQueue.main.async {
//                                self?.view.showMessage(text: error.localizedDescription)
//                            }
                        } else {
                            if let url = url?.absoluteString {
                                FirebaseManager.shared.firestore.collection(ReferenceKeys.usersHistory).document(id).getDocument { [weak self] snapshot, error in
                                    guard let self = self, let id = self.myID else { return }
                                    let randomKey = UUID().uuidString
                                    print(randomKey)
                                    let prompt: String = self.messageTextView.text
                                    let filter: String = self.userSelectedFilters.compactMap {$0.name}.joined(separator: ", ")
                                    let model: [String: Any] = [ReferenceKeys.photo: url, ReferenceKeys.prompt: prompt, ReferenceKeys.filter: filter, ReferenceKeys.userID: id, ReferenceKeys.timeOfCreation: Date().currentTimeMillis(), ReferenceKeys.photoID: randomKey, ReferenceKeys.likeCount: 0]
                                    FirebaseManager.shared.firestore.collection(ReferenceKeys.usersHistory).document(randomKey).setData(model)
                                    AdminPanelHelper.shared.model = model
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension GeneratorVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GeneratorFiltersCollectionViewCell.identifier, for: indexPath) as! GeneratorFiltersCollectionViewCell
        if indexPath.row < filters.count {
            let filter = filters[indexPath.row]
            cell.updateWith(generatorFilterModel: filter, isSelected: userSelectedFilters.contains(where: {$0.name == filter.name}))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.bounds.width - (Layout.leading * 2) - minimumInteritemSpacingForSection) / numberOfCollectionViewColumns, height: view.bounds.height / 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        minimumInteritemSpacingForSection
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        minimumInteritemSpacingForSection
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < filters.count {
            let filter = filters[indexPath.row]
            if userSelectedFilters.contains(where: { $0.name == filter.name }) {
                userSelectedFilters.removeAll(where: { $0.name == filter.name })
            } else {
                userSelectedFilters.append(filter)
            }
            collectionView.reloadItems(at: [indexPath])
        }
        
    }
}

extension GeneratorVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            messageTextView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            messageTextView.text = placeholder
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            sendTapped()
        }
        return true
    }
}


struct GeneratorFilterModel: Codable {
    let filters: [Filter]
    
    struct Filter: Codable {
        let name: String?
        let imageURL: String?
        let prompt: String?
        let negativePrompt: String?
    }
}

class GeneratorFiltersCollectionViewCell: UICollectionViewCell {
    private let filterImageView = UIImageView()
    private let filterNameLabel = UILabel()
    private let cornerRadius: CGFloat = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateWith(generatorFilterModel: GeneratorFilterModel.Filter, isSelected: Bool) {
        contentView.backgroundColor = isSelected ? .violet : .clear
        filterImageView.kf.indicatorType = .activity
        (filterImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = .white
        if let urlString = generatorFilterModel.imageURL, let url = URL(string: urlString) {
            filterImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        }
        filterNameLabel.text = generatorFilterModel.name
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = cornerRadius
        filterImageView.roundOnlyTopCorners(radius: cornerRadius)
        filterImageView.clipsToBounds = true
        filterImageView.contentMode = .scaleAspectFill
        
        contentView.addSubviews([filterImageView, filterNameLabel])
        
        filterImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(contentView.bounds.height * 0.6)
        }
        
        filterNameLabel.textAlignment = .center
        filterNameLabel.numberOfLines = 2
        filterNameLabel.textColor = .white
        filterNameLabel.font = .futura(withSize: 16)
        filterNameLabel.snp.makeConstraints {
            $0.top.equalTo(filterImageView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().offset(-4)
        }
    }
}

class APIService {
    
}

extension APIService {
    static func requestPhotoBy(filter: StableDiffusionFilterRequest, completion: @escaping (_ paymentHistory: StableDiffusionResponse?, _ error: Error?) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://stablediffusionapi.com/api/v4/dreambooth")!)
        request.configure(.post)
        
        do {
            let data = try JSONEncoder().encode(filter)
            request.httpBody = data
            print(data)
            print(String(data: data, encoding: .utf8) as Any)
        } catch {
            print(error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("---------------------------------")
            print("Server response:")
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("DATA NOT FOUND!!! ????")
                completion(nil, error)
                return
            }
            print(String(data: data, encoding: .utf8) as Any)
//            print("JSON String: \(String(data: data, encoding: .utf8))")
            do {
                let history = try JSONDecoder().decode(StableDiffusionResponse.self, from: data)
                print(history as Any)
                completion(history, nil)
            } catch {
                print(error)
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}

struct StableDiffusionResponse: Codable {
    let status: String?
    let output: [String]?
}

struct StableDiffusionFilterRequest: Codable {
    let key: String
    let prompt: String
    let negative_prompt: String?
    var model_id: String = "midjourney"
    let guidance_scale: Int = 8
    let num_inference_steps: Int = 25
    let width: Int = 400
    let height: Int = 840
    let samples: Int = 1
}

extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension URLRequest {
    mutating func configure(
        _ method: HttpMethod,
        _ parameters: [String: Any?]? = nil
    ) {
        self.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        self.httpMethod = method.rawValue
        if let strongParameters = parameters, !strongParameters.isEmpty {
            self.httpBody = try? JSONSerialization.data(withJSONObject: strongParameters)
        }
    }
}
enum HttpMethod: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
}
