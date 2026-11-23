//
//  SettingsViewController.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/30/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

import UIKit

@objc(SettingsViewController)
final class SettingsViewController: UIViewController {

    @IBOutlet weak var btnClearOils: UIButton?
    @IBOutlet weak var btnClearRemedies: UIButton?
    @IBOutlet weak var btnRestoreFactory: UIButton?
    @IBOutlet weak var btnBackuptoiCloud: UIButton?
    @IBOutlet weak var btnRestoreFromiCloud: UIButton?
    @IBOutlet weak var btnDoiTunesBackup: UIButton?
    @IBOutlet weak var viewMain: UIView?
    @IBOutlet weak var lblAppVersion: UILabel?
    @IBOutlet weak var lblDBVersion: UILabel?

    private var dbPathString = ""

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        loadVersioning()
        FormFunctions.setBackGroundImage(view)
        FormFunctions.setBackGroundImage(viewMain)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSettings()
        loadVersioning()
    }

    private func loadSettings() {
        dbPathString = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
        DatabaseManagement.startiCloudSync()
        [btnClearOils, btnClearRemedies, btnRestoreFactory, btnBackuptoiCloud, btnRestoreFromiCloud, btnDoiTunesBackup]
            .forEach(FormFunctions.setBorderButton)
    }

    /// Show the app version and the database version.
    private func loadVersioning() {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        lblAppVersion?.text = "\(appVersion).\(appBuild)"
        lblDBVersion?.text = (try? BurnSoftDatabase.currentDatabaseVersion(fromTable: "DB_Version", databasePath: dbPathString)) ?? "0"
    }

    // MARK: iCloud

    /// Back up the database to iCloud Drive.
    @IBAction func btnBackuptoiCloud(_ sender: Any) {
        try? BurnSoftDatabase.updateDatabaseForiCloudBackup(dbPathString)
        do {
            try DatabaseManagement.backupDatabaseToiCloud(dbName: MYSettings.dbName, localDatabasePath: dbPathString)
            FormFunctions.sendMessage("Databae Backup was successful!", title: "Success!", viewController: self)
        } catch {
            FormFunctions.sendMessage(error.localizedDescription, title: "ERROR!", viewController: self)
        }
        DatabaseManagement.startiCloudSync()
    }

    /// Restore the database from iCloud Drive, then upgrade it if it's from an older version.
    @IBAction func btnRestoreFromiCloud(_ sender: Any) {
        DatabaseManagement.startiCloudSync()
        do {
            try DatabaseManagement.restoreDatabaseFromiCloud(dbName: MYSettings.dbName, localDatabasePath: dbPathString)
            DBUpgrade.checkDBVersionAgainstExpectedVersion()
            FormFunctions.sendMessage("Databae Restore was successful!", title: "Success!", viewController: self)
        } catch {
            FormFunctions.sendMessage(error.localizedDescription, title: "ERROR!", viewController: self)
        }
    }

    // MARK: Clear and Restore

    @IBAction func btnClearOils(_ sender: Any) {
        confirm(title: "Clear Oils", message: "Do you wish to clear out all the oils from the database?",
                action: "Purify it!", then: clearDataOil)
    }

    @IBAction func btnClearRemedies(_ sender: Any) {
        confirm(title: "Clear Remedies", message: "Do you wish to clear out all the Remedies from the database?",
                action: "Purify it!", then: clearDataRemedy)
    }

    @IBAction func btnRestoreFactory(_ sender: Any) {
        confirm(title: "Restore Factory Database", message: "Do you want to restore the the factory Database?",
                action: "Restore!", then: restoreFactoryDatabase)
    }

    private func confirm(title: String, message: String, action: String, then handler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default) { _ in handler() })
        alert.addAction(UIAlertAction(title: "Never Mind", style: .default))
        present(alert, animated: true)
    }

    private func clearDataOil() {
        for sql in ["DELETE from eo_remedy_oil_list", "DELETE from eo_oil_list_details", "DELETE from eo_oil_list"] {
            try? BurnSoftDatabase.runQuery(sql, databasePath: dbPathString)
        }
        FormFunctions.sendMessage("Data Cleared", title: "This database is clean!", viewController: self)
    }

    private func clearDataRemedy() {
        for sql in ["DELETE from eo_remedy_oil_list", "DELETE from eo_remedy_list"] {
            try? BurnSoftDatabase.runQuery(sql, databasePath: dbPathString)
        }
        FormFunctions.sendMessage("Data Cleared", title: "This database is clean!", viewController: self)
    }

    private func restoreFactoryDatabase() {
        try? BurnSoftDatabase.restoreFactoryDB(MYSettings.dbName)
        FormFunctions.sendMessage("Restore Factory Database", title: "DB Restored to Factory.", viewController: self)
    }
}
