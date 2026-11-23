//
//  SearchDatabaseTests.swift
//  My Essential Oil Remedies Tests
//
//  Unit tests for SearchDatabase, run against a temporary copy of
//  the factory MEO.db (9 oils + 3 remedies).
//

import Testing
@testable import My_Essential_Oil_Remedies

struct SearchDatabaseTests {
    let database: TemporaryDatabase
    var dbPath: String { database.path }

    init() throws {
        database = try TemporaryDatabase()
    }

    @Test("Search data is the 9 oils plus the 3 remedies")
    func allSearchDataCombinesOilsAndRemedies() {
        let results = SearchDatabase.allSearchDataSimple(databasePath: dbPath)
        #expect(results.count == 12)
        #expect(results.contains("Lavender"))
        #expect(results.contains("Detox"))
    }

    @Test func oilIDByName() throws {
        #expect(try SearchDatabase.oilID(byName: "Lavender", databasePath: dbPath) == 130)
        #expect(try SearchDatabase.oilID(byName: "Detox", databasePath: dbPath) == 0, "A remedy name is not an oil")
        #expect(try SearchDatabase.oilID(byName: "No Such Entry", databasePath: dbPath) == 0)
    }

    @Test func remedyIDByName() throws {
        #expect(try SearchDatabase.remedyID(byName: "Detox", databasePath: dbPath) == 51)
        #expect(try SearchDatabase.remedyID(byName: "Lavender", databasePath: dbPath) == 0, "An oil name is not a remedy")
        #expect(try SearchDatabase.remedyID(byName: "No Such Entry", databasePath: dbPath) == 0)
    }
}
