import UIKit

enum SectionedComponent: CaseIterable {
    case section1
    case section2
}

final class MultipleSectionCompositionalLayout: UIViewController {
    
    var collectionView: UICollectionView!
    private var items: [SectionedComponent: [Item]] = [
        .section1: Array(1...50).map { Item(id: $0, value: $0) },
        .section2: Array(51...100).map { Item(id: $0, value: $0) }
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
    
    /// `CollectionDifference` designed to handled flat collections and does not natively support sectioned diffing
    /// https://github.com/ra1028/DifferenceKit?tab=readme-ov-file#--supported-section-diff
    ///
    @objc private func shuffleItems() {
         var newItems = items
         for section in SectionedComponent.allCases {
             newItems[section]?.shuffle()
         }
         
         collectionView.performBatchUpdates {
             for (sectionIdx, section) in SectionedComponent.allCases.enumerated() {
                 let oldSnapshot = items[section]!
                 let newSnapshot = newItems[section]!
                 /// difference calculations for each sections
                 let difference = newSnapshot.difference(from: oldSnapshot)
                 
                 for change in difference {
                     switch change {
                     case .remove(let offset, _, _):
                         collectionView.deleteItems(at: [IndexPath(item: offset, section: sectionIdx)])
                     case .insert(let offset, _, _):
                         collectionView.insertItems(at: [IndexPath(item: offset, section: sectionIdx)])
                     }
                 }
             }
         }
         
         items = newItems
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalWidth(0.25))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.25))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func createSnapshot(from items: [SectionedComponent: [Item]]) -> [Item] {
        return items.flatMap { $0.value }
    }
}

extension MultipleSectionCompositionalLayout: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SectionedComponent.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = SectionedComponent.allCases[section]
        return items[section]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "labelCell", for: indexPath) as? LabelCell else {
            fatalError()
        }
        let section = SectionedComponent.allCases[indexPath.section]
        let item = items[section]![indexPath.item]
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
