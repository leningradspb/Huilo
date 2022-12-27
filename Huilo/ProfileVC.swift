//
//  ProfileVC.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 26.12.2022.
//

import UIKit

class ProfileVC: GradientVC {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let minimumInteritemSpacingForSection: CGFloat = 12
    private let numberOfCollectionViewColumns: CGFloat = 2
    private let refreshControl = UIRefreshControl()
    private var usersHistory: [UserHistory] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadData(isInitial: true)
    }
    
    private func setupUI() {
        setupNavigationBar(with: "profile")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear", withConfiguration: iconConfig), style: .plain, target: self, action: #selector(settingsTapped))
        gradientContentView.addSubviews([collectionView])
  
        collectionView.backgroundColor = .clear
        collectionView.register(FullContentViewImageCollectionViewCell.self, forCellWithReuseIdentifier: FullContentViewImageCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.showsVerticalScrollIndicator = false
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: Layout.leading, bottom: Layout.leading, right: Layout.leading)
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 10
        }
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func loadData(isInitial: Bool) {
        guard let myID = myID else {return}
        
        FirebaseManager.shared.firestore.collection(ReferenceKeys.usersHistory).document(myID).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let snapshotData = snapshot?.data() else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: snapshotData) else { return }
            
            do {
                let model = try JSONDecoder().decode(UserHistoryResults.self, from: data)
                print(model)
                
                DispatchQueue.main.async {
                    if isInitial {
                        self.usersHistory = model.results ?? []
                    } else {
                        model.results?.forEach {
                            self.usersHistory.append($0)
                        }
                    }
                    self.collectionView.reloadData()
                }
            } catch let error {
            }
              
        }
    }
    
    @objc private func refresh() {
        loadData(isInitial: true)
        refreshControl.endRefreshing()
    }
                                                            
    @objc private func settingsTapped() {
        let vc = SettingsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        usersHistory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FullContentViewImageCollectionViewCell.identifier, for: indexPath) as! FullContentViewImageCollectionViewCell
        let row = indexPath.row
        if row < usersHistory.count, let photo = usersHistory[row].photo, let url = URL(string: photo) {
            cell.setImage(url: url)
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
//        if indexPath.row < filters.count {
//
//        }
        
    }
}


struct UserHistoryResults: Codable {
    let results: [UserHistory]?
}

struct UserHistory: Codable {
    let filter, photo, prompt: String?
}
