//
//  CalendarDayLayout.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/4/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

protocol CalendarDayLayoutDelegate: UICollectionViewDelegate {

    func numberOfRowsIn(section: Int) -> Int

    func startRowForItem(at indexPath: IndexPath) -> Int
    func endRowForItem(at indexPath: IndexPath) -> Int
}

class CalendarDayLayout: UICollectionViewLayout {

    // MARK: Constants

    enum SupplementaryViewKind: String {
        case Separator = "Separator"
    }

    init(withDelegate delegate: CalendarDayLayoutDelegate) {
        self.delegate = delegate

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Delegate

    var delegate: CalendarDayLayoutDelegate? = nil

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    let rowHeight: CGFloat = 55.0
    let separatorHeight: CGFloat = 22.0

    private func heightFor(section: Int) -> CGFloat {
        return self.rowHeight * CGFloat(self.delegate?.numberOfRowsIn(section: section) ?? 0)
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
        self.contentSize = CGSize(width: self.collectionView!.bounds.size.width, height: self.heightFor(section: 0))
        self.cellLayoutAttributes = (0..<(self.collectionView?.numberOfSections ?? 0)).map { layoutAttributesFor(section: $0) }
    }

    private func layoutAttributesFor(section: Int) -> [UICollectionViewLayoutAttributes] {
        return (0..<self.collectionView!.numberOfItems(inSection: section)).map { item in
            let indexPath = IndexPath(item: item, section: section)
            let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

            let startRow = self.delegate?.startRowForItem(at: indexPath) ?? 0
            let endRow = self.delegate?.endRowForItem(at: indexPath) ?? 0

            let sectionOffset: CGFloat = 0

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

            let separatorLayoutAttributes: [UICollectionViewLayoutAttributes] = (1..<(self.delegate?.numberOfRowsIn(section: section) ?? 1)).map { row in
                return self.layoutAttributesForSupplementaryView(ofKind: SupplementaryViewKind.Separator.rawValue, at: IndexPath(item: row, section: section))!
            }

            let cellLayoutAttributes: [UICollectionViewLayoutAttributes] = self.itemRangeFor(section: section).map { item in
                return self.layoutAttributesForItem(at: IndexPath(item: item, section: section))!
            }

            return separatorLayoutAttributes + cellLayoutAttributes
        }

        return layoutAttributes
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)

        let headerHeight: CGFloat = 0
        let sectionOffset: CGFloat = 0

        switch SupplementaryViewKind(rawValue: elementKind)! {
        case .Separator:
            layoutAttributes.frame = CGRect(x: 0.0, y: sectionOffset + headerHeight + CGFloat(indexPath.row) * rowHeight - separatorHeight / 2.0, width: contentSize.width, height: separatorHeight)
            layoutAttributes.zIndex = -1
        }

        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cellLayoutAttributes[indexPath.section][indexPath.item]
    }
}
