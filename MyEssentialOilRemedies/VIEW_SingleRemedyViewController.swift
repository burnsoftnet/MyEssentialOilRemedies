//
//  VIEW_SingleRemedyViewController.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 11/7/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//
//  For regular size is 400x800

import UIKit

/// Shows a single remedy opened from search.
@objc(VIEW_SingleRemedyViewController)
final class VIEW_SingleRemedyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RemedyIDReceiving {

    /// ID of the remedy to show.
    var rid = 0
    /// True when opened from search, which shows the Close button.
    var isFromSearch = false
    /// Remedy values; loaded from the database unless they were set before the view loaded.
    var remedyName: String?
    var remedyDescription: String?
    var uses: String?

    @IBOutlet weak var lblProblem: UILabel?
    @IBOutlet weak var lblDescription: UITextView?
    @IBOutlet weak var lblUses: UITextView?
    @IBOutlet weak var myTableView: UITableView?
    @IBOutlet weak var tbSave: UIBarButtonItem?
    @IBOutlet weak var tbEdit: UIBarButtonItem?
    @IBOutlet weak var tbClose: UIBarButtonItem?
    @IBOutlet weak var topConstraint: NSLayoutConstraint?
    @IBOutlet weak var ViewDescription: UIView?
    @IBOutlet weak var ViewOils: UIView?
    @IBOutlet weak var ViewUses: UIView?

    private var dbPathString = ""
    private var oils: [RemedyOil] = []
    private var selectedOilName = ""

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView?.delegate = self
        myTableView?.dataSource = self
        loadSettings()
        clearFields()
        loadData()
        loadForm()
        if !isFromSearch {
            tbClose?.tintColor = .clear
            tbClose?.isEnabled = false
        } else {
            topConstraint?.constant = 20
        }

        changeCurrentView(to: 1)

        FormFunctions.setBackGroundImage(view)
        FormFunctions.setBackGroundImage(ViewOils)
        FormFunctions.setBackGroundImage(ViewUses)
        FormFunctions.setBackGroundImage(myTableView)
        FormFunctions.setBackGroundImage(ViewDescription)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        // When the Back button is hit, go back to the remedy list.
        if navigationController?.viewControllers.contains(self) != true {
            if let list = storyboard?.instantiateViewController(withIdentifier: "RemedyListController") {
                navigationController?.pushViewController(list, animated: true)
            }
            dismiss(animated: true)
        }
        super.viewWillDisappear(animated)
    }

    // MARK: Data

    private func loadSettings() {
        dbPathString = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
        FormFunctions.setBorderLabel(lblProblem)
        FormFunctions.setBordersTextView(lblDescription)
    }

    private func loadForm() {
        lblProblem?.text = remedyName
        lblDescription?.text = remedyDescription
        lblUses?.text = uses
    }

    /// Load the remedy values that haven't been set yet, and the remedy's oils.
    private func loadData() {
        if let db = try? SQLiteConnection(path: dbPathString) {
            try? db.query("select * from eo_remedy_list where ID=\(rid)") { row in
                if remedyName == nil, !row.isNull(1) { remedyName = row.string(1) }
                if remedyDescription == nil, !row.isNull(2) { remedyDescription = row.string(2) }
                if uses == nil, !row.isNull(3) { uses = row.string(3) }
            }
        }
        oils = OilRemedies.oils(forRemedyID: rid, databasePath: dbPathString)
        myTableView?.reloadData()
    }

    private func clearFields() {
        lblProblem?.text = ""
        lblDescription?.text = ""
        lblUses?.text = ""
    }

    // MARK: Actions

    /// Not in use.
    @IBAction func tbSave(_ sender: Any) {
    }

    @IBAction func tbEdit(_ sender: Any) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "segueEditRemedyFromSearch") else { return }
        (controller as? RemedyIDReceiving)?.rid = rid
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func tbDescription(_ sender: Any) {
        changeCurrentView(to: 1)
    }

    @IBAction func tbClose(_ sender: Any) {
        dismiss(animated: true)
        navigationController?.popViewController(animated: false)
        navigationController?.popViewController(animated: true)
    }

    @IBAction func tbOils(_ sender: Any) {
        changeCurrentView(to: 2)
    }

    @IBAction func tbUses(_ sender: Any) {
        changeCurrentView(to: 3)
    }

    // MARK: Views

    /// Switch between the description (1), oils (2) and uses (3) views.
    private func changeCurrentView(to view: Int) {
        ViewDescription?.isHidden = view != 1
        ViewOils?.isHidden = view != 2
        ViewUses?.isHidden = view != 3
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "segueViewOilPopUpSearch":
            if let popup = segue.destination as? PopUpOilSearchViewController {
                popup.oilName = selectedOilName
                VIEW_RemedyViewController.setOverCurrentContextPresentation(for: popup)
            }
        case "segueEditRemedyFromSearch", "segueEditRemedyFromSearch2", "segueEditRemedyFromSearch3":
            if let editor = segue.destination as? EDIT_RemedyViewController {
                editor.rid = rid
                VIEW_RemedyViewController.setOverCurrentContextPresentation(for: editor)
            }
        default:
            break
        }
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOilName = oils[indexPath.row].name
        modalPresentationStyle = .currentContext
        performSegue(withIdentifier: "segueViewOilPopUpSearch", sender: self)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let oil = oils[indexPath.row]
        cell.textLabel?.text = oil.name
        // Oils that are in stock are highlighted.
        if oil.inStock {
            cell.contentView.backgroundColor = .green
        } else {
            FormFunctions.setBackGroundImage(cell.contentView)
        }
        return cell
    }
}
