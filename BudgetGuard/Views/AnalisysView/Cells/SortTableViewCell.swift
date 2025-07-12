//
//  SortTableViewCell.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 12.07.2025.
//

import UIKit

 protocol SortTableViewCellDelegate: AnyObject {
     func sort(withType type: SortingType)
 }

 final class SortTableViewCell: UITableViewCell {

     // MARK: - Static Properties
     static let reuseIdentifier = "SortTableViewCell"

     // MARK: - Private Properties
     private weak var delegate: SortTableViewCellDelegate?
     private var currentType: SortingType = .forDate

     private lazy var nameLabel: UILabel = {
         let label = UILabel()
         label.text = "Сортировка"
         return label
     }()

     private lazy var sortButton: UIButton = {
         let button = UIButton(type: .system)
         button.setTitleColor(.accent, for: .normal)
         return button
     }()

     // MARK: - Init
     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
         selectionStyle = .none
         setupSubviews()
         setupConstraints()
     }

     required init?(coder: NSCoder) {
         super.init(coder: coder)
         setupSubviews()
         setupConstraints()
     }

     // MARK: - Public Methods
     func setupCell(withType type: SortingType, delegate: SortTableViewCellDelegate) {
         self.delegate = delegate
         self.currentType = type
         sortButton.setTitle(type.rawValue, for: .normal)
         configureMenu()
     }

     // MARK: - Private Methods
     private func setupSubviews() {
         contentView.addSubview(nameLabel)
         contentView.addSubview(sortButton)
     }

     private func setupConstraints() {
         sortButton.translatesAutoresizingMaskIntoConstraints = false
         nameLabel.translatesAutoresizingMaskIntoConstraints = false

         NSLayoutConstraint.activate([
             nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

             sortButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             sortButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
         ])
     }

     private func configureMenu() {
         let dateAction = UIAction(title: SortingType.forDate.rawValue) { [weak self] _ in
             self?.currentType = .forDate
             self?.sortButton.setTitle(SortingType.forDate.rawValue, for: .normal)
             self?.delegate?.sort(withType: .forDate)
         }

         let amountAction = UIAction(title: SortingType.forAmount.rawValue) { [weak self] _ in
             self?.currentType = .forAmount
             self?.sortButton.setTitle(SortingType.forAmount.rawValue, for: .normal)
             self?.delegate?.sort(withType: .forAmount)
         }

         let menu = UIMenu(title: "", children: [dateAction, amountAction])
         sortButton.menu = menu
         sortButton.showsMenuAsPrimaryAction = true
     }
 }
