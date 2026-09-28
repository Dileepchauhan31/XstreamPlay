//
//  NibReusable.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import UIKit

/// For cells whose XIB file has the same name as the class.
///
/// Add `NibReusable` to a cell, and you can register and dequeue it
/// without typing the identifier string:
///
///     tableView.register(MovieRailCell.self)
///     let cell: MovieRailCell = tableView.dequeueReusableCell(for: indexPath)
///
/// No strings means no typos, and no crashes from a wrong identifier.
protocol NibReusable: AnyObject {
    static var reuseIdentifier: String { get }
    static var nib: UINib { get }
}

extension NibReusable {

    static var reuseIdentifier: String {
        String(describing: self)
    }

    static var nib: UINib {
        UINib(nibName: reuseIdentifier, bundle: nil)
    }
}

// MARK: - UITableView

extension UITableView {

    func register<Cell: UITableViewCell & NibReusable>(_ cellType: Cell.Type) {
        register(cellType.nib, forCellReuseIdentifier: cellType.reuseIdentifier)
    }

    func registerHeaderFooter<View: UITableViewHeaderFooterView & NibReusable>(_ viewType: View.Type) {
        register(viewType.nib, forHeaderFooterViewReuseIdentifier: viewType.reuseIdentifier)
    }

    func dequeueReusableCell<Cell: UITableViewCell & NibReusable>(for indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("\(Cell.reuseIdentifier) is not registered, or its XIB has the wrong class.")
        }
        return cell
    }

    func dequeueReusableHeaderFooter<View: UITableViewHeaderFooterView & NibReusable>() -> View {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: View.reuseIdentifier) as? View else {
            fatalError("\(View.reuseIdentifier) is not registered, or its XIB has the wrong class.")
        }
        return view
    }
}

// MARK: - UICollectionView

extension UICollectionView {

    func register<Cell: UICollectionViewCell & NibReusable>(_ cellType: Cell.Type) {
        register(cellType.nib, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }

    func dequeueReusableCell<Cell: UICollectionViewCell & NibReusable>(for indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("\(Cell.reuseIdentifier) is not registered, or its XIB has the wrong class.")
        }
        return cell
    }
}
