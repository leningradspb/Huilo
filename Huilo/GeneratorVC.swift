//
//  ViewController.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 14.12.2022.
//

import UIKit

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
        view.addSubviews([collectionView, messageTextView, sendMessageButton])
  
        collectionView.backgroundColor = .clear
        collectionView.register(GeneratorFiltersCollectionViewCell.self, forCellWithReuseIdentifier: GeneratorFiltersCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: Layout.leading, bottom: 0, right: Layout.leading)
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 10
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
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
            messageTextView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            messageTextView.text = placeholder
            messageTextView.textColor = .darkGray
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
