//
//  SearchVC.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 14.12.2022.
//

import UIKit
import SnapKit
import Kingfisher

class SearchVC: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var sections: [MainScreenModel.Section] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTableView()
        loadData()
    }

    private func setupNavigationBar() {
        navigationItem.title = "Recommendations"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupTableView() {
        view.backgroundColor = .black
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        tableView.separatorColor = UIColor.white.withAlphaComponent(0.4)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        tableView.register(RecommendationCell.self, forCellReuseIdentifier: RecommendationCell.identifier)
        
        view.addSubview(tableView)
        
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

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sections.count {
            let category = sections[section]
            return category.cells?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section < sections.count {
            let v = UIView()
            let header = UILabel()
            header.text = sections[section].name
            v.addSubview(header)
            header.textColor = .white
            header.font = .systemFont(ofSize: 24, weight: .semibold)
            
            header.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(16)
                $0.trailing.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
            return v
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: RecommendationCell.identifier, for: indexPath) as! RecommendationCell
            
            if indexPath.section < sections.count {
                let section = sections[indexPath.section]
                if let cells = section.cells, indexPath.row < cells.count {
                    cell.photos = cells[indexPath.row].cellPhotos ?? []
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
            
            if indexPath.section < sections.count {
                let section = sections[indexPath.section]
                if let cells = section.cells, indexPath.row < cells.count {
                    print(section.name)
                    cell.textLabel?.textColor = .green
                    cell.textLabel?.text = cells[indexPath.row].cellName
                    cell.contentView.backgroundColor = .orange
                }
                //                let model = conversations[indexPath.row]
                //                cell.updateConversationCell(with: model)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 280 : 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard conversations.count > 0 else { return }
//        showChat(by: indexPath.row)
    }
}


class CategoryCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        contentView.backgroundColor = .black
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
    }
}

class RecommendationCell: UITableViewCell {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var photos: [String] = [] {
        didSet {
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
        backgroundColor = .black
        contentView.backgroundColor = .black
        selectionStyle = .none
        collectionView.backgroundColor = .black
        collectionView.register(RecommendationCollectionViewCell.self, forCellWithReuseIdentifier: RecommendationCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 10
        }
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

extension RecommendationCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendationCollectionViewCell.identifier, for: indexPath) as! RecommendationCollectionViewCell
        if indexPath.row < photos.count {
            let photo = photos[indexPath.row]
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
        print("SLOT TAPPED IN collectionView")
    }
}


class RecommendationCollectionViewCell: UICollectionViewCell {
    private let recommendationImageView = UIImageView()
    private let cornerRadius: CGFloat = 20
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
        contentView.backgroundColor = .black
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

//
struct MainScreenModel: Codable {
    let sections: [Section]?

    struct Section: Codable {
        let name: String?
        let cells: [Cell]?
        
        struct Cell: Codable {
            let cellName: String?
            let cellPhotos: [String]?
        }
    }
}
