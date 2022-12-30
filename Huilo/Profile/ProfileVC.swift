//
//  ProfileVC.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 26.12.2022.
//

import UIKit
import Firebase
import Kingfisher

class ProfileVC: GradientVC {
//    private let dispatchGroup = DispatchGroup()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let minimumInteritemSpacingForSection: CGFloat = 12
    private let numberOfCollectionViewColumns: CGFloat = 2
    private let refreshControl = UIRefreshControl()
    private var usersHistory: [UserHistory] = []
    private var userModel: UserModel?
    private var lastDocument: DocumentSnapshot?
    private let limit = 20
    private var isNeedFetch = true
    private var headerImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadProfile()
        loadData()
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
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.identifier)
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
    
    private func loadProfile() {
        guard let myID = myID else {return}
//        dispatchGroup.enter()
        FirebaseManager.shared.firestore.collection(ReferenceKeys.users).document(myID).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let snapshotData = snapshot?.data() else {
//                self.dispatchGroup.leave()
                return }
            guard let data = try? JSONSerialization.data(withJSONObject: snapshotData) else {
//                self.dispatchGroup.leave()
                return }
            
            do {
                let model = try JSONDecoder().decode(UserModel.self, from: data)
                print(model)
                self.userModel = model
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
//                self.dispatchGroup.leave()
            } catch let error {
                print(error)
//                self.dispatchGroup.leave()
            }
        }
    }
    /// здесь идет поиск по всем документам по полю, где userID равен моему ID. Так устроена паджинация в Firestore. первая версия была добавление в массив всех фото историй, но в масиве я не нашел паджинацию. начальный код внизу страницы.
    /// Если есть lastDocument то делаем паджинацию
    private func loadData() {
        guard let myID = myID else {return}
        if let lastDocument = self.lastDocument {
            FirebaseManager.shared.firestore.collection(ReferenceKeys.usersHistory).whereField("userID", isEqualTo: myID).order(by: ReferenceKeys.timeOfCreation, descending: true).limit(to: limit).start(afterDocument: lastDocument).getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                print(snapshot?.documents.count, error)
                if let error = error {
                    self.view.showMessage(text: error.localizedDescription, isError: true)
                    return
                }
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    self.isNeedFetch = false
                    return
                }

                documents.forEach {
                    let snapshotData = $0.data()
                    guard let data = try? JSONSerialization.data(withJSONObject: snapshotData) else { return }
                    do {
                        let model = try JSONDecoder().decode(UserHistory.self, from: data)
                        print(model)
                        
                        DispatchQueue.main.async {
                            self.usersHistory.append(model)
                            self.lastDocument = documents.last
                            self.collectionView.reloadData()
                        }
                    } catch let error {
                    }
                }
            }
        } else {
            FirebaseManager.shared.firestore.collection(ReferenceKeys.usersHistory).whereField("userID", isEqualTo: myID).order(by: ReferenceKeys.timeOfCreation, descending: true).limit(to: limit).getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                print(snapshot?.documents.count, error)
                if let error = error {
                    self.view.showMessage(text: error.localizedDescription, isError: true)
                    return
                }
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    self.isNeedFetch = false
                    return
                }

                documents.forEach {
                    let snapshotData = $0.data()
                    guard let data = try? JSONSerialization.data(withJSONObject: snapshotData) else { return }
                    do {
                        let model = try JSONDecoder().decode(UserHistory.self, from: data)
                        print(model)
                        
                        DispatchQueue.main.async {
                            self.usersHistory.append(model)
                            self.lastDocument = documents.last
                            self.collectionView.reloadData()
                        }
                    } catch let error {
                    }
                }
            }
        }
    }
    
    @objc private func refresh() {
        usersHistory.removeAll()
        lastDocument = nil
        isNeedFetch = true
        loadData()
        refreshControl.endRefreshing()
    }
                                                            
    @objc private func settingsTapped() {
        let vc = SettingsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func headerTapped() {
        print("headerTapped")
        guard let userID = myID, let headerImage = headerImage else {return}
        let vc = EditProfileVC(userID: userID, image: headerImage, nickName: userModel?.nickName)
        vc.update = {  [weak self] in
            guard let self = self else { return }
            self.headerImage = nil
            self.userModel = nil
            self.loadProfile()
            self.refresh()
        }
        present(vc, animated: true, completion: nil)
    }
}

extension ProfileVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.identifier, for: indexPath) as! ProfileHeader
        if let urlString = userModel?.profileImageURL, let url = URL(string: urlString) {
            header.configure(with: url, nickName: userModel?.nickName)
            header.imageClosure = { [weak self] image in
                guard let self = self else { return }
                self.headerImage = image
            }
        }
        
        if header.gestureRecognizers == nil {
            setupTapRecognizer(for: header, action: #selector(headerTapped))
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.bounds.width, height: 280)
    }
    
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
        return CGSize(width: (view.bounds.width - (Layout.leading * 2) - minimumInteritemSpacingForSection) / numberOfCollectionViewColumns, height: view.bounds.height / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        minimumInteritemSpacingForSection
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        minimumInteritemSpacingForSection
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("TAPPED IN collectionView ProfileVC")
        if let cell = collectionView.cellForItem(at: indexPath) as? FullContentViewImageCollectionViewCell {
            if let image = cell.recommendationImageView.image {
                let vc = FullSizeWallpaperVC(image: image)
                self.present(vc, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard usersHistory.count > 0, isNeedFetch else { return }
         if indexPath.row == usersHistory.count - 1 {
             loadData()
         }
    }
}

struct UserHistory: Codable {
    let filter, photo, prompt, userID: String?
}

struct UserModel: Codable {
    let email, nickName, profileImageURL, userID: String?
}

final class ProfileHeader: UICollectionReusableView {
    private let imageView = UIImageView()
    private let nameOrNickLabel = UILabel()
    private let historyLabel = UILabel()
    var imageClosure: ((UIImage)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        addSubviews([imageView, nameOrNickLabel, historyLabel])
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(180)
        }
//        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        nameOrNickLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(50)
        }
        
        historyLabel.snp.makeConstraints {
            $0.top.equalTo(nameOrNickLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview()
        }
        historyLabel.text = "history"
        historyLabel.font = .futura(withSize: 20)
        historyLabel.textColor = .white
       
        nameOrNickLabel.font = .futura(withSize: 25)
        nameOrNickLabel.textAlignment = .center
        nameOrNickLabel.textColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with url: URL, nickName: String?) {
        imageView.kf.indicatorType = .activity
        (imageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = .white
        imageView.kf.setImage(with: url, options: [.transition(.fade(0.2))]) {[weak self] result in
            switch result {
            case .success(let r):
                if let image = self?.imageView.image {
                    self?.imageClosure?(image)
                }
            case .failure(_):
                break
            }
        }
        nameOrNickLabel.text = nickName
    }
}



//private func loadLeaderboard(limit: Int) {
//    print(limit, lastDocument?.data())
//    if let lastDocument = self.lastDocument {
//        FirebaseManager.shared.firestore.collection(ReferenceKeys.users).order(by: ReferenceKeys.balance, descending: true).limit(to: limit).start(afterDocument: lastDocument).getDocuments { [weak self] snapshot, error in
//            guard let self = self else { return }
//            if let error = error {
//                self.view.showMessage(text: error.localizedDescription, isError: true)
//                return
//            }
//            guard let documents = snapshot?.documents, !documents.isEmpty else {
//                self.isNeedFetch = false
//                return
//            }
//
//            documents.forEach {
//                let model = UserModel(from: $0.data())
//                self.leaderboard.append(model)
//            }
//            self.lastDocument = documents.last
//            self.tableView.reloadData()
//        }
//    } else {
//        FirebaseManager.shared.firestore.collection(ReferenceKeys.users).order(by: ReferenceKeys.balance, descending: true).limit(to: limit).getDocuments { [weak self] snapshot, error in
//            guard let self = self else { return }
//            if let error = error {
//                self.view.showMessage(text: error.localizedDescription, isError: true)
//                return
//            }
////            guard let data = snapshot?.data() else { return }
//            guard let documents = snapshot?.documents, !documents.isEmpty else {
//                self.isNeedFetch = false
//                return
//            }
//
//            documents.forEach {
//                let model = UserModel(from: $0.data())
//                self.leaderboard.append(model)
//            }
//            self.lastDocument = documents.last
//            self.tableView.reloadData()
//        }
//    }
//}
//
//func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//    guard leaderboard.count > 0, isNeedFetch else { return }
//    if indexPath.row == leaderboard.count - 1 {
//        loadLeaderboard(limit: limit)
//    }
//}

//        FirebaseManager.shared.firestore.collection(ReferenceKeys.usersHistory).document(myID).getDocument { [weak self] snapshot, error in
//            guard let self = self else { return }
//            guard let snapshotData = snapshot?.data() else { return }
//            guard let data = try? JSONSerialization.data(withJSONObject: snapshotData) else { return }
//
//            do {
//                let model = try JSONDecoder().decode(UserHistoryResults.self, from: data)
//                print(model)
//
//                DispatchQueue.main.async {
//                    if isInitial {
//                        self.usersHistory = model.results ?? []
//                    } else {
//                        model.results?.forEach {
//                            self.usersHistory.append($0)
//                        }
//                    }
//                    self.collectionView.reloadData()
//                }
//            } catch let error {
//            }
//
//        }
