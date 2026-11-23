//
//  EDIT_RemedyViewController.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/3/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

import UIKit

@objc(EDIT_RemedyViewController)
final class EDIT_RemedyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
                                       UIGestureRecognizerDelegate, RemedyIDReceiving {

    /// ID of the remedy to edit.
    var rid = 0
    /// True when opened from search, which needs extra room at the top.
    var isFromSearch = false

    /// Oils in the remedy being edited.
    private var oils: [String] = []

    @IBOutlet weak var viewDescription: UIView?
    @IBOutlet weak var viewOils: UIView?
    @IBOutlet weak var viewUses: UIView?
    @IBOutlet weak var txtOilName: UITextField?
    @IBOutlet weak var myTableView: UITableView?
    @IBOutlet weak var txtUses: UITextView?
    @IBOutlet weak var txtRemedy: UITextField?
    @IBOutlet weak var txtDescription: UITextView?
    @IBOutlet weak var topConstraint: NSLayoutConstraint?

    private var dbPathString = ""

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        loadData()
        myTableView?.delegate = self
        myTableView?.dataSource = self

        // Dismiss the keyboard when the view is tapped.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapReceived))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)

        FormFunctions.setBackGroundImage(viewDescription)
        FormFunctions.setBackGroundImage(viewUses)
        FormFunctions.setBackGroundImage(viewOils)
        FormFunctions.setBackGroundImage(myTableView)

        changeCurrentView(to: 1)

        if isFromSearch, let topConstraint {
            if topConstraint.constant == 0 {
                topConstraint.constant = 20
            } else if topConstraint.constant < 0 {
                topConstraint.constant = 0
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    /// When the form is leaving, go back to the previous screen.
    override func viewWillDisappear(_ animated: Bool) {
        closeForm()
        super.viewWillDisappear(animated)
    }

    private func closeForm() {
        navigationController?.popViewController(animated: false)
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }

    private func clearAndExit() {
        oils.removeAll()
        closeForm()
    }

    @objc private func tapReceived(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    // MARK: Data

    private func loadSettings() {
        dbPathString = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
        FormFunctions.setBorderTextBox(txtRemedy)
        FormFunctions.setBordersTextView(txtUses)
        FormFunctions.setBorderTextBox(txtOilName)
        FormFunctions.setBordersTextView(txtDescription)
    }

    /// Load the remedy and its oils from the database.
    private func loadData() {
        do {
            let db = try SQLiteConnection(path: dbPathString)
            try db.query("select * from eo_remedy_list where ID=\(rid)") { row in
                if !row.isNull(1) { txtRemedy?.text = row.string(1) }
                if !row.isNull(2) { txtDescription?.text = row.string(2) }
                if !row.isNull(3) { txtUses?.text = row.string(3) }
            }
        } catch {
            FormFunctions.doBuggermeMessage(error.localizedDescription, from: "EDIT_RemedyViewController.loadData")
        }
        oils = OilRemedies.oilNames(forRemedyID: rid, databasePath: dbPathString)
        myTableView?.reloadData()
    }

    // MARK: Actions

    @IBAction func btnAddOil(_ sender: Any) {
        let newOil = txtOilName?.text ?? ""
        if !newOil.isEmpty {
            oils.append(newOil)
            myTableView?.reloadData()
        }
        txtOilName?.text = ""
    }

    /// Save the remedy, replace its oils, and close the form.
    @IBAction func tbUpdate(_ sender: Any) {
        do {
            try OilRemedies.updateRemedyDetails(rid: rid, name: txtRemedy?.text ?? "", description: txtDescription?.text ?? "",
                                                uses: txtUses?.text ?? "", databasePath: dbPathString)
        } catch {
            FormFunctions.sendMessage(error.localizedDescription, title: "Error Updating Remedy", viewController: self)
            return
        }
        do {
            try OilRemedies.clearOilsPerRemedy(rid: rid, databasePath: dbPathString)
        } catch {
            FormFunctions.sendMessage(error.localizedDescription, title: "Error Clearing Oils", viewController: self)
            return
        }
        OilRemedies.addOils(toRemedyID: rid, oils: oils, databasePath: dbPathString)
        clearAndExit()
    }

    @IBAction func tbClose(_ sender: Any) {
        clearAndExit()
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

    @IBAction func tbDescription(_ sender: Any) {
        changeCurrentView(to: 1)
    }

    @IBAction func tbOils(_ sender: Any) {
        changeCurrentView(to: 2)
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

    /// Swipe to remove an oil from the remedy (saved when Update is touched).
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self else { return }
            oils.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completion(true)
        }
        deleteAction.backgroundColor = .red

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
