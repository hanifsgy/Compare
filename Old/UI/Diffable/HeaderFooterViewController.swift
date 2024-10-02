/// Take from example header footer example
import UIKit
import DifferenceKit

struct HeaderFooterSectionModel: Differentiable, Equatable {
    var id: Int
    var hasFooter: Bool

    var differenceIdentifier: Int {
        return id
    }

    var headerTitle: String {
        return "Section \(id)"
    }
    
    func isContentEqual(to source: HeaderFooterSectionModel) -> Bool {
        return self.id == source.id
    }
}

extension String: Differentiable {}


final class HeaderFooterViewController: UITableViewController {
    typealias Section = ArraySection<HeaderFooterSectionModel, String>
    private var data = [Section]()
    private var dataInput: [Section] {
        get { return data }
        set {
            let changeset = StagedChangeset(source: data, target: newValue)
            tableView.reload(using: changeset, with: .fade) { data in
                self.data = data
            }
        }
    }
    
    private let allTexts = (0x0041...0x005A).compactMap { UnicodeScalar($0).map(String.init) }
    @objc private func refresh() {
        let modelA = HeaderFooterSectionModel(id: 0, hasFooter: true)
        let modelB = HeaderFooterSectionModel(id: 1, hasFooter: true)
        let sectionA = Section(model: modelA, elements: allTexts.prefix(7))
        let sectionB = Section(model: modelB, elements: allTexts.prefix(10))
        dataInput = [sectionA, sectionB]
    }
    
    private func showMore(in sectionIndex: Int) {
        var section = dataInput[sectionIndex]
        let texts = allTexts.dropFirst(section.elements.count).prefix(7)
        section.elements.append(contentsOf: texts)
        section.model.hasFooter = section.elements.count < allTexts.count
        dataInput[sectionIndex] = section

        let lastIndex = section.elements.index(before: section.elements.endIndex)
        let lastIndexPath = IndexPath(row: lastIndex, section: sectionIndex)
        tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Header Footer"
        tableView.allowsSelection = false
        tableView.register(HeaderFooterPlainCell.self, forCellReuseIdentifier: "HeaderFooterPlainCell")
        tableView.register(HeaderFooterMoreView.self, forHeaderFooterViewReuseIdentifier: "HeaderFooterMoreView")

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
    }
}
extension HeaderFooterViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderFooterPlainCell", for: indexPath) as! HeaderFooterPlainCell
        cell.textLabel?.text = data[indexPath.section].elements[indexPath.row]
        return cell
    }


    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].model.headerTitle
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard data[section].model.hasFooter else { return nil }

        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderFooterMoreView") as! HeaderFooterMoreView
        view.onMorePressed = { [weak self] in
            self?.showMore(in: section)
        }

        return view
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return data[section].model.hasFooter ? 44 : 0
    }
}

class HeaderFooterPlainCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        textLabel?.font = UIFont.systemFont(ofSize: 16)
        textLabel?.textColor = .black
    }
}

class HeaderFooterMoreView: UITableViewHeaderFooterView {
    var onMorePressed: (() -> Void)?
    
    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show More", for: .normal)
        button.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(moreButton)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            moreButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            moreButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    @objc private func moreButtonTapped() {
        onMorePressed?()
    }
}
