//
//  ViewController.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 14.12.2022.
//

import UIKit

class GeneratorVC: GradientVC {
    private var filters: [GeneratorFilterModel.Filter] = []
    private var userSelectedFilters: [GeneratorFilterModel.Filter] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(with: "generator")
        loadData()
    }
    
    private func loadData() {
        FirebaseManager.shared.firestore.collection("Generator").document("filters").getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
//            print(snapshot?.data(), error)
//            snapshot?.data()
            
            guard let snapshotData = snapshot?.data() else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: snapshotData) else { return }
            
            do {
                let model = try JSONDecoder().decode(GeneratorFilterModel.self, from: data)
                print(model)
                
                DispatchQueue.main.async {
                    self.filters = model.filters
//                    self.tableView.reloadData()
                }
            } catch let error {
                print(error)
            }
            
        }
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
