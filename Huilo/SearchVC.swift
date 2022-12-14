//
//  SearchVC.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 14.12.2022.
//

import UIKit
import SnapKit

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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print(section, sections.count)
        if section < sections.count {
            return sections[section].name
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
            
            if indexPath.section < sections.count {
                let section = sections[indexPath.section]
                if let cells = section.cells, indexPath.row < cells.count {
                    print(section.name)
                    cell.textLabel?.textColor = .green
                    cell.textLabel?.text = cells[indexPath.row].cellName
                    cell.contentView.backgroundColor = .blue
                }
//                let model = conversations[indexPath.row]
//                cell.updateConversationCell(with: model)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: RecommendationCell.identifier, for: indexPath) as! RecommendationCell
            
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
//        return conversations.count > 0 ? 100 : view.safeAreaLayoutGuide.layoutFrame.height
        return 50
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
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .red
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
