//
//  Endpoint.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 17.07.2025.
//

import Foundation

enum ContentType: String {
    case json = "application/json"
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIEndpoint {
    case accounts
    case account(id: Int)
    case updateAccount(id: Int)
    
    case categories
    case categoryByDirection(isIncome: Bool)
    
    case createTransaction
    case transaction(id: Int)
    case updateTransaction(id: Int)
    case deleteTransaction(id: Int)
    case transactionsByPeriod(accountId: Int, startDate: Date? = nil, endDate: Date? = nil)
    
}

private let isoFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withFullDate]
    return formatter
}()

extension APIEndpoint {
    
    var method: HTTPMethod {
        switch self {
        case    .accounts,
                .account,
                .categories,
                .categoryByDirection,
                .transaction,
                .transactionsByPeriod:
            return .get
        case    .createTransaction:
            return .post
        case    .updateAccount,
                .updateTransaction:
            return .put
        case    .deleteTransaction:
            return .delete
        }
    }
    
    
    var path: String {
        switch self {
        case .accounts:
            return "/accounts"
        case .account(let id):
            return "/accounts/\(id)"
        case .updateAccount(let id):
            return "/accounts/\(id)"
        case .categories:
            return "/categories"
        case .categoryByDirection(let isIncome):
            return "/categories/type/\(isIncome)"
        case .createTransaction:
            return "/transactions"
        case .transaction(let id):
            return "/transactions/\(id)"
        case .updateTransaction(let id):
            return "/transactions/\(id)"
        case .deleteTransaction(let id):
            return "/transactions/\(id)"
        case .transactionsByPeriod(let accountId, _, _):
            return "/transactions/account/\(accountId)/period"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .transactionsByPeriod(_, let start, let end):
            var items: [URLQueryItem] = []
            if let start = start {
                items.append(URLQueryItem(name:
                                            "startDate", value: isoFormatter.string(from: start)))
            }
            if let end = end {
                items.append(URLQueryItem(name: "endDate", value: isoFormatter.string(from: end)))
            }
            return items.isEmpty ? nil : items
        default:
            return nil
        }
    }
    
}
