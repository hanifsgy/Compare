import UIKit

enum Page: String, CaseIterable {
    case gridCollectionLayout
    case structuredConcurrency
    case diffing
    
    var title: String {
        switch self {
        case .gridCollectionLayout:
            "UI - Grid Collection Layout - Diffing"
        case .structuredConcurrency:
            "Structured Concurrency Demo"
        case .diffing:
            "Diffing on TableView"
        }
    }
}

final class ListPageController: UITableViewController {
    
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
        case .gridCollectionLayout:
            self.navigationController?.pushViewController(GridLayoutViewController(), animated: true)
        case .diffing: break
        default: break
        }
        
    }
}
