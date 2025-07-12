//
//  TotalAmountTableViewCell.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 12.07.2025.
//

import UIKit

 final class TotalAmountTableViewCell: UITableViewCell {

     // MARK: - Static Properties
     static let reuseIdentifier = "TotalAmountTableViewCell"

     // MARK: - Private Properties
     private lazy var nameLabel: UILabel = {
         let label = UILabel()
         return label
     }()

     private lazy var sumLabel: UILabel = {
         let label = UILabel()
         return label
     }()

     // MARK: - Init
     required init?(coder: NSCoder) {
         super.init(coder: coder)

         setupSubviews()
         setupConstraints()
     }

     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
         selectionStyle = .none
         setupSubviews()
         setupConstraints()
     }

     // MARK: - Public Methods
     func setupCell(withValue value: Decimal, for currency: String) {
         nameLabel.text = "Сумма"
         sumLabel.text = "\(value.formatted()) \(currency.currencySymbol ?? "")"
     }

     // MARK: - Private Methods
     private func setupSubviews() {
         contentView.backgroundColor = .white
         contentView.addSubview(nameLabel)
         contentView.addSubview(sumLabel)
     }

     private func setupConstraints() {
         sumLabel.translatesAutoresizingMaskIntoConstraints = false
         nameLabel.translatesAutoresizingMaskIntoConstraints = false

         NSLayoutConstraint.activate([
             nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

             sumLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             sumLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
         ])
     }
 }
