//
//  CategoryVC.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 18.12.2022.
//

import UIKit
import Firebase

class CategoryVC: GradientVC {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let minimumInteritemSpacingForSection: CGFloat = 12
    private let numberOfCollectionViewColumns: CGFloat = 2
    private var lastDocument: DocumentSnapshot?
    private let limit = 20
    private var isNeedFetch = true
    private var result: [CategoryModel] = []
    
    private let categoryName: String
    init(categoryName: String) {
        self.categoryName = categoryName
        super.init(nibName: nil, bundle: nil)
        setupUI()
        loadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        gradientContentView.addSubview(collectionView)
        modalPresentationStyle = .fullScreen
        setupNavigationBar(with: categoryName)
        
        collectionView.backgroundColor = .clear
        collectionView.register(FullContentViewImageCollectionViewCell.self, forCellWithReuseIdentifier: FullContentViewImageCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 20, left: Layout.leading, bottom: 20, right: Layout.leading)
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 10
        }
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func loadData() {
        if let lastDocument = self.lastDocument {
            FirebaseManager.shared.firestore.collection(ReferenceKeys.categories).whereField(ReferenceKeys.filter, isEqualTo: categoryName).order(by: ReferenceKeys.timeOfCreation, descending: true).limit(to: limit).start(afterDocument: lastDocument).getDocuments { [weak self] snapshot, error in
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
                        let model = try JSONDecoder().decode(CategoryModel.self, from: data)
                        print(model)
                        
                        DispatchQueue.main.async {
                            self.result.append(model)
                            self.lastDocument = documents.last
                            self.collectionView.reloadData()
                        }
                    } catch let error {
                    }
                }
            }
        } else {
            FirebaseManager.shared.firestore.collection(ReferenceKeys.categories).whereField(ReferenceKeys.filter, isEqualTo: categoryName).order(by: ReferenceKeys.timeOfCreation, descending: true).limit(to: limit).getDocuments { [weak self] snapshot, error in
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
                        let model = try JSONDecoder().decode(CategoryModel.self, from: data)
                        print(model)
                        
                        DispatchQueue.main.async {
                            self.result.append(model)
                            self.lastDocument = documents.last
                            self.collectionView.reloadData()
                        }
                    } catch let error {
                    }
                }
            }
        }
    }
}

extension CategoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        result.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FullContentViewImageCollectionViewCell.identifier, for: indexPath) as! FullContentViewImageCollectionViewCell
        if indexPath.row < result.count {
            let photo = result[indexPath.row].photo
            if let url = URL(string: photo) {
                cell.setImage(url: url)
            }
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
        print("TAPPED IN collectionView CategoryVC")
        if let cell = collectionView.cellForItem(at: indexPath) as? FullContentViewImageCollectionViewCell {
            if let image = cell.recommendationImageView.image {
                let vc = FullSizeWallpaperVC(image: image)
                self.present(vc, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard result.count > 0, isNeedFetch else { return }
         if indexPath.row == result.count - 1 {
             loadData()
         }
    }
}

struct CategoryModel: Codable {
    let photo, userID, photoID: String
    let prompt, negative_prompt, filter: String?
    let timeOfCreation: Double?
}
