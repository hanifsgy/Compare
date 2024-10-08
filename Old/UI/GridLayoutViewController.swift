import UIKit
import DifferenceKit

enum Section {
  case main
}

struct Item: Differentiable {
    var id: Int
    var value: Int
    
    var differenceIdentifier: Int {
        return id
    }
    
    func isContentEqual(to source: Item) -> Bool {
        return value == source.value
    }
}

class GridLayoutViewController: UIViewController {
    
    var collectionView: UICollectionView!
    private var items: [Item] = Array(1...5_000).map { Item(id: $0, value: $0) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let shuffleButton = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffleItems))
        let multipleSection = UIBarButtonItem(title: "Sectioned Item", style: .plain, target: self, action: #selector(sectionedItems))
        navigationItem.rightBarButtonItems = [multipleSection, shuffleButton]
    }
    
    @objc private func shuffleItems() {
        let oldItems = items
        items.shuffle()
        let changeset = StagedChangeset(source: oldItems, target: items)
        collectionView.reload(using: changeset) { data in
            self.items = data
        }
    }
    
    @objc private func sectionedItems() {
        self.navigationController?.pushViewController(MultipleSectionGridViewController(), animated: true)
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

extension GridLayoutViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "labelCell", for: indexPath) as? LabelCell else {
            fatalError()
        }
        cell.textLabel.text = "\(items[indexPath.item])"
        cell.backgroundColor = .systemOrange
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
