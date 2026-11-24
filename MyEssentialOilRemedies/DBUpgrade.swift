//
//  DBUpgrade.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 12/30/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

import Foundation

/// Upgrades the user's database schema to the version this app expects.
enum DBUpgrade {

    private static let versionTable = "DB_Version"

    /// Check the database version against the version the app expects and apply any upgrades needed.
    /// - Remark: USEDBY: MainStartViewController
    static func checkDBVersionAgainstExpectedVersion() {
        let dbPath = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
        let dbVersion = Double((try? BurnSoftDatabase.currentDatabaseVersion(fromTable: versionTable, databasePath: dbPath)) ?? "0") ?? 0

        guard MYSettings.dbVersion > dbVersion else {
            FormFunctions.doBuggermeMessage("DEBUG: DBVersion is equal to or greater than expected.", from: "DBUpgrade")
            return
        }
        FormFunctions.doBuggermeMessage("DEBUG: DBVersion is less than expected!!!", from: "DBUpgrade")

        if dbVersion == 1.1 {
            upgrade11(dbPath)
        } else if dbVersion == 1.2 {
            upgrade11(dbPath)
            upgrade12(dbPath)
            upgrade13(dbPath)
            upgrade14(dbPath)
        } else if dbVersion < 1.3 && dbVersion >= 1.2 {
            upgrade13(dbPath)
            upgrade14(dbPath)
        } else if dbVersion < 1.4 && dbVersion >= 1.3 {
            upgrade14(dbPath)
        }
    }

    // MARK: Upgrades

    /// Version 1.1: add the vendor columns.
    private static func upgrade11(_ dbPath: String) {
        applyPatch(1.1, dbPath: dbPath, statements: [
            "ALTER TABLE eo_oil_list_details ADD COLUMN vendor STRING(255);",
            "ALTER TABLE eo_oil_list_details ADD COLUMN vendor_site TEXT;",
            "DROP VIEW view_eo_oil_list_all",
            "CREATE VIEW view_eo_oil_list_all as SELECT ol.ID, ol.name, ol.INSTOCK, old.ID as DetailsID,old.description, old.BotanicalName,old.Ingredients, old.SafetyNotes, old.Color,old.Viscosity, old.CommonName, old.vendor, old.vendor_site from eo_oil_list ol inner join eo_oil_list_details old on old.OID=ol.ID",
        ])
    }

    /// Version 1.2: add the remedy name to the oils in remedy view.
    private static func upgrade12(_ dbPath: String) {
        applyPatch(1.2, dbPath: dbPath, statements: [
            "DROP VIEW view_oils_in_remedy",
            "CREATE VIEW view_oils_in_remedy as SELECT ro.RID,ol.name,ol.instock,ro.ID,ro.OID, rl.name as remedy from eo_remedy_oil_list ro inner join eo_oil_list ol on ol.id=ro.OID inner join eo_remedy_list rl on rl.id=ro.RID",
        ])
    }

    /// Version 1.3: add the blend and re-order columns.
    private static func upgrade13(_ dbPath: String) {
        applyPatch(1.3, dbPath: dbPath, statements: [
            "ALTER TABLE eo_oil_list_details ADD isBlend INTEGER;",
            "ALTER TABLE eo_oil_list_details ADD reorder INTEGER;",
            "Update eo_oil_list_details set isBlend=0;",
            "Update eo_oil_list_details set reorder=0;",
            "DROP VIEW view_eo_oil_list_all;",
            "CREATE VIEW view_eo_oil_list_all AS SELECT ol.ID, ol.name, ol.INSTOCK, old.ID as DetailsID,old.description, old.BotanicalName,old.Ingredients, old.SafetyNotes, old.Color,old.Viscosity, old.CommonName, old.vendor, old.vendor_site , old.isBlend, old.reorder from eo_oil_list ol inner join eo_oil_list_details old on old.OID=ol.ID;",
        ])
    }

    /// Version 1.4: turn off journaling. The version is only recorded if that succeeds.
    private static func upgrade14(_ dbPath: String) {
        let version = 1.4
        let title = String(format: "DB Version %.01f", version)
        guard !patchApplied(version, dbPath: dbPath) else { return }

        FormFunctions.doBuggermeMessage(String(format: "DEBUG: Start DBVersion Upgrade to version %.01f", version), from: "DBUpgrade")
        do {
            try BurnSoftDatabase.turnOffJournaling(dbPath)
        } catch {
            FormFunctions.checkForErrorLogOnly(error.localizedDescription, title: title)
            return
        }
        run(String(format: "INSERT INTO DB_Version (version) VALUES('%.01f')", version), dbPath: dbPath, title: title)
        FormFunctions.doBuggermeMessage(String(format: "DEBUG: End DBVersion Upgrade to version %.01f", version), from: "DBUpgrade")
    }

    // MARK: Helpers

    /// Run each statement, then record the new version in the version table.
    /// Errors are logged and don't stop the remaining statements, matching the original behavior.
    private static func applyPatch(_ version: Double, dbPath: String, statements: [String]) {
        let title = String(format: "DB Version %.01f", version)
        guard !patchApplied(version, dbPath: dbPath) else { return }

        FormFunctions.doBuggermeMessage(String(format: "DEBUG: Start DBVersion Upgrade to version %.01f", version), from: "DBUpgrade")
        for sql in statements {
            run(sql, dbPath: dbPath, title: title)
        }
        run(String(format: "INSERT INTO DB_Version (version) VALUES('%.01f')", version), dbPath: dbPath, title: title)
        FormFunctions.doBuggermeMessage(String(format: "DEBUG: End DBVersion Upgrade to version %.01f", version), from: "DBUpgrade")
    }

    /// True if the patch for this version has already been applied.
    private static func patchApplied(_ version: Double, dbPath: String) -> Bool {
        let exists = (try? BurnSoftDatabase.versionExists(String(format: "%f", version), versionTable: versionTable,
                                                          databasePath: dbPath)) ?? false
        if exists {
            FormFunctions.doBuggermeMessage(String(format: "DEBUG: Database has already had %.01f patch applied!", version), from: "DBUpgrade")
        }
        return exists
    }

    private static func run(_ sql: String, dbPath: String, title: String) {
        do {
            try BurnSoftDatabase.runQuery(sql, databasePath: dbPath)
        } catch {
            FormFunctions.checkForErrorLogOnly(error.localizedDescription, title: title)
        }
    }
}
