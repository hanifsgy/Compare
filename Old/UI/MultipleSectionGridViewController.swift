import UIKit
import DifferenceKit

enum SectionGrid: CaseIterable {
    case section1
    case section2
}

struct SectionedItems: DifferentiableSection {
    var model: SectionGrid
    var elements: [Item]
    
    var differenceIdentifier: SectionGrid {
        return model
    }
    
    func isContentEqual(to source: SectionedItems) -> Bool {
        return model == source.model
    }
    
    init<C>(source: SectionedItems, elements: C) where C : Collection, C.Element == Item {
        self.model = source.model
        self.elements = Array(elements)
    }
    
    init(model: SectionGrid, elements: [Item]) {
        self.model = model
        self.elements = elements
    }
}

final class MultipleSectionGridViewController: UIViewController {
    
    var collectionView: UICollectionView!
    private var items: [SectionedItems] = [
        SectionedItems(model: .section1, elements: Array(1...50).map { Item(id: $0, value: $0) }),
        SectionedItems(model: .section2, elements: Array(51...100).map { Item(id: $0, value: $0) })
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let shuffleButton = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffleItems))
        navigationItem.rightBarButtonItem = shuffleButton
    }
    
    @objc private func shuffleItems() {
        let oldItems = items
        items = items.map { section in
            var newSection = section
            newSection.elements.shuffle()
            return newSection
        }
        let changeset = StagedChangeset(source: oldItems, target: items)
        collectionView.reload(using: changeset) { data in
            self.items = data
        }
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        
        collectionView.register(LabelCell.self, forCellWithReuseIdentifier: "labelCell")
        collectionView.dataSource = self
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width / 4 - 8, height: view.bounds.width / 4 - 8)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        return layout
    }
}

extension MultipleSectionGridViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items[section].elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "labelCell", for: indexPath) as? LabelCell else {
            fatalError()
        }
        let item = items[indexPath.section].elements[indexPath.item]
        cell.textLabel.text = "\(item.value)"
        cell.backgroundColor = .systemBlue
        return cell
    }
}

fileprivate class LabelCell: UICollectionViewCell {
    
    var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -8),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 8),
            textLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
