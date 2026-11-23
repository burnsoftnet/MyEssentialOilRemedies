//
//  MYSettingsTests.swift
//  My Essential Oil Remedies Tests
//
//  Unit tests for MYSettings and its application constants.
//

import Testing
@testable import My_Essential_Oil_Remedies

struct MYSettingsTests {

    @Test("The test host is the full version, so it isn't the Lite version")
    func isLiteVersionIsFalseForFullVersionHost() {
        #expect(!MYSettings.isLiteVersion)
    }

    @Test("Expected database version; make sure DBUpgrade handles any new version")
    func expectedDatabaseVersion() {
        #expect(abs(MYSettings.dbVersion - 1.4) < 0.0001)
    }

    @Test func databaseName() {
        #expect(MYSettings.dbName == "MEO.db")
    }

    @Test func liteVersionEntryLimit() {
        #expect(MYSettings.liteLimit == 15)
    }
}
