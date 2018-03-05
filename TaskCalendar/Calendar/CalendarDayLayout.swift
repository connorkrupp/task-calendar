//
//  CalendarDayLayout.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/4/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

protocol CalendarDayLayoutDataSource: UICollectionViewDelegate {

    func numberOfRowsIn(section: Int) -> Int

    func startPartialRowForItem(at indexPath: IndexPath) -> Double
    func endPartialRowForItem(at indexPath: IndexPath) -> Double

    func didMoveItem(at indexPath: IndexPath, to partialRow: Double, in section: Int)
}

class CalendarDayLayout: UICollectionViewLayout {

    // MARK: Constants

    enum SupplementaryViewKind: String {
        case Separator = "Separator"
    }

    // MARK: Properties

    var longPressGestureRecognizer: UILongPressGestureRecognizer!

    // MARK: Initializers

    init(withDataSource dataSource: CalendarDayLayoutDataSource) {
        self.dataSource = dataSource

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: Delegate

    var dataSource: CalendarDayLayoutDataSource

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    let rowHeight: CGFloat = 55.0
    let separatorHeight: CGFloat = 22.0

    private func heightFor(sections: CountableRange<Int>) -> CGFloat {
        return sections.reduce(0.0, { (offset, section) in
            return offset + self.heightFor(section: section)
        })
    }

    private func heightFor(section: Int) -> CGFloat {
        return self.rowHeight * CGFloat(self.dataSource.numberOfRowsIn(section: section))
    }

    // MARK: Cache

    var sectionRange: CountableRange<Int> {
        return 0..<(self.collectionView?.numberOfSections ?? 0)
    }

    func itemRangeFor(section: Int) -> CountableRange<Int> {
        return 0..<(self.collectionView?.numberOfItems(inSection: section) ?? 0)
    }

    var contentSize = CGSize.zero

    var cellLayoutAttributes = [[UICollectionViewLayoutAttributes]]()

    // MARK: Layout

    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }

    override func prepare() {
        self.contentSize = CGSize(width: self.collectionView!.bounds.size.width, height: self.heightFor(sections: self.sectionRange))
        self.cellLayoutAttributes = (0..<(self.collectionView?.numberOfSections ?? 0)).map { layoutAttributesFor(section: $0) }

        self.installLongPressGestureRecognizer()
    }

    // MARK: Dragging

    fileprivate func installLongPressGestureRecognizer() {
        if longPressGestureRecognizer == nil {
            longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGestureRecognizer:)))
            longPressGestureRecognizer.minimumPressDuration = 0.2
            self.collectionView?.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    private struct DragInfo {
        var indexPath: IndexPath
        var view: UIView
        var offset: CGPoint
    }

    @objc func handleLongPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        let location = longPressGestureRecognizer.location(in: self.collectionView!)

        switch longPressGestureRecognizer.state {
        case .began:
            self.startDragAt(location: location)
        case .changed:
            self.updateDragAt(location: location)
        case .ended:
            self.endDragAt(location: location)
        default:
            break
        }
    }

    private var dragInfo: DragInfo? = nil

    func startDragAt(location: CGPoint) {
        guard
            let indexPath = self.collectionView?.indexPathForItem(at: location),
            let cell = self.collectionView?.cellForItem(at: indexPath),
            let draggingView = cell.snapshotView(afterScreenUpdates: true) else { return }

        draggingView.frame = cell.frame

        self.collectionView?.addSubview(draggingView)

        let dragOffset = CGPoint(x: draggingView.center.x - location.x, y: draggingView.center.y - location.y)

        draggingView.layer.shadowPath = UIBezierPath(rect: draggingView.bounds).cgPath
        draggingView.layer.shadowColor = UIColor.black.cgColor
        draggingView.layer.shadowOpacity = 0.9
        draggingView.layer.shadowRadius = 2

        self.invalidateLayout()

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
            draggingView.alpha = 0.95
        }, completion: nil)

        self.dragInfo = DragInfo(indexPath: indexPath, view: draggingView, offset: dragOffset)
    }

    func updateDragAt(location: CGPoint) {
        guard let dragInfo = self.dragInfo else { return }

        dragInfo.view.center = CGPoint(x: location.x + dragInfo.offset.x, y: location.y + dragInfo.offset.y)
    }

    func endDragAt(location: CGPoint) {
        guard let dragInfo = self.dragInfo else { return }

        let dropLocation = CGPoint(x: location.x, y: location.y + dragInfo.offset.y - dragInfo.view.frame.size.height / 2)

        let section = self.section(at: dropLocation)!
        let sectionOffset = self.heightFor(sections: 0..<section)
        let numRows = CGFloat(self.dataSource.numberOfRowsIn(section: section))
        let partialRow = (dropLocation.y - sectionOffset) / self.heightFor(section: section) * numRows
        let fullRow = floor(partialRow)
        let rounded = round(partialRow * 10) / 10
        let tenthsPlace = round((rounded - floor(rounded)) * 10)

        let row = Double(tenthsPlace < 5 ? fullRow : fullRow + 0.5)

        dragInfo.view.removeFromSuperview()
        self.dataSource.didMoveItem(at: dragInfo.indexPath, to: row, in: section)
        self.dragInfo = nil
        self.invalidateLayout()
    }

    private func section(at location: CGPoint) -> Int? {
        var offset: CGFloat = 0

        for section in self.sectionRange {
            offset += self.heightFor(section: section)

            if (location.y < offset) {
                return section
            }
        }

        return nil
    }

    // MARK: Building Layout Attributes

    private func layoutAttributesFor(section: Int) -> [UICollectionViewLayoutAttributes] {
        return (0..<self.collectionView!.numberOfItems(inSection: section)).map { item in
            let indexPath = IndexPath(item: item, section: section)
            let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

            let startRow = self.dataSource.startPartialRowForItem(at: indexPath)
            let endRow = self.dataSource.endPartialRowForItem(at: indexPath)

            let sectionOffset: CGFloat = self.heightFor(sections: 0..<indexPath.section)

            let startOffset = sectionOffset + CGFloat(startRow) * self.rowHeight
            let endOffset = sectionOffset + CGFloat(endRow) * self.rowHeight

            let rect = CGRect(x: 72, y: startOffset, width: self.contentSize.width - 72, height: endOffset - startOffset)

            layoutAttributes.frame = rect
            layoutAttributes.zIndex = indexPath.item

            return layoutAttributes
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        let layoutAttributes = sectionRange.reduce([UICollectionViewLayoutAttributes]()) { layoutAttributes, section in

            let separatorLayoutAttributes: [UICollectionViewLayoutAttributes] = (1..<(self.dataSource.numberOfRowsIn(section: section))).map { row in
                return self.layoutAttributesForSupplementaryView(ofKind: SupplementaryViewKind.Separator.rawValue, at: IndexPath(item: row, section: section))!
            }

            let cellLayoutAttributes: [UICollectionViewLayoutAttributes] = self.itemRangeFor(section: section).map { item in
                return self.layoutAttributesForItem(at: IndexPath(item: item, section: section))!
            }

            return layoutAttributes + separatorLayoutAttributes + cellLayoutAttributes
        }

        return layoutAttributes
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)

        let headerHeight: CGFloat = 0
        let sectionOffset: CGFloat = self.heightFor(sections: 0..<indexPath.section)

        switch SupplementaryViewKind(rawValue: elementKind)! {
        case .Separator:
            layoutAttributes.frame = CGRect(x: 0.0, y: sectionOffset + headerHeight + CGFloat(indexPath.row) * rowHeight - separatorHeight / 2.0, width: contentSize.width, height: self.separatorHeight)
            layoutAttributes.zIndex = -1
        }

        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cellLayoutAttributes[indexPath.section][indexPath.item]
    }
}
