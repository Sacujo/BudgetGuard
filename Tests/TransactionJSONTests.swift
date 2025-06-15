//
//  TransactionJSONTests.swift
//  BudgetGuardTests
//
//  Created by Igor Guryan on 13.06.2025.
//

import Testing
import Foundation
@testable import BudgetGuard

struct TransactionJSONTests {
    private let testTransaction = Transaction(
        id: 1,
        accountId: 123,
        categoryId: 456,
        amount: 1000.50,
        transactionDate: Date(timeIntervalSince1970: 1623600000),
        comment: "Test comment",
        createdAt: Date(timeIntervalSince1970: 1623600000),
        updatedAt: Date(timeIntervalSince1970: 1623600000)
    )
    private let isoFormatter = ISO8601DateFormatter()
    
    @Test
    func jsonObjectConversion() async throws {
        let json = testTransaction.jsonObject as? [String: Any]
        
        #expect(json != nil, "JSON conversion failed")
        #expect(json?["id"] as? Int == 1, "Invalid id")
        #expect(json?["accountId"] as? Int == 123, "Invalid accountId")
        #expect(json?["categoryId"] as? Int == 456, "Invalid categoryId")
        #expect(json?["amount"] as? String == "1000.5", "Invalid amount")
        #expect(json?["comment"] as? String == "Test comment", "Invalid comment")
        
        let expectedDateString = isoFormatter.string(from: testTransaction.transactionDate)
        #expect(json?["transactionDate"] as? String == expectedDateString, "Invalid transactionDate")
    }
    
    @Test
    func jsonObjectWithNilComment() async throws {
        let transaction = Transaction(
            id: 2,
            accountId: 124,
            categoryId: 457,
            amount: 2000.75,
            transactionDate: Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date())
        
        let json = transaction.jsonObject as? [String: Any]
        // Проверяем что поле comment отсутствует в словаре
        #expect(json?.keys.contains("comment") == false, "Comment field should not be present")
    }
    
    @Test
    func parseValidJson() async throws {
        let json: [String: Any] = [
            "id": 1,
            "accountId": 123,
            "categoryId": 456,
            "amount": "1000.5",
            "transactionDate": "2021-06-13T00:00:00Z",
            "comment": "Test comment",
            "createdAt": "2021-06-13T00:00:00Z",
            "updatedAt": "2021-06-13T00:00:00Z"
        ]
        
        let parsedTransaction = Transaction.parse(jsonObject: json)
        #expect(parsedTransaction != nil, "Parsing failed")
        #expect(parsedTransaction?.id == 1, "Parsed id mismatch")
        #expect(parsedTransaction?.amount == Decimal(1000.5), "Parsed amount mismatch")
    }
    
    //MARK: - Missing
    @Test
    func parseJsonWithMissingFields() async throws {
        let json: [String: Any] = [
            "id": 1,
            "accountId": 123,
            "categoryId": 456,
            "amount": "1000.5",
            "transactionDate": "2021-06-13T00:00:00Z",
            "createdAt": "2021-06-13T00:00:00Z",
            "updatedAt": "2021-06-13T00:00:00Z"
        ]
        
        let parsedTransaction = Transaction.parse(jsonObject: json)
        #expect(parsedTransaction == nil, "Should fail with missing fields")
    }
    //MARK: - RoundtripConversion
    @Test
    func roundtripConversion() async throws {
        let json = testTransaction.jsonObject
        let parsedTransaction = Transaction.parse(jsonObject: json)
        
        #expect(parsedTransaction != nil, "Roundtrip failed")
        #expect(parsedTransaction?.id == testTransaction.id, "ID mismatch in roundtrip")
        #expect(parsedTransaction?.amount == testTransaction.amount, "Amount mismatch in roundtrip")
    }
}
