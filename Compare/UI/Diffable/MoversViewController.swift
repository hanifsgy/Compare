import UIKit
import Shared

final class MoversViewController: UIViewController {
    enum Section {
        case main
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Stock>!
    private var stocks: [Stock] = []
    private var timer: Timer?
    private var sortAscending = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupDataSource()
        loadInitialData()
        startUpdatingPrices()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        
        collectionView.register(StockCell.self, forCellWithReuseIdentifier: StockCell.reuseIdentifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(60))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Stock>(collectionView: collectionView) {
            (collectionView, indexPath, stock) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StockCell.reuseIdentifier, for: indexPath) as? StockCell else {
                fatalError("Unable to dequeue StockCell")
            }
            cell.configure(with: stock)
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) in
            guard kind == UICollectionView.elementKindSectionHeader else {
                return UICollectionReusableView()
            }
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderView.reuseIdentifier,
                for: indexPath
            ) as? SectionHeaderView
            view?.delegate = self
            return view
        }
    }
    
    private func loadInitialData() {
        stocks = [
            Stock(companyName: "Apple", stockCode: "AAPL", price: 150.0, previousPrice: 149.0),
            Stock(companyName: "Google", stockCode: "GOOGL", price: 2800.0, previousPrice: 2795.0),
            Stock(companyName: "Microsoft", stockCode: "MSFT", price: 300.0, previousPrice: 301.0),
            Stock(companyName: "Amazon", stockCode: "AMZN", price: 3300.0, previousPrice: 3290.0),
            Stock(companyName: "Facebook", stockCode: "FB", price: 330.0, previousPrice: 332.0)
        ]
        
        updateSnapshot()
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Stock>()
        snapshot.appendSections([.main])
        snapshot.appendItems(stocks)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func startUpdatingPrices() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.25, repeats: true) { [weak self] _ in
            self?.updatePrices()
        }
    }
    
    private func updatePrices() {
        var updatedStocks: [Stock] = []
        for stock in stocks {
            let randomPercentage = Double.random(in: -3...3) / 100
            let priceChange = stock.price * randomPercentage
            let newPrice = stock.price + priceChange
            let roundedNewPrice = (newPrice * 100).rounded() / 100
            let updatedStock = Stock(companyName: stock.companyName,
                                     stockCode: stock.stockCode,
                                     price: roundedNewPrice,
                                     previousPrice: stock.price)
            updatedStocks.append(updatedStock)
        }
        stocks = updatedStocks
        sortStocks()
        updateSnapshot()
        
        // Animate color changes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.animatePriceChanges()
        }
    }
    
    private func animatePriceChanges() {
        for cell in collectionView.visibleCells {
            guard let stockCell = cell as? StockCell else { continue }
            stockCell.animatePriceChange()
        }
    }
    
    private func sortStocks() {
        stocks.sort { (stock1, stock2) -> Bool in
            let change1 = (stock1.price - stock1.previousPrice) / stock1.previousPrice
            let change2 = (stock2.price - stock2.previousPrice) / stock2.previousPrice
            return sortAscending ? change1 < change2 : change1 > change2
        }
    }
}

extension MoversViewController: SectionHeaderViewDelegate {
    func didTapSortButton() {
        sortAscending.toggle()
        sortStocks()
        updateSnapshot()
    }
}
