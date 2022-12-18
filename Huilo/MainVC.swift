//
//  SearchVC.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 14.12.2022.
//

import UIKit
import SnapKit
import Kingfisher

class MainVC: GradientVC {
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var sections: [MainScreenModel.Section] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar(with: "main")
        setupTableView()
        loadData()
        
//        for family in UIFont.familyNames {
//            print("Family name " + family)
//            let fontNames = UIFont.fontNames(forFamilyName: family)
//
//            for font in fontNames {
//                print("    Font name: " + font)
//            }
//        }
    }
    
    private func setupTableView() {
        view.backgroundColor = .black
        gradientContentView.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        tableView.separatorColor = UIColor.white.withAlphaComponent(0.4)
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        tableView.register(RecommendationCell.self, forCellReuseIdentifier: RecommendationCell.identifier)
        tableView.estimatedSectionFooterHeight = 0
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func loadData() {
        FirebaseManager.shared.firestore.collection("Main").document("m").getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
//            print(snapshot?.data(), error)
//            snapshot?.data()
            
            guard let snapshotData = snapshot?.data() else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: snapshotData) else { return }
            
            do {
                let model = try JSONDecoder().decode(MainScreenModel.self, from: data)
                print(model)
                
                DispatchQueue.main.async {
                    self.sections = model.sections ?? []
                    self.tableView.reloadData()
                }
            } catch let error {
                print(error)
            }
            
        }
    }

}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sections.count {
            if sections[section].isRecommendation == true {
                return 1
            } else {
                let category = sections[section]
                return category.cells?.count ?? 0
            }
        }
        return 0
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section < sections.count {
//            let v = UIView()
//            let header = UILabel()
//            header.text = sections[section].name
//            v.addSubview(header)
//            header.textColor = .white
//            header.font = .systemFont(ofSize: 24, weight: .semibold)
//            
//            header.snp.makeConstraints {
//                $0.leading.equalToSuperview().offset(16)
//                $0.trailing.equalToSuperview()
//                $0.centerY.equalToSuperview()
//            }
//            return v
//        }
//        return nil
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 60
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < sections.count, sections[indexPath.section].isRecommendation == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: RecommendationCell.identifier, for: indexPath) as! RecommendationCell
            
            if indexPath.section < sections.count {
                if let recommendedCategories = sections[indexPath.section].recommendedCategories, indexPath.row < recommendedCategories.count {
                    cell.sectionCell = recommendedCategories[indexPath.row]
                    cell.showCategoriesVCbyName = { [weak self] categoryName in
                        guard let self = self else { return }
                        let vc = CategoryVC(categoryName: categoryName)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
            
            if indexPath.section < sections.count {
                let section = sections[indexPath.section]
                if let cells = section.cells, indexPath.row < cells.count {
                    cell.sectionCell = cells[indexPath.row]
                    cell.showFullScreenWallpaperVC = { [weak self] image in
                        guard let self = self else { return }
                        let vc = FullSizeWallpaperVC(image: image)
                        self.present(vc, animated: true)
                    }
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < sections.count, sections[indexPath.section].isRecommendation == true {
            return 306
        }
        return 286
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard conversations.count > 0 else { return }
//        showChat(by: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
}

// MARK: - Ячейка категории, содержащая коллекцию
class CategoryCell: UITableViewCell {
    private let collectionViewHeader = UILabel()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var showFullScreenWallpaperVC: ((UIImage)->())?
    
    var sectionCell: MainScreenModel.Section.Cell? {
        didSet {
            collectionViewHeader.text = sectionCell?.cellName
            collectionView.reloadData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        collectionView.backgroundColor = .clear
        collectionView.register(FullContentViewImageCollectionViewCell.self, forCellWithReuseIdentifier: FullContentViewImageCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: Layout.leading, bottom: 0, right: Layout.leading)
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 10
        }
        
        contentView.addSubviews([collectionViewHeader, collectionView])
        collectionViewHeader.textColor = .white
        collectionViewHeader.font = .futura(withSize: 18)
        
        collectionViewHeader.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(Layout.leading)
            $0.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(collectionViewHeader.snp.bottom).offset(10)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
// MARK: - Настойка коллекции для категории
extension CategoryCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionCell?.cellPhotos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FullContentViewImageCollectionViewCell.identifier, for: indexPath) as! FullContentViewImageCollectionViewCell
        if let photos = sectionCell?.cellPhotos, indexPath.row < photos.count {
            let photo = photos[indexPath.row]
            if let url = URL(string: photo) {
                cell.setImage(url: url)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 240)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("SLOT TAPPED IN collectionView CategoryCell")
        if let cell = collectionView.cellForItem(at: indexPath) as? FullContentViewImageCollectionViewCell {
            if let image = cell.recommendationImageView.image {
                showFullScreenWallpaperVC?(image)
            }
        }
    }
}

// MARK: - Ячейка рекомендаций, содержащая коллекцию
class RecommendationCell: UITableViewCell {
    private let collectionViewHeader = UILabel()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var showCategoriesVCbyName: ((String)->())?
    
    var sectionCell: MainScreenModel.Section.RecommendedCategory? {
        didSet {
            collectionViewHeader.text = sectionCell?.name
            collectionView.reloadData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        collectionView.backgroundColor = .clear
        collectionView.register(FullContentViewImageCollectionViewCell.self, forCellWithReuseIdentifier: FullContentViewImageCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: Layout.leading, bottom: 0, right: Layout.leading)
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 10
        }
        
        contentView.addSubviews([collectionViewHeader, collectionView])
        collectionViewHeader.textColor = .white
        collectionViewHeader.font = .futura(withSize: 18)
        
        collectionViewHeader.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(Layout.leading)
            $0.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(collectionViewHeader.snp.bottom).offset(6)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

// MARK: - Настойка коллекции для рекомендации
extension RecommendationCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photo = sectionCell?.photo, !photo.isEmpty {
            return 1
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FullContentViewImageCollectionViewCell.identifier, for: indexPath) as! FullContentViewImageCollectionViewCell
        if let photo = sectionCell?.photo, !photo.isEmpty {
            if let url = URL(string: photo) {
                cell.setImage(url: url)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 260, height: 275)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("SLOT TAPPED IN collectionView RecommendationCell")
        if let categoryName = sectionCell?.name {
            showCategoriesVCbyName?(categoryName)
        }
    }
}


class FullContentViewImageCollectionViewCell: UICollectionViewCell {
    let recommendationImageView = UIImageView()
    private let cornerRadius: CGFloat = 20
    private var isRecommendation: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setImage(url: URL) {
        recommendationImageView.kf.indicatorType = .activity
        recommendationImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = cornerRadius
        recommendationImageView.layer.cornerRadius = cornerRadius
        recommendationImageView.clipsToBounds = true
        recommendationImageView.contentMode = .scaleAspectFill
        
        contentView.addSubview(recommendationImageView)
        
        recommendationImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

struct MainScreenModel: Codable {
    let sections: [Section]?

    struct Section: Codable {
        let recommendedCategories: [RecommendedCategory]?
        let name: String?
        let cells: [Cell]?
        let isRecommendation: Bool?
        
        struct Cell: Codable {
            let cellName: String?
            let cellPhotos: [String]?
        }
        
        struct RecommendedCategory: Codable {
            let name, photo: String?
        }
    }
}
