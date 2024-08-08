import UIKit

enum Section {
  case main
}

struct Item: Hashable {
    var id: Int
    var value: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class CompositionalLayout: UIViewController {
    
    var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var items: [Item] = Array(1...5_000).map { Item(id: $0, value: $0)}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        configureDataSource()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let shuffleButton = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffleItems))
        let multipleSection = UIBarButtonItem(title: "Sectioned Item", style: .plain, target: self, action: #selector(sectionedItems))
        navigationItem.rightBarButtonItems = [multipleSection, shuffleButton]
    }
    
    @objc private func shuffleItems() {
        items.shuffle()
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
//        if #available(iOS 15.0, *) {
//            dataSource.applySnapshotUsingReloadData(snapshot)
//        } else {
//            dataSource.apply(snapshot, animatingDifferences: true)
//        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc private func sectionedItems() {
        self.navigationController?.pushViewController(MultipleSectionCompositionalLayout(), animated: true)
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        collectionView.register(LabelCell.self, forCellWithReuseIdentifier: "labelCell")
    }
    
    private func configureDataSource() {
      dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, value) -> UICollectionViewCell? in
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "labelCell", for: indexPath) as? LabelCell else {
          fatalError()
        }
        cell.textLabel.text = "\(value)"
        cell.backgroundColor = .systemOrange
        return cell
      })
        
      var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
      snapshot.appendSections([.main])
      snapshot.appendItems(items, toSection: .main)
      dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func createLayout() -> UICollectionViewLayout {
      let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
      let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.25))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      let section = NSCollectionLayoutSection(group: group)
      let layout = UICollectionViewCompositionalLayout(section: section)

      return layout
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
