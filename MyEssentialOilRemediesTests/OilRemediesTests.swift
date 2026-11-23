//
//  OilRemediesTests.swift
//  My Essential Oil Remedies Tests
//
//  Unit tests for OilRemedies, run against a temporary copy of the
//  factory MEO.db (3 remedies; Detox has 2 linked oils).
//

import Testing
@testable import My_Essential_Oil_Remedies

struct OilRemediesTests {
    let database: TemporaryDatabase
    var dbPath: String { database.path }

    init() throws {
        database = try TemporaryDatabase()
    }

    @Test("All remedies come back sorted by name, with their section letter")
    func allRemediesSortedByName() throws {
        let remedies = try OilRemedies.allRemedies(databasePath: dbPath)
        #expect(remedies.count == 3, "Factory database ships with 3 remedies")
        let first = try #require(remedies.first)
        #expect(first.name == "Allergy Migraines")
        #expect(first.section == "A")
        #expect(first.rid > 0)
    }

    @Test func remedyExistsIsCaseInsensitive() throws {
        #expect(try OilRemedies.remedyExists(named: "Detox", databasePath: dbPath))
        #expect(try OilRemedies.remedyExists(named: "detox", databasePath: dbPath))
        #expect(try !OilRemedies.remedyExists(named: "No Such Remedy", databasePath: dbPath))
    }

    @Test func remedyIDByName() {
        #expect(OilRemedies.remedyID(byName: "Detox", databasePath: dbPath) == 51)
    }

    @Test("The Detox remedy is linked to 2 oils")
    func oilsForRemedy() {
        #expect(OilRemedies.oilNames(forRemedyID: 51, databasePath: dbPath).count == 2)
        #expect(OilRemedies.oils(forRemedyID: 51, databasePath: dbPath).count == 2)
    }

    @Test("Adding the same oil twice returns the same ID")
    func addOilNameReusesID() throws {
        let firstID = try OilRemedies.addOilName("Unit Test Oil", databasePath: dbPath)
        #expect(firstID > 0)
        #expect(try OilLists.oilExists(named: "Unit Test Oil", databasePath: dbPath))

        let secondID = try OilRemedies.addOilName("Unit Test Oil", databasePath: dbPath)
        #expect(firstID == secondID)
    }

    @Test func addUpdateDeleteRemedyLifecycle() throws {
        let rid = try OilRemedies.addRemedyDetails(name: "Unit Test Remedy", description: "Test description",
                                                   uses: "Test uses", databasePath: dbPath)
        #expect(rid > 0, "Adding a remedy should return its new ID")
        #expect(try OilRemedies.remedyExists(named: "Unit Test Remedy", databasePath: dbPath))

        try OilRemedies.updateRemedyDetails(rid: rid, name: "Renamed Test Remedy", description: "New description",
                                            uses: "New uses", databasePath: dbPath)
        #expect(OilRemedies.remedyID(byName: "Renamed Test Remedy", databasePath: dbPath) == rid)

        try OilRemedies.deleteRemedy(id: rid, databasePath: dbPath)
        #expect(try !OilRemedies.remedyExists(named: "Renamed Test Remedy", databasePath: dbPath))
    }

    @Test("Adding oils links existing oils and creates unknown ones")
    func addOilsLinksOilsToRemedy() throws {
        let rid = try OilRemedies.addRemedyDetails(name: "Oil Link Test Remedy", description: "desc",
                                                   uses: "uses", databasePath: dbPath)
        #expect(rid > 0)

        OilRemedies.addOils(toRemedyID: rid, oils: ["Lavender", "Brand New Test Oil"], databasePath: dbPath)

        #expect(OilRemedies.oilNames(forRemedyID: rid, databasePath: dbPath).count == 2)
        #expect(try OilLists.oilExists(named: "Brand New Test Oil", databasePath: dbPath))

        try OilRemedies.clearOilsPerRemedy(rid: rid, databasePath: dbPath)
        #expect(OilRemedies.oilNames(forRemedyID: rid, databasePath: dbPath).isEmpty)
        try OilRemedies.deleteRemedy(id: rid, databasePath: dbPath)
    }

    @Test("Names with apostrophes are stored once-escaped and found again")
    func namesWithApostrophes() throws {
        let rid = try OilRemedies.addRemedyDetails(name: "Grandma's Rub", description: "It's warm",
                                                   uses: "Rub it in", databasePath: dbPath)
        #expect(rid > 0)
        #expect(OilRemedies.remedyID(byName: "Grandma's Rub", databasePath: dbPath) == rid)

        OilRemedies.addOils(toRemedyID: rid, oils: ["St. John's Wort"], databasePath: dbPath)
        #expect(OilRemedies.oilNames(forRemedyID: rid, databasePath: dbPath) == ["St. John's Wort"])

        let remedy = try #require(try OilRemedies.allRemedies(databasePath: dbPath).first { $0.rid == rid })
        #expect(remedy.name == "Grandma's Rub")
        #expect(remedy.description == "It's warm")
    }
}
