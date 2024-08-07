//
//  ListViewController.swift
//  Compare
//
//  Created by Muhammad Hanif Sugiyanto on 07/08/24.
//

import UIKit

enum Page: String, CaseIterable {
    case compositionalLayout
    case structuredConcurrency
    case diffing
    
    var title: String {
        switch self {
        case .compositionalLayout:
            "UI - Compositional Layout"
        case .structuredConcurrency:
            "Structured Concurrency Demo"
        case .diffing:
            "Diffing on TableView"
        }
    }
}

final class ListViewController: UITableViewController {
    
    private let data: [Page] = Page.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lists"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let page = data[indexPath.row].rawValue
        switch Page(rawValue: page) {
        case .compositionalLayout:
            self.navigationController?.pushViewController(CompositionalLayout(), animated: true)
        case .diffing: break
        default: break
        }
        
    }
}
