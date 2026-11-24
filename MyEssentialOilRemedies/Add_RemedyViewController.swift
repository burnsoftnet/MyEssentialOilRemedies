//
//  Add_RemedyViewController.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/3/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

import UIKit

@objc(Add_RemedyViewController)
final class Add_RemedyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {

    /// Oils added to the new remedy.
    private var oils: [String] = []

    @IBOutlet weak var viewDescription: UIView?
    @IBOutlet weak var viewOils: UIView?
    @IBOutlet weak var viewUses: UIView?
    @IBOutlet weak var txtUses: UITextView?
    @IBOutlet weak var myTableView: UITableView?
    @IBOutlet weak var RemedyName: UITextField?
    @IBOutlet weak var RemedyDescription: UITextView?
    @IBOutlet weak var txtOilName: UITextField?

    private var dbPathString = ""

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        myTableView?.delegate = self
        myTableView?.dataSource = self
        changeCurrentView(to: 1)

        // Dismiss the keyboard when the view is tapped.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapReceived))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)

        FormFunctions.setBackGroundImage(view)
        FormFunctions.setBackGroundImage(viewOils)
        FormFunctions.setBackGroundImage(viewUses)
        FormFunctions.setBackGroundImage(myTableView)
        FormFunctions.setBackGroundImage(viewDescription)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadSettings()
    }

    /// When the form is leaving, go back to the remedy list.
    override func viewWillDisappear(_ animated: Bool) {
        closeForm()
        super.viewWillDisappear(animated)
    }

    private func closeForm() {
        navigationController?.popViewController(animated: false)
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }

    private func loadSettings() {
        FormFunctions.setBorderTextBox(RemedyName)
        FormFunctions.setBordersTextView(RemedyDescription)
        FormFunctions.setBorderTextBox(txtOilName)
        FormFunctions.setBordersTextView(txtUses)
        myTableView?.reloadData()
        dbPathString = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
    }

    @objc private func tapReceived(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    // MARK: Actions

    /// Warn as soon as the user leaves the name field if the remedy already exists.
    @IBAction func RemedyNameLostFocus(_ sender: Any) {
        let name = RemedyName?.text ?? ""
        if (try? OilRemedies.remedyExists(named: BurnSoftGeneral.fcString(name), databasePath: dbPathString)) == true {
            FormFunctions.sendMessage("An remedy already exists with the name \(name)", title: "Remedy Exists!", viewController: self)
        }
    }

    /// Add the oil in the text box to the remedy's oil list (limited in the Lite version).
    @IBAction func btnAddOil(_ sender: Any) {
        if MYSettings.isLiteVersion {
            let oilCount = (try? BurnSoftDatabase.totalRows(inTable: "eo_oil_list", databasePath: dbPathString)) ?? 0
            guard oilCount <= MYSettings.liteLimit - 1 else {
                FormFunctions.alertOnLimit(for: self)
                return
            }
        }
        let newOil = txtOilName?.text ?? ""
        if !newOil.isEmpty {
            oils.append(newOil)
            myTableView?.reloadData()
        }
        txtOilName?.text = ""
    }

    /// Save the remedy and its oils, then close the form.
    @IBAction func tbSave(_ sender: Any) {
        let name = (RemedyName?.text ?? "").trimmingCharacters(in: .whitespaces)
        let description = RemedyDescription?.text ?? ""
        let uses = txtUses?.text ?? ""

        switch (name.isEmpty, description.isEmpty) {
        case (false, false):
            do {
                // addRemedyDetails escapes the values itself.
                let rid = try OilRemedies.addRemedyDetails(name: name, description: description, uses: uses, databasePath: dbPathString)
                OilRemedies.addOils(toRemedyID: rid, oils: oils, databasePath: dbPathString)
                oils.removeAll()
                closeForm()
            } catch {
                FormFunctions.checkForError(error, title: "Adding Remedy", viewController: self)
            }
        case (false, true):
            FormFunctions.sendMessage("Please put in a Problem description!", title: "Missing Value", viewController: self)
        case (true, false):
            FormFunctions.sendMessage("Please Put in a Problem Name!", title: "Missing Value", viewController: self)
        case (true, true):
            FormFunctions.sendMessage("Please Put in a Problem Name & Description!", title: "Missing Value", viewController: self)
        }
    }

    // MARK: Views

    /// Switch between the description (1), oils (2) and uses (3) views.
    private func changeCurrentView(to view: Int) {
        viewDescription?.isHidden = view != 1
        viewOils?.isHidden = view != 2
        viewUses?.isHidden = view != 3
    }

    @IBAction func tbUses(_ sender: Any) {
        changeCurrentView(to: 3)
    }

    @IBAction func tbOils(_ sender: Any) {
        changeCurrentView(to: 2)
    }

    @IBAction func tbDescription(_ sender: Any) {
        changeCurrentView(to: 1)
    }

    // MARK: Oils Table

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        oils.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        FormFunctions.setBackGroundImage(cell.contentView)
        cell.textLabel?.text = oils[indexPath.row]
        return cell
    }
}
