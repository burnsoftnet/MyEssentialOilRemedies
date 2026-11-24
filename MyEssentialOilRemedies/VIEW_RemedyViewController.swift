//
//  VIEW_RemedyViewController.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/3/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

import UIKit

/// Shows a remedy: its description, the oils it needs, and how to use it.
@objc(VIEW_RemedyViewController)
final class VIEW_RemedyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RemedyIDReceiving {

    /// ID of the remedy to show.
    var rid = 0

    @IBOutlet weak var viewDescription: UIView?
    @IBOutlet weak var viewOils: UIView?
    @IBOutlet weak var viewUses: UIView?
    @IBOutlet weak var lblProblem: UILabel?
    @IBOutlet weak var lblDescription: UITextView?
    @IBOutlet weak var lblUses: UITextView?
    @IBOutlet weak var myTableView: UITableView?
    @IBOutlet weak var tbSave: UIBarButtonItem?
    @IBOutlet weak var tbClose: UIBarButtonItem?
    @IBOutlet weak var topConstraint: NSLayoutConstraint?

    private var dbPathString = ""
    private var oils: [RemedyOil] = []
    private var selectedOilName = ""
    private var actionButton: UIBarButtonItem?

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView?.delegate = self
        myTableView?.dataSource = self
        loadSettings()
        loadData()

        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(startAction))
        self.actionButton = actionButton
        navigationItem.rightBarButtonItems = [actionButton]

        FormFunctions.setBackGroundImage(viewOils)
        FormFunctions.setBackGroundImage(viewUses)
        FormFunctions.setBackGroundImage(myTableView)
        FormFunctions.setBackGroundImage(viewDescription)

        changeCurrentView(to: 1)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        // When the Back button is hit, go back to the remedy list.
        if navigationController?.viewControllers.contains(self) != true {
            dismiss(animated: true)
        }
        super.viewWillDisappear(animated)
    }

    // MARK: Data

    private func loadSettings() {
        dbPathString = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
        FormFunctions.setBorderLabel(lblProblem)
        FormFunctions.setBordersTextView(lblDescription)
        FormFunctions.setBordersTextView(lblUses)
    }

    /// Load the remedy and its oils from the database.
    private func loadData() {
        if let db = try? SQLiteConnection(path: dbPathString) {
            try? db.query("select * from eo_remedy_list where ID=\(rid)") { row in
                if !row.isNull(1) { lblProblem?.text = row.string(1) }
                if !row.isNull(2) { lblDescription?.text = row.string(2) }
                if !row.isNull(3) { lblUses?.text = row.string(3) }
            }
        }
        oils = OilRemedies.oils(forRemedyID: rid, databasePath: dbPathString)
        myTableView?.reloadData()
    }

    // MARK: Share

    /// Gather the remedy details and present the share sheet.
    @objc private func startAction() {
        let name = lblProblem?.text ?? ""
        let description = lblDescription?.text ?? ""
        let uses = lblUses?.text ?? ""
        let oilNames = oils.map(\.name)
        let oilList = "\n" + oilNames.map { "\($0)\n" }.joined()

        let rawText = ActionClass.remedyDetailsToString(name: name, description: description, oils: oilList, howToUse: uses)
        let xml = BurnSoftGeneral.fcStringXML(Parser.remedyDetailsToXML(name: name, description: description, uses: uses, oils: oilNames))
        let outputFile = ActionClass.writeRemedyDetailsToFile(xml)
        ActionClass.sendToActionSheet(from: self, items: [URL(fileURLWithPath: outputFile), rawText],
                                      emailSubject: "Oil Remedy for: \(name)", barButtonItem: actionButton)
    }

    // MARK: Views

    /// Switch between the description (1), oils (2) and uses (3) views.
    private func changeCurrentView(to view: Int) {
        viewDescription?.isHidden = view != 1
        viewOils?.isHidden = view != 2
        viewUses?.isHidden = view != 3
    }

    @IBAction func tbEdit(_ sender: Any) {
        guard let destination = storyboard?.instantiateViewController(withIdentifier: "EditRemedy_Description_ViewController") as? EDIT_RemedyViewController else { return }
        destination.rid = rid
        navigationController?.pushViewController(destination, animated: true)
    }

    @IBAction func tbDescription(_ sender: Any) {
        changeCurrentView(to: 1)
    }

    @IBAction func tbClose(_ sender: Any) {
        navigationController?.popViewController(animated: false)
        navigationController?.popViewController(animated: true)
    }

    @IBAction func tbOils(_ sender: Any) {
        changeCurrentView(to: 2)
    }

    @IBAction func tbUses(_ sender: Any) {
        changeCurrentView(to: 3)
    }

    // MARK: Navigation

    /// Present the pop-up over the current view.
    static func setOverCurrentContextPresentation(for presentedController: UIViewController) {
        presentedController.providesPresentationContextTransitionStyle = true
        presentedController.definesPresentationContext = true
        presentedController.modalPresentationStyle = .overCurrentContext
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueViewOilPopUp" {
            if let popup = segue.destination as? PopUpOilViewController {
                popup.oilName = selectedOilName
                Self.setOverCurrentContextPresentation(for: popup)
            }
            return
        }
        (segue.destination as? RemedyIDReceiving)?.rid = rid
        if segue.identifier == "segueSearchRemedyOils" || segue.identifier == "segueSearchUses" {
            Self.setOverCurrentContextPresentation(for: segue.destination)
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
        performSegue(withIdentifier: "segueViewOilPopUp", sender: self)
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
