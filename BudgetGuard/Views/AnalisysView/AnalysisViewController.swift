//
//  AnalysisViewController.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 11.07.2025.
//

import UIKit
import SwiftUI

enum DatePickerType: String {
     case start = "Период: начало"
     case end = "Период: конец"
 }

enum CellType {
     case picker(datePickerType: DatePickerType)
     case sorting
     case totalAmount
 }

protocol AnalysisViewProtocol: AnyObject {
    func reloadTransactionTableView()
    func reloadPickerTableView()
}

final class AnalysisViewController: UIViewController {

    private let presenter: AnalysisPresenterProtocol
    private let cells: [CellType] = [
            .picker(datePickerType: .start),
            .picker(datePickerType: .end),
            .sorting,
            .totalAmount
        ]
    private var tableHeightConstraint: NSLayoutConstraint?
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var diagramView = UIView()
    
    private lazy var tableTitleLabel: UILabel = {
             let label = UILabel()
             label.text = "ОПЕРАЦИИ"
             label.textColor = .secondaryLabel
             label.font = .systemFont(ofSize: 13, weight: .regular)
             return label
         }()
    
    private var pickerTableView: UITableView!
    private var transactionTableView: UITableView!
    
    
    init(presenter: AnalysisPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        presenter.view = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerTableView = makePickerTableView()
        transactionTableView = makeTransactionTableView()
        setupSubviews()
        setupConstraints()
        presenter.loadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        self.parent?.navigationItem.title = "Анализ"
        self.parent?.navigationController?.navigationBar.prefersLargeTitles = true
        self.parent?.navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupSubviews() {
            view.backgroundColor = .background
            view.addSubview(scrollView)
            scrollView.addSubview(contentView)

            contentView.addSubview(pickerTableView)
            contentView.addSubview(diagramView)
            contentView.addSubview(tableTitleLabel)
            contentView.addSubview(transactionTableView)

        diagramView.backgroundColor = .background
    }
    
    private func setupConstraints() {
             scrollView.translatesAutoresizingMaskIntoConstraints = false
             contentView.translatesAutoresizingMaskIntoConstraints = false
             pickerTableView.translatesAutoresizingMaskIntoConstraints = false
             diagramView.translatesAutoresizingMaskIntoConstraints = false
             tableTitleLabel.translatesAutoresizingMaskIntoConstraints = false
             transactionTableView.translatesAutoresizingMaskIntoConstraints = false

             tableHeightConstraint = transactionTableView.heightAnchor.constraint(equalToConstant: CGFloat(presenter.transactions.count) * 60)
             tableHeightConstraint?.isActive = true

             NSLayoutConstraint.activate([
                 scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                 scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                 scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                 scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                 contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                 contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                 contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                 contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                 contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

                 pickerTableView.topAnchor.constraint(equalTo: contentView.topAnchor),
                 pickerTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                 pickerTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                 pickerTableView.heightAnchor.constraint(equalToConstant: 176),

                 diagramView.topAnchor.constraint(equalTo: pickerTableView.bottomAnchor),
                 diagramView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                 diagramView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                 diagramView.heightAnchor.constraint(equalToConstant: 185),
                 tableTitleLabel.topAnchor.constraint(equalTo: diagramView.bottomAnchor, constant: 8),
                 tableTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

                 transactionTableView.topAnchor.constraint(equalTo: tableTitleLabel.bottomAnchor, constant: 8),
                 transactionTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                 transactionTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                 transactionTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
             ])
         }
    
    private func setupSeparator(for cell: UITableViewCell, at indexPath: IndexPath) {
             let last = cell is TransactionTableViewCell ? presenter.transactions.count-1 : cells.count-1
             if indexPath.row == last {
                 cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
             } else {
                 cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
             }
         }
    
    private func makePickerTableView() -> UITableView {
             let tableView = UITableView()
             tableView.register(TotalAmountTableViewCell.self, forCellReuseIdentifier: TotalAmountTableViewCell.reuseIdentifier)
             tableView.register(SortTableViewCell.self, forCellReuseIdentifier: SortTableViewCell.reuseIdentifier)
             tableView.register(PickerTableViewCell.self, forCellReuseIdentifier: PickerTableViewCell.reuseIdentifier)
             tableView.dataSource = self
             tableView.delegate = self
             tableView.isScrollEnabled = false
             tableView.layer.cornerRadius = 10
             tableView.tableHeaderView = UIView()
             return tableView
         }
    
    private func makeTransactionTableView() -> UITableView {
            let tableView = UITableView()
            tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: TransactionTableViewCell.reuseIdentifier)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.isScrollEnabled = false
            tableView.layer.cornerRadius = 10
            tableView.tableHeaderView = UIView()
            return tableView
        }
    
}

extension AnalysisViewController: UITableViewDataSource, UITableViewDelegate {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if tableView == pickerTableView {
             return cells.count
         } else if tableView == transactionTableView {
             return presenter.transactions.count
         }
         return 0
     }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if tableView == pickerTableView {
             let type = cells[indexPath.row]
             switch type {
             case .picker(let datePickerType):
                 guard let cell = tableView.dequeueReusableCell(withIdentifier: PickerTableViewCell.reuseIdentifier, for: indexPath) as? PickerTableViewCell else {
                     return UITableViewCell()
                 }
                 cell.setupCell(with: datePickerType,for:indexPath.row == 0 ? presenter.fromDate : presenter.toDate , delegate: self)
                 setupSeparator(for: cell, at: indexPath)
                 return cell
             case .totalAmount:
                 guard let cell = tableView.dequeueReusableCell(withIdentifier: TotalAmountTableViewCell.reuseIdentifier, for: indexPath) as? TotalAmountTableViewCell else {
                     return UITableViewCell()
                 }
                 cell.setupCell(withValue: presenter.totalAmount, for: presenter.bankAccount?.currency ?? "")
                 setupSeparator(for: cell, at: indexPath)
                 return cell
             case .sorting:
                 guard let cell = tableView.dequeueReusableCell(withIdentifier: SortTableViewCell.reuseIdentifier, for: indexPath) as? SortTableViewCell else {
                     return UITableViewCell()
                 }
                 cell.setupCell(withType: presenter.sortingType, delegate: self)
                 setupSeparator(for: cell, at: indexPath)
                 return cell
             }
         } else {
             guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.reuseIdentifier, for: indexPath) as? TransactionTableViewCell else {
                 return UITableViewCell()
             }
             let transaction = presenter.transactions[indexPath.row]
             let category = presenter.categories.first(where: { $0.id == transaction.categoryId })
             let amount = NSDecimalNumber(decimal: transaction.amount)
             let sum = NSDecimalNumber(decimal: presenter.totalAmount)
             let percentDecimal = amount.multiplying(by: 100).dividing(by: sum)
             let percent = percentDecimal.rounding(accordingToBehavior: nil).intValue
             cell.setupCell(with: transaction, category: category, currency: presenter.bankAccount?.currency ?? "OOPS",  percent: percent, delegate: self)
             setupSeparator(for: cell, at: indexPath)
             return cell
         }
     }

     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         tableView == pickerTableView ? 44 : 60
     }

//     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//         guard tableView == transactionTableView else { return }
//         let swiftUIView = TransactionEditView()
//         let hostingController = UIHostingController(rootView: swiftUIView)
//         navigationController?.pushViewController(hostingController, animated: true)
//     }
 }

 // MARK: - AnalysisViewProtocol
 extension AnalysisViewController: AnalysisViewProtocol {
     func reloadTransactionTableView() {
         transactionTableView.reloadData()
         tableHeightConstraint?.constant = CGFloat(presenter.transactions.count) * 60
         UIView.animate(withDuration: 0.3) {
             self.view.layoutIfNeeded()
         }
     }
     func reloadPickerTableView() {
         pickerTableView.reloadData()
     }
 }

 // MARK: - PickerTableViewCellDelegate
 extension AnalysisViewController: PickerTableViewCellDelegate {
     func updateDate(_ date: Date, for type: DatePickerType) {
         switch type {
         case .start:
             presenter.fromDate = date
         case .end:
             presenter.toDate = date
         }
         presenter.loadData()
     }
 }

 // MARK: - SortTableViewCellDelegate
 extension AnalysisViewController: SortTableViewCellDelegate {
     func sort(withType type: SortingType) {
         presenter.sortingType = type
         presenter.loadData()
     }
 }
