//
//  SearchDatabase.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 9/23/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

import Foundation

/// Database lookups used by the search screens.
enum SearchDatabase {

    /// All the oil names followed by all the remedy names, each sorted by name.
    static func allSearchDataSimple(databasePath: String) -> [String] {
        let oils = (try? names("select name from view_eo_oil_list_all order by name asc", databasePath: databasePath)) ?? []
        let remedies = (try? names("select name from eo_remedy_list order by name asc", databasePath: databasePath)) ?? []
        return oils + remedies
    }

    /// The ID of the oil with this name, or 0 if no oil has that name.
    /// Search results are combined, so this is used to work out whether a result is an oil or a remedy.
    static func oilID(byName name: String, databasePath: String) throws -> Int {
        try id("select id from eo_oil_list where name='\(name)'", databasePath: databasePath)
    }

    /// The ID of the remedy with this name, or 0 if no remedy has that name.
    static func remedyID(byName name: String, databasePath: String) throws -> Int {
        try id("select id from eo_remedy_list where name='\(name)'", databasePath: databasePath)
    }

    private static func names(_ sql: String, databasePath: String) throws -> [String] {
        let db = try SQLiteConnection(path: databasePath)
        var names: [String] = []
        try db.query(sql) { row in names.append(row.string(0)) }
        return names
    }

    private static func id(_ sql: String, databasePath: String) throws -> Int {
        let db = try SQLiteConnection(path: databasePath)
        var id = 0
        try db.query(sql) { row in id = row.int(0) }
        return id
    }
}
