//
//  SettingsiTunesBackupRestoreViewController.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 1/31/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

import UIKit

/// Local (iTunes/Finder file sharing) backups of the database in the Documents folder.
@objc(SettingsiTunesBackupRestoreViewController)
final class SettingsiTunesBackupRestoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var myTableView: UITableView?
    @IBOutlet weak var mainView: UIView?

    private var dbPathString = ""
    /// Names of the .bak files in Documents.
    private var backupFiles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        dbPathString = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
        loadFileListings()
        myTableView?.delegate = self
        myTableView?.dataSource = self

        FormFunctions.setBackGroundImage(view)
        FormFunctions.setBackGroundImage(mainView)
        FormFunctions.setBackGroundImage(myTableView)
    }

    private func reloadData() {
        dbPathString = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
        loadFileListings()
        myTableView?.reloadData()
    }

    private func loadFileListings() {
        let files = (try? FileManager.default.contentsOfDirectory(atPath: BurnSoftGeneral.documentsDirectory)) ?? []
        backupFiles = files.filter { $0.hasSuffix(".bak") }
    }

    private func documentsPath(for fileName: String) -> String {
        (BurnSoftGeneral.documentsDirectory as NSString).appendingPathComponent(fileName)
    }

    // MARK: Backup and Restore

    /// Copy the database to meo_backup_<date>.bak in Documents.
    @IBAction func btnBackUpDatabaseForiTunes(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH_mm_ss"
        let newDBName = documentsPath(for: "meo_backup_\(dateFormatter.string(from: Date())).bak")

        FormFunctions.doBuggermeMessage("DatabasePath: \(dbPathString)", from: "SettingsiTunesBackupRestoreViewController.btnBackUpDatabaseForiTunes")
        FormFunctions.doBuggermeMessage("New Database Name: \(newDBName)", from: "SettingsiTunesBackupRestoreViewController.btnBackUpDatabaseForiTunes")

        do {
            try FileManager.default.copyItem(atPath: dbPathString, toPath: newDBName)
            FormFunctions.sendMessage("Backup Successful!", title: "Success!", viewController: self)
        } catch {
            FormFunctions.sendMessage("Error backuping database: \(error.localizedDescription)", title: "Backup Error", viewController: self)
        }
        reloadData()
    }

    /// Restore the selected backup as the main database.
    private func restoreDatabase(fromFile fileName: String) {
        do {
            try FileManager.default.copyItem(atPath: documentsPath(for: fileName), toPath: dbPathString)
            FormFunctions.sendMessage("Restore Successful!", title: "Success!", viewController: self)
        } catch {
            FormFunctions.sendMessage("Error restoring database: \(error.localizedDescription)", title: "Restore Error", viewController: self)
        }
    }

    // MARK: Table View

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        backupFiles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = backupFiles[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let fileName = backupFiles[indexPath.row]

        let restoreAction = UIContextualAction(style: .destructive, title: "Restore") { [weak self] _, _, completion in
            guard let self else { return }
            if BurnSoftDatabase.resetDBDirectory() {
                restoreDatabase(fromFile: fileName)
            } else {
                FormFunctions.sendMessage("Unable to delete Main Database before copy", title: "Restore Error", viewController: self)
            }
            reloadData()
            completion(true)
        }
        restoreAction.backgroundColor = .blue

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self else { return }
            do {
                try FileManager.default.removeItem(atPath: documentsPath(for: fileName))
                FormFunctions.sendMessage("\(fileName) backup file was deleted!", title: "Backup Deleted", viewController: self)
            } catch {
                FormFunctions.sendMessage("Unable to delete backup file: \(fileName)!", title: "Backup Deleted Error", viewController: self)
            }
            reloadData()
            completion(true)
        }
        deleteAction.backgroundColor = .red

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, restoreAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
