//
//  BurnSoftGeneral.swift
//  BurnSoftGeneral
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

import Foundation

/// General string and file system helpers.
enum BurnSoftGeneral {

    // MARK: Strings

    /// Fluff/prep the string for inserting into a database.
    /// Doubles single quotes, turns backticks into escaped single quotes, and trims whitespace.
    static func fcString(_ value: String) -> String {
        value.replacingOccurrences(of: "'", with: "''")
            .replacingOccurrences(of: "`", with: "''")
            .trimmingCharacters(in: .whitespaces)
    }

    /// Fluff/prep the string for inserting into a database and an XML file.
    /// Same as `fcString(_:)` but also escapes ampersands.
    static func fcStringXML(_ value: String) -> String {
        value.replacingOccurrences(of: "'", with: "''")
            .replacingOccurrences(of: "`", with: "''")
            .replacingOccurrences(of: "&", with: "&amp;")
            .trimmingCharacters(in: .whitespaces)
    }

    /// Convert a boolean value to the string "Yes" or "No".
    static func boolString(_ value: Bool) -> String {
        value ? "Yes" : "No"
    }

    /// Convert a decimal string to a number, or nil if it isn't a number.
    static func number(from value: String) -> NSNumber? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: value)
    }

    // MARK: Directories

    /// The app's Documents directory.
    static var documentsDirectory: String {
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }

    /// The Documents/Inbox/ directory where AirDropped and emailed files arrive.
    static var inboxDirectory: String {
        documentsDirectory + "/Inbox/"
    }

    /// Clear the document inbox so an old version of a drop doesn't keep a newer version from being processed.
    static func clearDocumentInBox() {
        let inbox = inboxDirectory
        let files = (try? FileManager.default.contentsOfDirectory(atPath: inbox)) ?? []
        for file in files {
            try? FileManager.default.removeItem(atPath: inbox + file)
        }
    }

    /// Returns true if there are files in the inbox waiting to be processed (normally from an AirDrop).
    static func newFilesFoundProcessing() -> Bool {
        let files = (try? FileManager.default.contentsOfDirectory(atPath: inboxDirectory)) ?? []
        return !files.isEmpty
    }

    // MARK: Files

    /// Copy a file, replacing the destination if it already exists.
    static func copyFile(from source: String, to destination: String) throws {
        let fileManager = FileManager.default
        let sourceExists = fileManager.fileExists(atPath: source)
        let destinationExists = fileManager.fileExists(atPath: destination)

        guard sourceExists || destinationExists else {
            throw DatabaseError(message: "File doesn't exist in source or destination!")
        }
        if sourceExists && destinationExists {
            do {
                try deleteFile(atPath: destination)
            } catch {
                throw DatabaseError(message: "Delete Error: \(error.localizedDescription)")
            }
        }
        do {
            try fileManager.copyItem(atPath: source, toPath: destination)
        } catch {
            throw DatabaseError(message: "Error copying file: \(error.localizedDescription)")
        }
    }

    /// Delete the file at the path. Succeeds without doing anything if the file doesn't exist.
    static func deleteFile(atPath path: String) throws {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path) else { return }
        do {
            try fileManager.removeItem(atPath: path)
        } catch {
            throw DatabaseError(message: "Error deleting database: \(error.localizedDescription)")
        }
    }

    /// Create a directory if it doesn't already exist.
    static func createDirectoryIfNotExists(_ path: String) throws {
        guard !FileManager.default.fileExists(atPath: path) else { return }
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
        } catch {
            throw DatabaseError(message: error.localizedDescription)
        }
    }
}
