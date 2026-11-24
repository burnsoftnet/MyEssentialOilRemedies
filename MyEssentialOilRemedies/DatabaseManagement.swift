//
//  DatabaseManagement.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 1/30/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//  Version 3.0
//

import Foundation

/// Backs up and restores the database to and from the iCloud Drive container.
enum DatabaseManagement {

    /// Extension of the backup stored in iCloud.
    static let backupExtension = "zip"
    /// Extension of the local database.
    static let databaseExtension = "db"
    /// Name of the database in both the backup location and locally.
    static let databaseName = "MEO"

    private static func bugMe(_ message: String, from location: String) {
        FormFunctions.doBuggermeMessage(message, from: "DatabaseManagement.\(location)")
    }

    // MARK: iCloud Paths

    /// The Documents folder in the app's iCloud container, created if needed.
    /// - Throws: If iCloud isn't available on this device.
    private static func iCloudDocumentsPath() throws -> String {
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            throw DatabaseError(message: "iCloud Drive is not available.")
        }
        let path = containerURL.path + "/Documents"
        try BurnSoftGeneral.createDirectoryIfNotExists(path)
        return path
    }

    /// The path of the iCloud backup for the database, with its extension replaced by `newExtension`.
    private static func iCloudBackupPath(forDBName dbName: String, extension newExtension: String) throws -> String {
        try iCloudDocumentsPath() + "/" + replacingExtension(of: dbName, with: newExtension)
    }

    /// Replace the database extension of a file name or path with another extension.
    private static func replacingExtension(of path: String, with newExtension: String) -> String {
        let nsPath = path as NSString
        guard nsPath.pathExtension == databaseExtension else { return path }
        return nsPath.deletingPathExtension + "." + newExtension
    }

    // MARK: Conflicts

    /// Every device that backs up the database to iCloud gets its own version, which causes conflicts when
    /// restoring on another device. This removes the other and conflicting versions so the latest one is restored.
    private static func removeConflictVersions(at url: URL) {
        loadFileListings()
        bugMe("\(url)", from: "removeConflictVersions")
        do {
            try NSFileVersion.removeOtherVersionsOfItem(at: url)
            bugMe("older versions were removed!", from: "removeConflictVersions")
        } catch {
            bugMe("Problems removing older versions!", from: "removeConflictVersions")
            bugMe(error.localizedDescription, from: "removeConflictVersions")
        }
        for version in NSFileVersion.unresolvedConflictVersionsOfItem(at: url) ?? [] {
            version.isResolved = true
            NSLog("REMOVED! %@", version.localizedName ?? "")
        }
    }

    /// Delete any extra backup files in the iCloud container, keeping only the main backup.
    private static func loadFileListings() {
        guard let documents = try? iCloudDocumentsPath() else { return }
        let files = (try? FileManager.default.contentsOfDirectory(atPath: documents)) ?? []
        let mainBackup = "\(databaseName).\(backupExtension)"
        for file in files where file.hasSuffix(".\(backupExtension)") {
            bugMe(file, from: "loadFileListings")
            if file != mainBackup {
                try? BurnSoftGeneral.deleteFile(atPath: documents + "/" + file)
            }
        }
    }

    // MARK: Backup and Restore

    /// Back up the database to the iCloud container.
    static func backupDatabaseToiCloud(dbName: String, localDatabasePath dbPath: String) throws {
        let backupFile = replacingExtension(of: dbPath, with: backupExtension)
        let newDBName = try iCloudBackupPath(forDBName: dbName, extension: backupExtension)
        defer {
            removeConflictVersions(at: URL(fileURLWithPath: newDBName))
            try? BurnSoftGeneral.deleteFile(atPath: backupFile)
        }
        do {
            try performCopy(from: dbPath, via: backupFile, to: newDBName)
        } catch {
            logError("backupDatabaseToiCloud", error)
            throw DatabaseError(message: "Error backuping database: \(error.localizedDescription)")
        }
    }

    /// Restore the database from iCloud Drive.
    static func restoreDatabaseFromiCloud(dbName: String, localDatabasePath dbPath: String) throws {
        do {
            let newDBName = try iCloudBackupPath(forDBName: dbName, extension: backupExtension)
            let backupFile = replacingExtension(of: dbPath, with: backupExtension)
            removeConflictVersions(at: URL(fileURLWithPath: newDBName))

            guard FileManager.default.fileExists(atPath: newDBName) else {
                throw DatabaseError(message: "The iCloud Backup does not Exist!")
            }
            BurnSoftDatabase.resetDBDirectory()

            do {
                try performCopy(from: newDBName, via: backupFile, to: dbPath)
            } catch {
                throw DatabaseError(message: "Error restoring database: \(error.localizedDescription)")
            }
            do {
                try BurnSoftGeneral.deleteFile(atPath: backupFile)
            } catch {
                throw DatabaseError(message: "Error deleting \(backupFile) database: \(error.localizedDescription)")
            }
        } catch {
            logError("restoreDatabaseFromiCloud", error)
            throw error
        }
    }

    /// Copy the first file to the second location, then copy that over to the final destination.
    private static func performCopy(from source: String, via intermediate: String, to destination: String) throws {
        bugMe("Target 1 Value: \(source)", from: "performCopy")
        bugMe("Target 2 Value: \(intermediate)", from: "performCopy")
        bugMe("Target 3 Value: \(destination)", from: "performCopy")

        try BurnSoftGeneral.copyFile(from: source, to: intermediate)
        do {
            try BurnSoftGeneral.copyFile(from: intermediate, to: destination)
        } catch {
            throw DatabaseError(message: "Error coping the database \(error.localizedDescription)")
        }
    }

    // MARK: Sync

    /// Start downloading the backup from the iCloud container. This needs to run when the app starts and before
    /// a restore, to make sure the latest version has been downloaded from the cloud.
    static func startiCloudSync() {
        do {
            let url = URL(fileURLWithPath: try iCloudBackupPath(forDBName: MYSettings.dbName, extension: backupExtension))
            removeConflictVersions(at: url)
            try FileManager.default.startDownloadingUbiquitousItem(at: url)
            bugMe("sync started!", from: "startiCloudSync")
        } catch {
            NSLog("ERROR - %@", error.localizedDescription)
            logError("startiCloudSync", error)
        }
    }

    private static func logError(_ location: String, _ error: Error) {
        FormFunctions.logError(from: "DatabaseManagement.\(location)", error: error)
    }
}
