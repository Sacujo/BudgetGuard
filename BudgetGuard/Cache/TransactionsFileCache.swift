//
//  TransactionsFileCache.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 13.06.2025.
//

import Foundation

final class TransactionsFileCache {
    private var transactions: [Transaction] = []
    
    //MARK: - Add Transaction
    
    func add(_ transaction: Transaction) {
        transactions.append(transaction)
    }
    
    //MARK: - Remove Transaction
    
    func remove(by id: Int) {
        transactions.removeAll { $0.id == id }
    }
    
    //MARK: - Save Transactions to file
    
    func save(to fileName: String) throws {
        let jsonArray = transactions.map{ $0.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [.prettyPrinted])
        let url = try fileUrl(for: fileName)
        try data.write(to: url)
    }
    
    func open(from fileName: String) throws {
        let url = try fileUrl(for: fileName)
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let jsonArray = json as? [Any] else {
            print("File is corrupted")
            return
        }
        var loadedTransactions: [Transaction] = []
        for jsonObject in jsonArray {
            if let transaction = Transaction.parse(jsonObject: jsonObject) {
                if !loadedTransactions.contains(where: { $0.id == transaction.id }) {
                    loadedTransactions.append(transaction)
                }
            }
        }
        transactions = loadedTransactions
    }
    
    //MARK: - Method for fileurl
    func fileUrl(for fileName: String) throws -> URL {
        return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("\(fileName).json")
    }
    
}


