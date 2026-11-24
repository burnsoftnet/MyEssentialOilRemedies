//
//  BurnSoftDatabase.swift
//  BurnSoftDatabase
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

import Foundation
import SQLite3

/// Error raised by the database and file helpers. The message is what gets shown to the user or logged.
nonisolated struct DatabaseError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

// MARK: - SQLite Connection

/// A SQLite connection that stays open only for the lifetime of the object.
/// Every query in the app opens the database, runs, and closes it again, so this wrapper
/// guarantees the close happens on every path (including errors).
nonisolated final class SQLiteConnection {
    private var handle: OpaquePointer?

    init(path: String) throws {
        guard sqlite3_open(path, &handle) == SQLITE_OK else {
            let message = String(cString: sqlite3_errmsg(handle))
            sqlite3_close(handle)
            handle = nil
            throw DatabaseError(message: "Error occured while attempting to connect to database! \(message)")
        }
    }

    deinit {
        sqlite3_close(handle)
    }

    /// The last error message reported by SQLite for this connection.
    var lastErrorMessage: String {
        String(cString: sqlite3_errmsg(handle))
    }

    /// Execute a statement that does not return rows.
    func execute(_ sql: String) throws {
        guard sqlite3_exec(handle, sql, nil, nil, nil) == SQLITE_OK else {
            throw DatabaseError(message: "Error while executing query: \(lastErrorMessage)")
        }
    }

    /// Prepare and step through a query, calling `body` once for every returned row.
    func query(_ sql: String, _ body: (SQLiteRow) throws -> Void) throws {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK else {
            throw DatabaseError(message: "Error while executing statement! \(lastErrorMessage)")
        }
        defer { sqlite3_finalize(statement) }
        while sqlite3_step(statement) == SQLITE_ROW {
            try body(SQLiteRow(statement: statement))
        }
    }
}

/// Column accessors for the current row of a prepared statement.
nonisolated struct SQLiteRow {
    fileprivate let statement: OpaquePointer?

    /// True if the column value is NULL.
    func isNull(_ column: Int32) -> Bool {
        sqlite3_column_type(statement, column) == SQLITE_NULL
    }

    /// The column as text, or an empty string if the column is NULL.
    func string(_ column: Int32) -> String {
        guard let text = sqlite3_column_text(statement, column) else { return "" }
        return String(cString: text)
    }

    /// The column as an integer (NULL is returned as 0).
    func int(_ column: Int32) -> Int {
        Int(sqlite3_column_int64(statement, column))
    }
}

// MARK: - BurnSoftDatabase

/// General database helpers shared across the app.
enum BurnSoftDatabase {

    // MARK: Paths

    /// The directory where the database is stored (Documents/data/).
    static var databaseDirectory: String {
        BurnSoftGeneral.documentsDirectory + "/data/"
    }

    /// Delete the database directory and all the files in it, and recreate the directory empty.
    @discardableResult
    static func resetDBDirectory() -> Bool {
        let fileManager = FileManager.default
        let dbPath = databaseDirectory
        guard (try? fileManager.removeItem(atPath: dbPath)) != nil,
              !fileManager.fileExists(atPath: dbPath) else {
            return false
        }
        return (try? fileManager.createDirectory(atPath: dbPath, withIntermediateDirectories: true)) != nil
    }

    /// Pass the database name to get the full path of the database.
    /// The first time this runs it creates the data directory and moves a database from the
    /// old location (Documents/) into it.
    static func databasePath(for dbName: String) -> String {
        let fileManager = FileManager.default
        let docPath = BurnSoftGeneral.documentsDirectory
        let dbPath = databaseDirectory
        let fullDBPath = (dbPath as NSString).appendingPathComponent(dbName)

        if !fileManager.fileExists(atPath: dbPath),
           (try? fileManager.createDirectory(atPath: dbPath, withIntermediateDirectories: true)) != nil {
            let oldPath = (docPath as NSString).appendingPathComponent(dbName)
            if (try? fileManager.moveItem(atPath: oldPath, toPath: fullDBPath)) != nil {
                try? fileManager.removeItem(atPath: (docPath as NSString).appendingPathComponent("MEO.db-shm"))
                try? fileManager.removeItem(atPath: (docPath as NSString).appendingPathComponent("MEO.db-wal"))
            }
        }
        return fullDBPath
    }

    /// Copy the factory database from the app bundle to the data directory if it isn't there yet.
    static func copyDbIfNeeded(_ dbName: String) throws {
        let fileManager = FileManager.default
        let docsPath = databasePath(for: dbName)
        guard !fileManager.fileExists(atPath: docsPath) else { return }
        guard let resourcePath = Bundle.main.resourcePath else {
            throw DatabaseError(message: "Error coping database: the app bundle could not be found.")
        }
        do {
            try fileManager.copyItem(atPath: (resourcePath as NSString).appendingPathComponent(dbName), toPath: docsPath)
        } catch {
            throw DatabaseError(message: "Error coping database: \(error.localizedDescription).")
        }
    }

    /// Restore the factory database by deleting the database in the user docs and copying it back over.
    static func restoreFactoryDB(_ dbName: String) throws {
        let docsPath = databasePath(for: dbName)
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: docsPath) else { return }
        do {
            try fileManager.removeItem(atPath: docsPath)
        } catch {
            throw DatabaseError(message: "Error deleting database: \(error.localizedDescription)")
        }
        try copyDbIfNeeded(dbName)
    }

    // MARK: Statements

    /// Execute a SQL statement against the database at `databasePath`.
    static func runQuery(_ sql: String, databasePath: String) throws {
        let db = try SQLiteConnection(path: databasePath)
        try db.execute(sql)
    }

    /// Returns true if the first column of the first row returned by `sql` is greater than zero.
    static func dataExists(byQuery sql: String, databasePath: String) throws -> Bool {
        let db = try SQLiteConnection(path: databasePath)
        var value: Int?
        try db.query(sql) { row in
            if value == nil { value = row.int(0) }
        }
        return (value ?? 0) > 0
    }

    /// Look up the ID of the most recent row in `table` whose `searchColumn` matches `name` (case-insensitive).
    /// - Returns: The ID, or 0 if nothing was found.
    static func lastEntryID(byName name: String, lookForColumn searchColumn: String, idColumn: String,
                            table: String, databasePath: String) throws -> Int {
        let sql = "SELECT \(idColumn) from \(table) where lower(\(searchColumn))='\(name.lowercased())' order by \(idColumn) desc limit 1"
        let db = try SQLiteConnection(path: databasePath)
        var id = 0
        try db.query(sql) { row in id = row.int(0) }
        return id
    }

    /// Get the current database version, used to see if the database needs to be upgraded.
    static func currentDatabaseVersion(fromTable table: String, databasePath: String) throws -> String {
        let db = try SQLiteConnection(path: databasePath)
        var version = "0"
        try db.query("select version from \(table) order by id desc limit 1") { row in
            version = row.string(0)
        }
        return version
    }

    /// Returns true if `version` has already been recorded in the version table.
    static func versionExists(_ version: String, versionTable table: String, databasePath: String) throws -> Bool {
        let db = try SQLiteConnection(path: databasePath)
        var exists = false
        try db.query("select * from \(table) where version=\(version)") { _ in exists = true }
        return exists
    }

    /// Get the total number of rows in a table.
    static func totalRows(inTable table: String, databasePath: String) throws -> Int {
        let db = try SQLiteConnection(path: databasePath)
        var count = 0
        try db.query("select count(*) as mytotal from \(table)") { row in count = row.int(0) }
        return count
    }

    /// Add and drop a table to change the modified date on the file, since adding data doesn't
    /// always change the date (needed so iCloud picks up the new backup).
    static func updateDatabaseForiCloudBackup(_ databasePath: String) throws {
        try? runQuery("DROP TABLE IF EXISTS TEMPUPDATE;", databasePath: databasePath)
        try runQuery("CREATE TABLE IF NOT EXISTS TEMPUPDATE (id INTEGER PRIMARY KEY);", databasePath: databasePath)
    }

    /// Turn off journaling in the SQLite database.
    static func turnOffJournaling(_ databasePath: String) throws {
        try runQuery("PRAGMA journal_mode=OFF;", databasePath: databasePath)
    }
}
