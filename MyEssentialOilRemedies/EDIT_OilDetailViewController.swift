//
//  EDIT_OilDetailViewController.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 7/1/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//
//  StoryboardiD: EditOilDetails

import UIKit

@objc(EDIT_OilDetailViewController)
final class EDIT_OilDetailViewController: UIViewController, UIGestureRecognizerDelegate {

    /// ID of the oil to edit.
    var oid = 0
    /// True when opened from search, which presents modally instead of pushing.
    var isFromSearch = false

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
    @IBOutlet weak var txtVendor: UITextField?
    @IBOutlet weak var txtWebsite: UITextField?
    @IBOutlet weak var ContentView: UIView?

    private var dbPathString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        loadData()

        // Dismiss the keyboard when the view is tapped.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapReceived))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(updateOils))

        FormFunctions.setBackGroundImage(view)
        FormFunctions.setBackGroundImage(ContentView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadSettings()
        loadData()
    }

    @objc private func tapReceived(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditOilDetails", let destination = segue.destination as? EDIT_OilDetailViewController {
            destination.oid = oid
        }
    }

    /// Save the details from the form to the database.
    @objc private func updateOils() {
        let name = BurnSoftGeneral.fcString(txtName?.text ?? "")
        let inStock = (swInStock?.isOn ?? false) ? 1 : 0
        do {
            try BurnSoftDatabase.runQuery("UPDATE eo_oil_list set name='\(name)',instock=\(inStock) where ID=\(oid)",
                                          databasePath: dbPathString)
        } catch {
            FormFunctions.checkForError(error, title: "Updating Name", viewController: self)
            return
        }
        guard oid != 0 else { return }

        // updateOilDetails escapes the values itself.
        let details = OilDetails(description: txtDescription?.text ?? "", botanicalName: txtBotanicalName?.text ?? "",
                                 ingredients: txtIngredients?.text ?? "", safetyNotes: txtSafetyNotes?.text ?? "",
                                 color: txtColor?.text ?? "", viscosity: txtViscosity?.text ?? "",
                                 commonName: txtCommonName?.text ?? "", vendor: txtVendor?.text ?? "",
                                 website: txtWebsite?.text ?? "", isBlend: swIsBlend?.isOn ?? false)
        do {
            try OilLists.updateOilDetails(oid: oid, details: details, databasePath: dbPathString)
            if isFromSearch {
                dismiss(animated: true)
                dismiss(animated: true)
            } else {
                navigationController?.popViewController(animated: false)
                navigationController?.popViewController(animated: true)
            }
        } catch {
            FormFunctions.checkForError(error, title: "Updating Details", viewController: self)
        }
    }

    @IBAction func btnUpdate(_ sender: Any) {
        updateOils()
    }

    /// Load the database path and the text box borders.
    private func loadSettings() {
        dbPathString = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
        [txtIngredients, txtDescription, txtSafetyNotes].forEach(FormFunctions.setBordersTextView)
        [txtName, txtCommonName, txtColor, txtViscosity, txtBotanicalName, txtVendor, txtWebsite].forEach(FormFunctions.setBorderTextBox)
    }

    /// Load the oil from the database into the fields.
    private func loadData() {
        do {
            let db = try SQLiteConnection(path: dbPathString)
            try db.query("select * from view_eo_oil_list_all where ID=\(oid)") { row in
                func text(_ column: Int32) -> String? { row.isNull(column) ? nil : row.string(column) }
                if let value = text(1) { txtName?.text = value }
                if let value = text(4) { txtDescription?.text = value }
                if let value = text(5) { txtBotanicalName?.text = value }
                if let value = text(6) { txtIngredients?.text = value }
                if let value = text(7) { txtSafetyNotes?.text = value }
                if let value = text(8) { txtColor?.text = value }
                if let value = text(9) { txtViscosity?.text = value }
                if let value = text(10) { txtCommonName?.text = value }
                if row.int(2) == 1 { swInStock?.setOn(true, animated: false) }
                if let value = text(11) { txtVendor?.text = value }
                if let value = text(12) { txtWebsite?.text = value }
                if row.int(13) == 1 { swIsBlend?.setOn(true, animated: false) }
            }
        } catch {
            FormFunctions.sendMessage(error.localizedDescription, title: "LoadData Error", viewController: self)
        }
    }
}
