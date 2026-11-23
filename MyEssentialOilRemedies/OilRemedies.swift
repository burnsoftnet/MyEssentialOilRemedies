//
//  OilRemedies.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

import Foundation

/// A remedy from the remedy list.
struct Remedy: Hashable {
    var rid = 0
    var name = ""
    var description = ""
    var uses = ""

    /// First letter of the name, used for the table sections and index.
    var section: String { String(name.prefix(1)) }
}

/// An oil that is used in a remedy.
struct RemedyOil: Hashable {
    var name: String
    var inStock: Bool
}

/// Database access for remedies and the oils tagged to them.
enum OilRemedies {

    /// Look up the remedy by name (case-insensitive) to see if it already exists in the database.
    static func remedyExists(named name: String, databasePath: String) throws -> Bool {
        let db = try SQLiteConnection(path: databasePath)
        var exists = false
        try db.query("select * from eo_remedy_list where name='\(name)' COLLATE NOCASE") { _ in exists = true }
        return exists
    }

    /// Look up the remedy ID by name.
    /// - Returns: The remedy ID, or 0 if it wasn't found.
    static func remedyID(byName name: String, databasePath: String) -> Int {
        (try? BurnSoftDatabase.lastEntryID(byName: BurnSoftGeneral.fcString(name), lookForColumn: "name", idColumn: "ID",
                                           table: "eo_remedy_list", databasePath: databasePath)) ?? 0
    }

    /// All the oils that have been tagged for a remedy.
    /// - Remark: View Remedies, Edit Remedies
    static func oils(forRemedyID rid: Int, databasePath: String) -> [RemedyOil] {
        guard let db = try? SQLiteConnection(path: databasePath) else { return [] }
        var oils: [RemedyOil] = []
        try? db.query("SELECT * from view_oils_in_remedy where RID=\(rid)") { row in
            oils.append(RemedyOil(name: row.string(1), inStock: row.int(2) == 1))
        }
        return oils
    }

    /// The names of all the oils that have been tagged for a remedy.
    /// - Remark: Edit Remedies
    static func oilNames(forRemedyID rid: Int, databasePath: String) -> [String] {
        oils(forRemedyID: rid, databasePath: databasePath).map(\.name)
    }

    /// All the remedies, sorted by name.
    static func allRemedies(databasePath: String) throws -> [Remedy] {
        let db = try SQLiteConnection(path: databasePath)
        var remedies: [Remedy] = []
        try db.query("select * from eo_remedy_list order by name COLLATE NOCASE ASC") { row in
            remedies.append(Remedy(rid: row.int(0), name: row.string(1), description: row.string(2), uses: row.string(3)))
        }
        return remedies
    }

    /// Checks to see if the oil already exists in the database by name.
    private static func oilNameExists(_ name: String, databasePath: String) throws -> Bool {
        try BurnSoftDatabase.dataExists(byQuery: "select * from eo_oil_list where lower(name)='\(name.lowercased())'",
                                        databasePath: databasePath)
    }

    /// Add the oil to the database if it isn't there already.
    /// - Returns: The ID of the new or existing oil, to be added to the remedy oil relations table.
    static func addOilName(_ name: String, databasePath: String) throws -> Int {
        let oilName = BurnSoftGeneral.fcString(name)
        if try !oilNameExists(oilName, databasePath: databasePath) {
            try BurnSoftDatabase.runQuery("INSERT INTO eo_oil_list (name) VALUES ('\(oilName)')", databasePath: databasePath)
            let oid = try lastOilID(named: oilName, databasePath: databasePath)
            try BurnSoftDatabase.runQuery("INSERT INTO eo_oil_list_details (OID,description,isBlend,reorder) VALUES(\(oid),'N/A',0,0)",
                                          databasePath: databasePath)
            return oid
        }
        return try lastOilID(named: oilName, databasePath: databasePath)
    }

    private static func lastOilID(named name: String, databasePath: String) throws -> Int {
        try BurnSoftDatabase.lastEntryID(byName: name, lookForColumn: "name", idColumn: "ID",
                                         table: "eo_oil_list", databasePath: databasePath)
    }

    /// Add an oil to the remedy oil relations table.
    static func addOilToRemedyOilList(oilID: Int, remedyID: Int, databasePath: String) throws {
        try BurnSoftDatabase.runQuery("INSERT INTO eo_remedy_oil_list (OID,RID) VALUES(\(oilID),\(remedyID))",
                                      databasePath: databasePath)
    }

    /// Add the remedy to the database.
    /// - Returns: The new remedy ID.
    static func addRemedyDetails(name: String, description: String, uses: String, databasePath: String) throws -> Int {
        let f = BurnSoftGeneral.fcString
        try BurnSoftDatabase.runQuery("INSERT INTO eo_remedy_list (name,description,uses) VALUES('\(f(name))','\(f(description))','\(f(uses))')",
                                      databasePath: databasePath)
        return try BurnSoftDatabase.lastEntryID(byName: f(name), lookForColumn: "name", idColumn: "ID",
                                                table: "eo_remedy_list", databasePath: databasePath)
    }

    /// Update the remedy details.
    static func updateRemedyDetails(rid: Int, name: String, description: String, uses: String, databasePath: String) throws {
        let f = BurnSoftGeneral.fcString
        try BurnSoftDatabase.runQuery("update eo_remedy_list set name='\(f(name))',description='\(f(description))',uses='\(f(uses))' where ID=\(rid)",
                                      databasePath: databasePath)
    }

    /// Delete the remedy and the oil links tagged to it, without deleting the oils themselves.
    static func deleteRemedy(id rid: Int, databasePath: String) throws {
        try clearOilsPerRemedy(rid: rid, databasePath: databasePath)
        try BurnSoftDatabase.runQuery("DELETE from eo_remedy_list where ID=\(rid)", databasePath: databasePath)
    }

    /// Delete all the oil links in the remedy oil list table that are tied to the remedy.
    static func clearOilsPerRemedy(rid: Int, databasePath: String) throws {
        try BurnSoftDatabase.runQuery("delete from eo_remedy_oil_list where RID=\(rid)", databasePath: databasePath)
    }

    /// Add each oil in the list to the remedy, adding the oil to the database first if needed.
    static func addOils(toRemedyID rid: Int, oils: [String], databasePath: String) {
        for name in oils {
            // addOilName escapes the name, so only trim it here (escaping twice doubled apostrophes).
            let oilName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let oid = try? addOilName(oilName, databasePath: databasePath) else { continue }
            try? addOilToRemedyOilList(oilID: oid, remedyID: rid, databasePath: databasePath)
        }
    }
}
