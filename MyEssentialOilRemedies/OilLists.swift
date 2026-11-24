//
//  OilLists.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

import Foundation

/// An oil from the oil list, with its details.
struct Oil: Hashable {
    var oid = 0
    var name = ""
    var description = ""
    var inStock = false
    var detailsID = ""
    var isBlend = false
    var isReOrder = false
    var botanicalName = ""
    var ingredients = ""
    var safetyNotes = ""
    var color = ""
    var viscosity = ""
    var commonName = ""
    var vendor = ""
    var vendorWebSite = ""

    /// First letter of the name, used for the table sections and index.
    var section: String { String(name.prefix(1)) }
}

/// The editable details of an oil (the eo_oil_list_details table).
struct OilDetails {
    var description = ""
    var botanicalName = ""
    var ingredients = ""
    var safetyNotes = ""
    var color = ""
    var viscosity = ""
    var commonName = ""
    var vendor = ""
    var website = ""
    var isBlend = false
}

/// A remedy that uses an oil.
struct RelatedRemedy: Hashable {
    var rid: Int
    var name: String
}

/// Database access for the oil list.
enum OilLists {

    /// Columns every oil list query must return, in this order.
    private static let oilColumns = "name,description,INSTOCK,ID,DetailsID,isBlend,reorder,BotanicalName,Ingredients,SafetyNotes,Color,Viscosity,CommonName,vendor,vendor_site"

    /// Look up the oil by name (case-insensitive) to see if it already exists in the database.
    /// - Remark: Used in AirDropHandler, OilLists, ADD_OilDetailsViewController
    static func oilExists(named name: String, databasePath: String) throws -> Bool {
        let db = try SQLiteConnection(path: databasePath)
        var exists = false
        try db.query("select * from eo_oil_list where name='\(name)' COLLATE NOCASE") { _ in exists = true }
        return exists
    }

    /// Gets the list of remedies that have the oil listed in the oils-to-remedy table.
    /// This does not include anything in the uses and description sections.
    static func remediesRelated(toOilID oid: Int, databasePath: String) throws -> [RelatedRemedy] {
        let db = try SQLiteConnection(path: databasePath)
        var remedies: [RelatedRemedy] = []
        try db.query("select rid,remedy from view_oils_in_remedy where OID=\(oid) order by name COLLATE NOCASE ASC") { row in
            remedies.append(RelatedRemedy(rid: row.int(0), name: row.string(1)))
        }
        return remedies
    }

    /// Get all the oils in the database, sorted by name.
    static func allOils(databasePath: String) throws -> [Oil] {
        try oils(where: nil, databasePath: databasePath)
    }

    /// Get the oils that are marked for re-order.
    static func oilsForReOrder(databasePath: String) throws -> [Oil] {
        try oils(where: "reorder=1", databasePath: databasePath)
    }

    private static func oils(where condition: String?, databasePath: String) throws -> [Oil] {
        let filter = condition.map { " where \($0)" } ?? ""
        let sql = "select \(oilColumns) from view_eo_oil_list_all\(filter) order by name COLLATE NOCASE ASC"
        let db = try SQLiteConnection(path: databasePath)
        var oils: [Oil] = []
        try db.query(sql) { row in
            oils.append(Oil(oid: row.int(3),
                            name: row.string(0),
                            description: row.string(1),
                            inStock: row.int(2) == 1,
                            detailsID: row.string(4),
                            isBlend: row.int(5) == 1,
                            isReOrder: row.int(6) == 1,
                            botanicalName: row.string(7),
                            ingredients: row.string(8),
                            safetyNotes: row.string(9),
                            color: row.string(10),
                            viscosity: row.string(11),
                            commonName: row.string(12),
                            vendor: row.string(13),
                            vendorWebSite: row.string(14)))
        }
        return oils
    }

    // MARK: Counts

    /// Number of oils in the list that are in stock.
    static func inStockCount(in oils: [Oil]) -> Int {
        oils.filter(\.inStock).count
    }

    /// Number of oils in the list that are marked for re-order.
    static func shoppingCount(in oils: [Oil]) -> Int {
        oils.filter(\.isReOrder).count
    }

    /// Number of oils in the database that are in stock.
    static func inStockCount(databasePath: String) throws -> Int {
        try count("select count(*) from view_eo_oil_list_all where INSTOCK=1", databasePath: databasePath)
    }

    /// Number of oils in the database that are marked for order or re-order.
    static func shoppingCount(databasePath: String) throws -> Int {
        try count("select count(*) from view_eo_oil_list_all where reorder=1", databasePath: databasePath)
    }

    private static func count(_ sql: String, databasePath: String) throws -> Int {
        let db = try SQLiteConnection(path: databasePath)
        var count = 0
        try db.query(sql) { row in count = row.int(0) }
        return count
    }

    // MARK: Updates

    /// Update the oil stock status.
    static func updateStockStatus(_ inStock: Bool, oilID: Int, databasePath: String) throws {
        try BurnSoftDatabase.runQuery("update eo_oil_list set INSTOCK=\(inStock ? 1 : 0) where ID=\(oilID)", databasePath: databasePath)
    }

    /// Update the blend status.
    /// - Note: The Objective-C version matched on the details table's own `ID` column; the details row is keyed to the oil by `OID`.
    static func updateBlendStatus(_ isBlend: Bool, oilID: Int, databasePath: String) throws {
        try BurnSoftDatabase.runQuery("update eo_oil_list_details set isBlend=\(isBlend ? 1 : 0) where OID=\(oilID)", databasePath: databasePath)
    }

    /// Get the oil ID by name. If the oil doesn't exist yet it is inserted first.
    /// - Returns: The oil ID, or 0 if it couldn't be found or added.
    static func oilID(byName name: String, inStock: Bool, databasePath: String) throws -> Int {
        let escapedName = BurnSoftGeneral.fcString(name)
        let exists = (try? oilExists(named: escapedName, databasePath: databasePath)) ?? false
        if !exists {
            try BurnSoftDatabase.runQuery("INSERT INTO eo_oil_list (name,instock) VALUES ('\(escapedName)',\(inStock ? 1 : 0))",
                                          databasePath: databasePath)
        }
        return (try? BurnSoftDatabase.lastEntryID(byName: escapedName, lookForColumn: "name", idColumn: "ID",
                                                  table: "eo_oil_list", databasePath: databasePath)) ?? 0
    }

    /// Get the oil name from the database based on the oil ID.
    static func oilName(byID oid: Int, databasePath: String) throws -> String {
        let db = try SQLiteConnection(path: databasePath)
        var name = ""
        try db.query("SELECT name FROM eo_oil_list where id=\(oid)") { row in
            if !row.isNull(0) { name = row.string(0) }
        }
        return name
    }

    /// Insert the oil details for an oil.
    static func insertOilDetails(oid: Int, details: OilDetails, databasePath: String) throws {
        let f = BurnSoftGeneral.fcString
        let sql = "INSERT INTO eo_oil_list_details (OID,description,BotanicalName,Ingredients,SafetyNotes,Color,Viscosity,CommonName,vendor,vendor_site,isBlend) VALUES(\(oid),'\(f(details.description))','\(f(details.botanicalName))','\(f(details.ingredients))','\(f(details.safetyNotes))','\(f(details.color))','\(f(details.viscosity))','\(f(details.commonName))','\(f(details.vendor))','\(f(details.website))',\(details.isBlend ? 1 : 0))"
        try BurnSoftDatabase.runQuery(sql, databasePath: databasePath)
    }

    /// Update the oil details for an oil.
    static func updateOilDetails(oid: Int, details: OilDetails, databasePath: String) throws {
        let f = BurnSoftGeneral.fcString
        let sql = "UPDATE eo_oil_list_details set description='\(f(details.description))',BotanicalName='\(f(details.botanicalName))',Ingredients='\(f(details.ingredients))',SafetyNotes='\(f(details.safetyNotes))',Color='\(f(details.color))',Viscosity='\(f(details.viscosity))',CommonName='\(f(details.commonName))',vendor='\(f(details.vendor))',vendor_site='\(f(details.website))',isBlend=\(details.isBlend ? 1 : 0) where OID=\(oid)"
        try BurnSoftDatabase.runQuery(sql, databasePath: databasePath)
    }
}
