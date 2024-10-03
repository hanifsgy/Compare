/// Originated from Apple WWDC related Diffing Modern Collection View
///
///
import UIKit

enum SectionWifi {
    case config
    case network
}

enum WifiType {
    case wifiEnabled
    case currentNetwork
    case availableNetwork
}

struct Network: Hashable {
    let name: String
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    static func == (lhs: Network, rhs: Network) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

struct WifiItem: Hashable {
    let title: String
    let type: WifiType
    let network: Network?
    let identifier: UUID

    init(title: String, type: WifiType) {
        self.title = title
        self.type = type
        self.network = nil
        self.identifier = UUID()
    }

    init(network: Network) {
        self.title = network.name
        self.type = .availableNetwork
        self.network = network
        self.identifier = network.identifier
    }

    var isConfig: Bool {
        let configItems: [WifiType] = [.wifiEnabled, .currentNetwork]
        return configItems.contains(type)
    }  

    var isNetwork: Bool {
        return type == .availableNetwork
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }

    static func == (lhs: WifiItem, rhs: WifiItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

final class WifiSettingsViewController: UIViewController {
    

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    var dataSource: UITableViewDiffableDataSource<SectionWifi, WifiItem>! = nil 
    var currentSnapshot = NSDiffableDataSourceSnapshot<SectionWifi, WifiItem>()
    var wifiController: WiFiController! = nil 
    lazy var configurationItems: [WifiItem] = {
        return [
            WifiItem(title: "WiFi", type: .wifiEnabled),
            WifiItem(title: "aaaa", type: .currentNetwork),
        ]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "WiFi"
        configureTableView()
        configureDataSource()
        updateDataSource()
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    private func configureDataSource() {
        wifiController = WiFiController(updateHandler: { [weak self] (wifiController) in
            self?.updateDataSource()
        })
        self.dataSource = UITableViewDiffableDataSource<SectionWifi, WifiItem>(tableView: tableView) {
            (tableView: UITableView, indexPath: IndexPath, itemIdentifier: WifiItem) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            var content = cell.defaultContentConfiguration()

            if itemIdentifier.isNetwork {
                content.text = itemIdentifier.title
                cell.accessoryType = .detailDisclosureButton
                cell.accessoryView = nil 
            } else if itemIdentifier.isConfig {
                content.text = itemIdentifier.title
                if itemIdentifier.type == .wifiEnabled {
                    let switchView = UISwitch()
                    switchView.isOn = self.wifiController.wifiEnabled
                    switchView.addTarget(self, action: #selector(self.toggleWifi(sender:)), for: .valueChanged)
                    cell.accessoryView = switchView
                } else {
                    cell.accessoryType = .detailDisclosureButton
                    cell.accessoryView = nil 
                }
            } else {
                assertionFailure("Invalid item identifier")
            }
            cell.contentConfiguration = content
            return cell
        }
        self.dataSource.defaultRowAnimation = .fade
        wifiController.scanForNetworks = true
    }

    private func updateDataSource() {
        guard let controller = wifiController else {
            return
        }
        let configItems = configurationItems.filter { !($0.type == .currentNetwork && !controller.wifiEnabled) }
        currentSnapshot = NSDiffableDataSourceSnapshot<SectionWifi, WifiItem>()
        currentSnapshot.appendSections([.config])
        currentSnapshot.appendItems(configItems, toSection: .config)
        if controller.wifiEnabled { 
            let sortedNetworks = controller.availableNetworks.sorted { $0.name < $1.name }
            let networkItems = sortedNetworks.map { WifiItem(network: $0) }
            currentSnapshot.appendSections([.network])
            currentSnapshot.appendItems(networkItems, toSection: .network)
        }   
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    @objc func toggleWifi(sender: UISwitch) {
        wifiController.wifiEnabled = sender.isOn
        updateDataSource()
    }
}

/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Controller object which notifies our application when availalbe Wi-Fi APs are available
*/

import Foundation

class WiFiController {
    typealias UpdateHandler = (WiFiController) -> Void

    init(updateHandler: @escaping UpdateHandler) {
        self.updateHandler = updateHandler
        updateAvailableNetworks(allNetworks)
        _performRandomUpdate()
    }

    var scanForNetworks = true
    var wifiEnabled = true
    var availableNetworks: Set<Network> {
        return _availableNetworks
    }

    func network(for identifier: UUID) -> Network? {
        return _availableNetworksDict[identifier]
    }

    // MARK: Internal

    private let updateHandler: UpdateHandler
    private var _availableNetworks = Set<Network>()
    private let updateInterval = 2000
    private var _availableNetworksDict = [UUID: Network]()
    private func _performRandomUpdate() {

        if wifiEnabled && scanForNetworks {
            let shouldUpdate = true
            if shouldUpdate {
                var updatedNetworks = Array(_availableNetworks)

                if updatedNetworks.isEmpty {
                    _availableNetworks = Set<Network>(allNetworks)
                } else {

                    let shouldRemove = Int.random(in: 0..<3) == 0
                    if shouldRemove {
                        let removeCount = Int.random(in: 0..<updatedNetworks.count)
                        for _ in 0..<removeCount {
                            let removeIndex = Int.random(in: 0..<updatedNetworks.count)
                            updatedNetworks.remove(at: removeIndex)
                        }
                    }

                    let shouldAdd = Int.random(in: 0..<3) == 0
                    if shouldAdd {
                        let allNetworksSet = Set<Network>(allNetworks)
                        var updatedNetworksSet = Set<Network>(updatedNetworks)
                        let notPresentNetworksSet = allNetworksSet.subtracting(updatedNetworksSet)

                        if !notPresentNetworksSet.isEmpty {
                            let addCount = Int.random(in: 0..<notPresentNetworksSet.count)
                            var notPresentNetworks = [Network](notPresentNetworksSet)

                            for _ in 0..<addCount {
                                let removeIndex = Int.random(in: 0..<notPresentNetworks.count)
                                let networkToAdd = notPresentNetworks[removeIndex]
                                notPresentNetworks.remove(at: removeIndex)
                                updatedNetworksSet.insert(networkToAdd)
                            }
                        }
                        updatedNetworks = [Network](updatedNetworksSet)
                    }
                    updateAvailableNetworks(updatedNetworks)
                }

                // notify
                updateHandler(self)
            }
        }

        let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(updateInterval)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self._performRandomUpdate()
        }
    }

    func updateAvailableNetworks(_ networks: [Network]) {
        _availableNetworks = Set<Network>(networks)
        _availableNetworksDict.removeAll()
        for network in _availableNetworks {
            _availableNetworksDict[network.identifier] = network
        }
    }

    private let allNetworks = [ Network(name: "AirSpace1"),
                                Network(name: "Living Room"),
                                Network(name: "Courage"),
                                Network(name: "Nacho WiFi"),
                                Network(name: "FBI Surveillance Van"),
                                Network(name: "Peacock-Swagger"),
                                Network(name: "GingerGymnist"),
                                Network(name: "Second Floor"),
                                Network(name: "Evergreen"),
                                Network(name: "__hidden_in_plain__sight__"),
                                Network(name: "MarketingDropBox"),
                                Network(name: "HamiltonVille"),
                                Network(name: "404NotFound"),
                                Network(name: "SNAGVille"),
                                Network(name: "Overland101"),
                                Network(name: "TheRoomWiFi"),
                                Network(name: "PrivateSpace")
    ]

}
