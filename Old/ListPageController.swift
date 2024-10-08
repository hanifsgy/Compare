import UIKit
import Shared

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
        case .compositionalLayout:
            self.navigationController?.pushViewController(GridLayoutViewController(), animated: true)
        case .features:
            self.navigationController?.pushViewController(MoversViewController(), animated: true)
        case .diffing:
            self.navigationController?.pushViewController(HeaderFooterViewController(), animated: true)
        case .diffing2:
            let wifiController = WiFiController { controller in
                // Handle updates here if needed
                print("WiFi networks updated")
            }
            self.navigationController?.pushViewController(wifiController, animated: true)
        default: break
        }
        
    }
}
