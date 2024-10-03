/// Re-write apple demo WWDC related Diffing on tableView
/// Wifi project
import UIKit
import DifferenceKit

struct WiFiNetwork: Differentiable {
    let id: UUID
    let name: String
    var signalStrength: Int
    
    var differenceIdentifier: UUID {
        return id
    }
    
    func isContentEqual(to source: WiFiNetwork) -> Bool {
        return name == source.name && signalStrength == source.signalStrength
    }
}

typealias WiFiSection = ArraySection<String, WiFiNetwork>

typealias UpdateHandler = (WiFiController) -> Void

class WiFiController: UIViewController {
    
    private var tableView: UITableView!
    private var sections: [WiFiSection]
    private let updateHandler: UpdateHandler
    private let updateInterval = 2000
    private let toggleSwitch: UISwitch = UISwitch()
    private var updateTimer: Timer?
    private var isWiFiEnabled: Bool {
        return toggleSwitch.isOn
    }
    
    init(updateHandler: @escaping UpdateHandler) {
        self.updateHandler = updateHandler
        self.sections = [
            ArraySection(model: "SETTINGS", elements: [WiFiNetwork(id: UUID(), name: "Wi-Fi", signalStrength: 0)]),
            ArraySection(model: "NETWORKS", elements: [])
        ]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        startRandomUpdates()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WiFiCell")
        view.addSubview(tableView)
        
        toggleSwitch.isOn = true
        toggleSwitch.addTarget(self, action: #selector(wifiSwitchChanged(_:)), for: .valueChanged)
    }
    
    private func startRandomUpdates() {
        stopRandomUpdates()
        updateTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(updateInterval) / 1000.0, repeats: true) { [weak self] _ in
            self?.performRandomUpdate()
        }
    }
    
    private func stopRandomUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func performRandomUpdate() {
        guard isWiFiEnabled else { return }
        
        var updatedNetworks = sections[1].elements
        
        if updatedNetworks.isEmpty || Bool.random() {
            let newNetwork = WiFiNetwork(id: UUID(), name: randomNetworkName(), signalStrength: Int.random(in: 1...3))
            updatedNetworks.append(newNetwork)
        } else if Bool.random() && !updatedNetworks.isEmpty {
            updatedNetworks.remove(at: Int.random(in: 0..<updatedNetworks.count))
        }
        
        updatedNetworks = updatedNetworks.map { network in
            var updatedNetwork = network
            updatedNetwork.signalStrength = Int.random(in: 1...3)
            return updatedNetwork
        }
        
        let newSections = [
            sections[0],
            ArraySection(model: "NETWORKS", elements: updatedNetworks)
        ]
        updateSections(newSections)
    }
    
    private func updateSections(_ newSections: [WiFiSection]) {
        let changeset = StagedChangeset(source: sections, target: newSections)
        tableView.reload(using: changeset, with: .fade) { data in
            self.sections = data
            self.updateHandler(self)
        }
    }
    
    private func randomNetworkName() -> String {
        let names = ["Home WiFi", "Office Network", "Cafe Hotspot", "Guest Network", "5G_WiFi", "Hidden Network", "Free Public WiFi"]
        return names.randomElement() ?? "Unknown Network"
    }
    
    @objc private func wifiSwitchChanged(_ sender: UISwitch) {
        let newSections = [
            sections[0],
            ArraySection(model: "NETWORKS", elements: sender.isOn ? sections[1].elements : [])
        ]
        updateSections(newSections)
        
        if sender.isOn {
            startRandomUpdates()
        } else {
            stopRandomUpdates()
        }
    }
    
    deinit {
        updateTimer?.invalidate()
    }
}

extension WiFiController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WiFiCell", for: indexPath)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.textLabel?.text = "Wi-Fi"
            cell.accessoryView = toggleSwitch
        } else {
            let network = sections[indexPath.section].elements[indexPath.row]
            cell.textLabel?.text = network.name
            cell.detailTextLabel?.text = String(repeating: "•", count: network.signalStrength)
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].model
    }
}