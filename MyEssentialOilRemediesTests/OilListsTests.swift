//
//  OilListsTests.swift
//  My Essential Oil Remedies Tests
//
//  Unit tests for OilLists, run against a temporary copy of the
//  factory MEO.db (9 oils, 2 in stock, 2 flagged for re-order).
//

import Testing
@testable import My_Essential_Oil_Remedies

struct OilListsTests {
    let database: TemporaryDatabase
    var dbPath: String { database.path }

    init() throws {
        database = try TemporaryDatabase()
    }

    @Test("All oils come back sorted by name")
    func allOilsSortedByName() throws {
        let oils = try OilLists.allOils(databasePath: dbPath)
        #expect(oils.count == 9, "Factory database ships with 9 oils")
        let first = try #require(oils.first)
        #expect(first.name == "Ginger")
        #expect(first.oid > 0)
    }

    @Test func oilExistsIsCaseInsensitive() throws {
        #expect(try OilLists.oilExists(named: "Lavender", databasePath: dbPath))
        #expect(try OilLists.oilExists(named: "lavender", databasePath: dbPath))
        #expect(try !OilLists.oilExists(named: "No Such Oil", databasePath: dbPath))
    }

    @Test func oilNameByID() throws {
        #expect(try OilLists.oilName(byID: 130, databasePath: dbPath) == "Lavender")
    }

    @Test func oilIDByNameReturnsExistingID() throws {
        #expect(try OilLists.oilID(byName: "Lavender", inStock: true, databasePath: dbPath) == 130)
    }

    @Test func oilIDByNameInsertsMissingOil() throws {
        let oid = try OilLists.oilID(byName: "Unit Test Oil", inStock: false, databasePath: dbPath)
        #expect(oid > 0, "A new oil should get a database ID")
        #expect(try OilLists.oilExists(named: "Unit Test Oil", databasePath: dbPath))
    }

    @Test func inStockCountsMatchFactoryData() throws {
        #expect(try OilLists.inStockCount(databasePath: dbPath) == 2)
        let oils = try OilLists.allOils(databasePath: dbPath)
        #expect(OilLists.inStockCount(in: oils) == 2)
    }

    @Test func updateStockStatusChangesInStockCount() throws {
        // Oil 131 (Ginger) is out of stock in the factory database.
        try OilLists.updateStockStatus(true, oilID: 131, databasePath: dbPath)
        #expect(try OilLists.inStockCount(databasePath: dbPath) == 3)

        try OilLists.updateStockStatus(false, oilID: 131, databasePath: dbPath)
        #expect(try OilLists.inStockCount(databasePath: dbPath) == 2)
    }

    @Test("The blend status is saved against the oil, not the details row ID")
    func updateBlendStatusUpdatesTheOil() throws {
        try OilLists.updateBlendStatus(true, oilID: 131, databasePath: dbPath)
        let ginger = try #require(try OilLists.allOils(databasePath: dbPath).first { $0.oid == 131 })
        #expect(ginger.isBlend)

        try OilLists.updateBlendStatus(false, oilID: 131, databasePath: dbPath)
        let updated = try #require(try OilLists.allOils(databasePath: dbPath).first { $0.oid == 131 })
        #expect(!updated.isBlend)
    }

    @Test func reOrderCountsMatchFactoryData() throws {
        #expect(try OilLists.shoppingCount(databasePath: dbPath) == 2)
        #expect(try OilLists.oilsForReOrder(databasePath: dbPath).count == 2)
        let oils = try OilLists.allOils(databasePath: dbPath)
        #expect(OilLists.shoppingCount(in: oils) == 2)
    }

    @Test("Oil 137 is linked to the Detox remedy in the factory database")
    func remediesRelatedToOil() throws {
        let remedies = try OilLists.remediesRelated(toOilID: 137, databasePath: dbPath)
        #expect(remedies == [RelatedRemedy(rid: 51, name: "Detox")])
    }

    @Test func insertAndUpdateOilDetails() throws {
        let oid = try OilLists.oilID(byName: "Details Test Oil", inStock: false, databasePath: dbPath)
        var details = OilDetails(description: "Tester's oil", botanicalName: "Testus oleum", isBlend: true)
        try OilLists.insertOilDetails(oid: oid, details: details, databasePath: dbPath)

        var oil = try #require(try OilLists.allOils(databasePath: dbPath).first { $0.oid == oid })
        #expect(oil.description == "Tester's oil")
        #expect(oil.botanicalName == "Testus oleum")
        #expect(oil.isBlend)

        details.description = "Updated"
        details.isBlend = false
        try OilLists.updateOilDetails(oid: oid, details: details, databasePath: dbPath)
        oil = try #require(try OilLists.allOils(databasePath: dbPath).first { $0.oid == oid })
        #expect(oil.description == "Updated")
        #expect(!oil.isBlend)
    }
}
