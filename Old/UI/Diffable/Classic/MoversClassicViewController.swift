import UIKit
import Shared

final class MoversNativeViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var stocks: [Stock] = []
    private var timer: Timer?
    private var sortAscending = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadInitialData()
        startUpdatingPrices()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width, height: 60)
        layout.minimumLineSpacing = 1
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: 44)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        
        collectionView.register(StockCell.self, forCellWithReuseIdentifier: StockCell.reuseIdentifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func loadInitialData() {
        stocks = stockDemo()
        
        collectionView.reloadData()
    }
    
    private func startUpdatingPrices() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.25, repeats: true) { [weak self] _ in
            self?.updatePrices()
        }
    }
    
    private func updatePrices() {
        let oldStocks = stocks
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
        
        let oldSortedStocks = oldStocks.sorted { $0.stockCode < $1.stockCode }
        stocks = updatedStocks
        sortStocks()
        let newSortedStocks = stocks.sorted { $0.stockCode < $1.stockCode }
        
        collectionView.performBatchUpdates({
            for (index, newStock) in newSortedStocks.enumerated() {
                if let oldIndex = oldSortedStocks.firstIndex(where: { $0.stockCode == newStock.stockCode }),
                   let newIndex = stocks.firstIndex(where: { $0.stockCode == newStock.stockCode }) {
                    if oldIndex != index {
                        collectionView.moveItem(at: IndexPath(item: oldIndex, section: 0),
                                                to: IndexPath(item: newIndex, section: 0))
                    }
                    collectionView.reloadItems(at: [IndexPath(item: newIndex, section: 0)])
                }
            }
        }, completion: { [weak self] _ in
            self?.animatePriceChanges()
        })
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

extension MoversNativeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StockCell.reuseIdentifier, for: indexPath) as? StockCell else {
            fatalError("Unable to dequeue StockCell")
        }
        cell.configure(with: stocks[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        headerView.delegate = self
        return headerView
    }
}

extension MoversNativeViewController: SectionHeaderViewDelegate {
    func didTapSortButton() {
        sortAscending.toggle()
        sortStocks()
        collectionView.reloadData()
    }
}
