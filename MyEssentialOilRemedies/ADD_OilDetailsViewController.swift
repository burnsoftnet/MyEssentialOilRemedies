//
//  ADD_OilDetailsViewController.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/20/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//
//  StoryboardiD: AddOils

import UIKit

@objc(ADD_OilDetailsViewController)
final class ADD_OilDetailsViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var txtName: UITextField?
    @IBOutlet weak var txtCommonName: UITextField?
    @IBOutlet weak var txtBotanicalName: UITextField?
    @IBOutlet weak var txtIngredients: UITextView?
    @IBOutlet weak var txtSafetyNotes: UITextView?
    @IBOutlet weak var txtColor: UITextField?
    @IBOutlet weak var txtViscosity: UITextField?
    @IBOutlet weak var swInStock: UISwitch?
    @IBOutlet weak var swIsBlend: UISwitch?
    @IBOutlet weak var txtDescription: UITextView?
    @IBOutlet weak var txtVedor: UITextField?
    @IBOutlet weak var txtWebsite: UITextField?
    @IBOutlet weak var viewMain: UIView?

    private var dbPathString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()

        // Dismiss the keyboard when the view is tapped.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapReceived))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)

        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addMoreOils))
        addButton.tintColor = .black
        navigationItem.rightBarButtonItem = addButton

        FormFunctions.setBackGroundImage(view)
        FormFunctions.setBackGroundImage(viewMain)
    }

    /// Set the database path and the text box borders.
    private func loadSettings() {
        dbPathString = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
        [txtSafetyNotes, txtIngredients, txtDescription].forEach(FormFunctions.setBordersTextView)
        [txtName, txtCommonName, txtBotanicalName, txtColor, txtViscosity, txtVedor, txtWebsite].forEach(FormFunctions.setBorderTextBox)
    }

    /// Look up whether an oil already exists with this name.
    private func oilExists(named name: String) -> Bool {
        (try? OilLists.oilExists(named: BurnSoftGeneral.fcString(name), databasePath: dbPathString)) ?? false
    }

    /// Warn as soon as the user leaves the name field if the oil already exists.
    @IBAction func OilNameEditingEnded(_ sender: Any) {
        let name = txtName?.text ?? ""
        if oilExists(named: name) {
            FormFunctions.sendMessage("An oil already exists with the name \(name)", title: "Oil Exists!", viewController: self)
        }
    }

    @objc private func tapReceived(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    private func clearValues() {
        [txtName, txtCommonName, txtBotanicalName, txtColor, txtViscosity, txtVedor, txtWebsite].forEach { $0?.text = "" }
        [txtIngredients, txtSafetyNotes, txtDescription].forEach { $0?.text = "" }
    }

    /// Add the details from the form to the database.
    @objc private func addMoreOils() {
        let name = (txtName?.text ?? "").trimmingCharacters(in: .whitespaces)

        guard !oilExists(named: name) else {
            FormFunctions.sendMessage("An oil already exists with the name \(name)", title: "Oil Exists!", viewController: self)
            return
        }
        guard !name.isEmpty else {
            FormFunctions.sendMessage("Please put in an Oil Name!", title: "Missing Name", viewController: self)
            return
        }

        let escapedName = BurnSoftGeneral.fcString(name)
        let oid: Int
        do {
            try BurnSoftDatabase.runQuery("INSERT INTO eo_oil_list (name,instock) VALUES ('\(escapedName)',\((swInStock?.isOn ?? false) ? 1 : 0))",
                                          databasePath: dbPathString)
            oid = try BurnSoftDatabase.lastEntryID(byName: escapedName, lookForColumn: "name", idColumn: "ID",
                                                   table: "eo_oil_list", databasePath: dbPathString)
        } catch {
            FormFunctions.checkForError(error, title: "Adding Name", viewController: self)
            return
        }
        guard oid != 0 else { return }

        // insertOilDetails escapes the values itself.
        let details = OilDetails(description: txtDescription?.text ?? "", botanicalName: txtBotanicalName?.text ?? "",
                                 ingredients: txtIngredients?.text ?? "", safetyNotes: txtSafetyNotes?.text ?? "",
                                 color: txtColor?.text ?? "", viscosity: txtViscosity?.text ?? "",
                                 commonName: txtCommonName?.text ?? "", vendor: txtVedor?.text ?? "",
                                 website: txtWebsite?.text ?? "", isBlend: swIsBlend?.isOn ?? false)
        do {
            try OilLists.insertOilDetails(oid: oid, details: details, databasePath: dbPathString)
            clearValues()
            navigationController?.popViewController(animated: false)
            navigationController?.popViewController(animated: true)
        } catch {
            FormFunctions.checkForError(error, title: "Adding Details", viewController: self)
        }
    }

    @IBAction func btnAdd(_ sender: Any) {
        addMoreOils()
    }
}
