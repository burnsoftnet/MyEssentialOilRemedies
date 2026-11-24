//
//  AirDropHandler.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 5/1/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

import UIKit

/// Imports oils and remedies that arrive in the Documents/Inbox folder via AirDrop or email.
enum AirDropHandler {

    /// Import the data from an oil (.meo) or remedy (.meor) file, asking the user first.
    static func openFile(atPath filePath: String, viewController: UIViewController) {
        let parser = Parser(xmlFile: filePath)
        let dbPath = BurnSoftDatabase.databasePath(for: MYSettings.dbName)

        if parser.isOil {
            confirmOilImport(parser, dbPath: dbPath, viewController: viewController)
        } else if parser.isRemedy {
            confirmRemedyImport(parser, dbPath: dbPath, viewController: viewController)
        }
    }

    private static func confirmOilImport(_ parser: Parser, dbPath: String, viewController: UIViewController) {
        let oilName = parser.oilName
        let oilExists = (try? OilLists.oilExists(named: oilName, databasePath: dbPath)) ?? false
        let title = oilExists ? "Oil Exists!" : "Add New Oil?"
        let message = oilExists
            ? "\(oilName) already exists!  Do you wish to replace theRemedy you have with this one?"
            : "Do you wish to add \(oilName) to your oil collection?"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            defer { BurnSoftGeneral.clearDocumentInBox() }
            let oid = (try? OilLists.oilID(byName: oilName, inStock: false, databasePath: dbPath)) ?? 0
            guard oid != 0 else {
                FormFunctions.sendMessage("Import of \(oilName) oil had an error getting existing Oil ID .",
                                          title: "Import Error!", viewController: viewController)
                return
            }
            do {
                if oilExists {
                    try OilLists.updateOilDetails(oid: oid, details: parser.oilDetails, databasePath: dbPath)
                } else {
                    try OilLists.insertOilDetails(oid: oid, details: parser.oilDetails, databasePath: dbPath)
                }
                FormFunctions.sendMessage("Import of \(oilName) oil details was completed.",
                                          title: "Import Complete", viewController: viewController)
            } catch {
                FormFunctions.sendMessage("Import of \(oilName) oil was had an error on details insert.",
                                          title: "Import Error!", viewController: viewController)
            }
        })
        alert.addAction(UIAlertAction(title: "No", style: .default) { _ in
            BurnSoftGeneral.clearDocumentInBox()
            FormFunctions.sendMessage("Import of \(oilName) oil was aborted.", title: "Import Aborted!", viewController: viewController)
        })
        viewController.present(alert, animated: true)
    }

    private static func confirmRemedyImport(_ parser: Parser, dbPath: String, viewController: UIViewController) {
        let remedyName = parser.remedyName
        let remedyExists = (try? OilRemedies.remedyExists(named: remedyName, databasePath: dbPath)) ?? false
        let title = remedyExists ? "Remedy Exists!" : "Add new Remedy?"
        let message = remedyExists
            ? "\(remedyName) already exists!  Do you wish to replace the remedy you have with this one?"
            : "Do you wish to add \(remedyName) to your Remedy collection?"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            defer { BurnSoftGeneral.clearDocumentInBox() }
            if remedyExists {
                let rid = OilRemedies.remedyID(byName: remedyName, databasePath: dbPath)
                FormFunctions.doBuggermeMessage("Remedy Exists with ID \(rid)", from: "AirDropHandler.openFile")
                try? OilRemedies.deleteRemedy(id: rid, databasePath: dbPath)
            }
            // addRemedyDetails escapes the values itself.
            guard let rid = try? OilRemedies.addRemedyDetails(name: remedyName, description: parser.remedyDescription,
                                                              uses: parser.remedyUses, databasePath: dbPath) else { return }
            OilRemedies.addOils(toRemedyID: rid, oils: parser.remedyOils, databasePath: dbPath)
        })
        alert.addAction(UIAlertAction(title: "No", style: .default) { _ in
            BurnSoftGeneral.clearDocumentInBox()
            FormFunctions.sendMessage("Import of Remedy \(remedyName) was aborted.", title: "Import Aborted!", viewController: viewController)
        })
        viewController.present(alert, animated: true)
    }

    /// Look through the Documents/Inbox folder for oil and remedy files and process them.
    static func processAllInBoxFiles(from viewController: UIViewController) {
        let inbox = BurnSoftGeneral.inboxDirectory
        let files = (try? FileManager.default.contentsOfDirectory(atPath: inbox)) ?? []
        for file in files where file.hasSuffix(".meo") {
            openFile(atPath: inbox + file, viewController: viewController)
        }
        for file in files where file.hasSuffix(".meor") {
            openFile(atPath: inbox + file, viewController: viewController)
        }
    }
}
