import UIKit
import Shared

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
        case .features:
            self.navigationController?.pushViewController(MoversViewController(), animated: true)
        case .diffing:
            self.navigationController?.pushViewController(WifiSettingsViewController(), animated: true)
        default: break
        }
        
    }
}
