////
////  Transaction+CSV.swift
////  BudgetGuard
////
////  Created by Igor Guryan on 13.06.2025.
////
//
//import Foundation
//
//extension Transaction {
//    // Заголовок CSV файла
//    static var csvHeader: String {
//        return "id,accountId,categoryId,amount,transactionDate,comment,createdAt,updatedAt"
//    }
//    
//    // Представление транзакции в CSV строке
//    var csvString: String {
//        let dateFormatter = ISO8601DateFormatter()
//        let commentEscaped = comment?.replacingOccurrences(of: "\"", with: "\"\"") ?? ""
//        
//        return [
//            "\(id)",
//            "\(account)",
//            "\(category)",
//            amount.description,
//            dateFormatter.string(from: transactionDate),
//            "\"\(commentEscaped)\"", // Заключаем комментарий в кавычки
//            dateFormatter.string(from: createdAt),
//            dateFormatter.string(from: updatedAt)
//        ].joined(separator: ",")
//    }
//    
//    // Парсинг CSV строки в Transaction
//    static func parse(csvString: String) -> Transaction? {
//        let scanner = Scanner(string: csvString)
//        scanner.charactersToBeSkipped = .whitespacesAndNewlines
//        
//        var fields = [String]()
//        var currentField = ""
//        var inQuotes = false
//        
//        while !scanner.isAtEnd {
//            if let char = scanner.scanCharacter() {
//                if char == "\"" {
//                    if inQuotes && scanner.scanString("\"") != nil {
//                        // Экранированная кавычка внутри строки
//                        currentField.append("\"")
//                    } else {
//                        inQuotes.toggle()
//                    }
//                } else if char == "," && !inQuotes {
//                    fields.append(currentField)
//                    currentField = ""
//                } else {
//                    currentField.append(char)
//                }
//            }
//        }
//        fields.append(currentField)
//        
//        guard fields.count >= 8 else { return nil }
//        
//        let dateFormatter = ISO8601DateFormatter()
//        
//        guard let id = Int(fields[0]),
//              let accountId = Int(fields[1]),
//              let categoryId = Int(fields[2]),
//              let amount = Decimal(string: fields[3]),
//              let transactionDate = dateFormatter.date(from: fields[4]),
//              let createdAt = dateFormatter.date(from: fields[6]),
//              let updatedAt = dateFormatter.date(from: fields[7])
//        else {
//            return nil
//        }
//        
//        // Удаляем кавычки из комментария если они есть
//        var comment = fields[5]
//        if comment.hasPrefix("\"") && comment.hasSuffix("\"") {
//            comment = String(comment.dropFirst().dropLast())
//        }
//        
//        return Transaction(
//            id: id,
//            account: account,
//            category: category,
//            amount: amount,
//            transactionDate: transactionDate,
//            comment: comment.isEmpty ? nil : comment,
//            createdAt: createdAt,
//            updatedAt: updatedAt
//        )
//    }
//}
