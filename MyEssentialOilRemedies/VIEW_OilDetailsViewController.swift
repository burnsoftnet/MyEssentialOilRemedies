//
//  VIEW_OilDetailsViewController.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/20/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//
//  StoryboardiD: ViewOilDetails

import UIKit

/// Shows the details of an oil and the remedies that use it.
/// Used both from the oil list and from search, so some outlets only exist in one of the scenes.
@objc(VIEW_OilDetailsViewController)
final class VIEW_OilDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
                                           UIPopoverPresentationControllerDelegate {

    /// ID of the oil to show.
    var oid = 0

    @IBOutlet weak var lblName: UILabel?
    @IBOutlet weak var lblCommonName: UILabel?
    @IBOutlet weak var lblBotanicalName: UILabel?
    @IBOutlet weak var lblIngredients: UITextView?
    @IBOutlet weak var lblSafetyNotes: UILabel?
    @IBOutlet weak var lblColor: UILabel?
    @IBOutlet weak var lblViscosity: UILabel?
    @IBOutlet weak var swInStock: UISwitch?
    @IBOutlet weak var swIsBlend: UISwitch?
    @IBOutlet weak var lblDescription: UITextView?
    @IBOutlet weak var lblVendor: UILabel?
    @IBOutlet weak var txtWebsite: UITextView?
    @IBOutlet weak var viewContent: UIView?
    @IBOutlet weak var viewRelatedRemedies: UIView?
    @IBOutlet weak var RelatedRemediesTable: UITableView?
    @IBOutlet weak var SearchContentView: UIView?

    private var dbPathString = ""
    private var relatedRemedies: [RelatedRemedy] = []
    private var selectedRID = 0
    private var actionButton: UIBarButtonItem?

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        loadData()
        loadRelatedRemedies()
        RelatedRemediesTable?.delegate = self
        RelatedRemediesTable?.dataSource = self

        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editOils))
        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(startAction))
        self.actionButton = actionButton
        navigationItem.rightBarButtonItems = [actionButton, editButton]

        changeCurrentView(to: 1)

        FormFunctions.setBackGroundImage(view)
        FormFunctions.setBackGroundImage(viewContent)
        FormFunctions.setBackGroundImage(viewRelatedRemedies)
        FormFunctions.setBackGroundImage(RelatedRemediesTable)
        FormFunctions.setBackGroundImage(SearchContentView)
    }

    // MARK: Data

    /// Load the database path and set the borders for the labels and text views.
    private func loadSettings() {
        dbPathString = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
        [lblName, lblColor, lblViscosity, lblCommonName, lblSafetyNotes, lblBotanicalName, lblVendor].forEach(FormFunctions.setBorderLabel)
        [lblDescription, lblIngredients, txtWebsite].forEach(FormFunctions.setBordersTextView)
    }

    private func loadRelatedRemedies() {
        relatedRemedies = (try? OilLists.remediesRelated(toOilID: oid, databasePath: dbPathString)) ?? []
    }

    /// Load the fields with the data from the selected oil.
    private func loadData() {
        do {
            let db = try SQLiteConnection(path: dbPathString)
            try db.query("select * from view_eo_oil_list_all where ID=\(oid)") { row in
                func text(_ column: Int32) -> String? { row.isNull(column) ? nil : row.string(column) }
                if let value = text(1) { lblName?.text = value }
                if let value = text(4) { lblDescription?.text = value }
                if let value = text(5) { lblBotanicalName?.text = value }
                if let value = text(6) { lblIngredients?.text = value }
                if let value = text(7) { lblSafetyNotes?.text = value }
                if let value = text(8) { lblColor?.text = value }
                if let value = text(9) { lblViscosity?.text = value }
                if let value = text(10) { lblCommonName?.text = value }
                if row.int(2) == 1 { swInStock?.setOn(true, animated: false) }
                if let value = text(11) { lblVendor?.text = value }
                if let value = text(12) { txtWebsite?.text = value }
                if row.int(13) == 1 { swIsBlend?.setOn(true, animated: false) }
            }
        } catch {
            FormFunctions.sendMessage(error.localizedDescription, title: "LoadData Error", viewController: self)
        }
    }

    // MARK: Share

    /// Gather the oil details and present the share sheet.
    @objc private func startAction() {
        let inStock = BurnSoftGeneral.boolString(swInStock?.isOn ?? false)
        let isBlend = BurnSoftGeneral.boolString(swIsBlend?.isOn ?? false)
        let name = lblName?.text ?? ""
        let commonName = lblCommonName?.text ?? ""
        let botanicalName = lblBotanicalName?.text ?? ""
        let ingredients = lblIngredients?.text ?? ""
        let safetyNotes = lblSafetyNotes?.text ?? ""
        let color = lblColor?.text ?? ""
        let viscosity = lblViscosity?.text ?? ""
        let vendor = lblVendor?.text ?? ""
        let website = txtWebsite?.text ?? ""
        let description = lblDescription?.text ?? ""

        let rawText = ActionClass.oilDetailsToString(name: name, commonName: commonName, botanicalName: botanicalName,
                                                     ingredients: ingredients, safetyNotes: safetyNotes, color: color,
                                                     viscosity: viscosity, inStock: inStock, vendor: vendor,
                                                     website: website, description: description, isBlend: isBlend)
        let xml = BurnSoftGeneral.fcStringXML(Parser.oilDetailsToXML(name: name, commonName: commonName,
                                                                     botanicalName: botanicalName, ingredients: ingredients,
                                                                     safetyNotes: safetyNotes, color: color,
                                                                     viscosity: viscosity, inStock: inStock, vendor: vendor,
                                                                     website: website, description: description,
                                                                     isBlend: isBlend))
        let outputFile = ActionClass.writeOilDetailsToFile(xml)
        ActionClass.sendToActionSheet(from: self, items: [URL(fileURLWithPath: outputFile), rawText],
                                      emailSubject: "Oil Details for: \(name)", barButtonItem: actionButton)
    }

    // MARK: Views

    /// Switch between the description view (1) and the related remedies view (2).
    private func changeCurrentView(to view: Int) {
        viewContent?.isHidden = view != 1
        viewRelatedRemedies?.isHidden = view != 2
    }

    @IBAction func tbDescription(_ sender: Any) {
        changeCurrentView(to: 1)
    }

    @IBAction func tbRelatedRemedies(_ sender: Any) {
        changeCurrentView(to: 2)
    }

    // MARK: Actions

    /// Update whether the oil is in stock without having to go into editing.
    @IBAction func swUpdateStockStatus(_ sender: Any) {
        try? OilLists.updateStockStatus(swInStock?.isOn ?? false, oilID: oid, databasePath: dbPathString)
    }

    /// Update whether the oil is a blend without having to go into editing.
    @IBAction func swUpdateBlendStatus(_ sender: Any) {
        try? OilLists.updateBlendStatus(swIsBlend?.isOn ?? false, oilID: oid, databasePath: dbPathString)
    }

    /// Close button when shown from search.
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true)
        presentedViewController?.dismiss(animated: true)
        navigationController?.popViewController(animated: false)
        navigationController?.popViewController(animated: true)
    }

    /// Edit button when shown from search.
    @IBAction func btnEdit(_ sender: Any) {
        performSegue(withIdentifier: "segueEditOilFromSearch", sender: self)
    }

    @objc private func editOils() {
        guard let destination = storyboard?.instantiateViewController(withIdentifier: "EditOils") as? EDIT_OilDetailViewController else { return }
        destination.oid = oid
        navigationController?.pushViewController(destination, animated: true)
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "EditOilSegue", "segueEditOilFromSearch":
            if let destination = segue.destination as? EDIT_OilDetailViewController {
                destination.oid = oid
                destination.isFromSearch = true
            }
        case "segueViewRemedyFromOils":
            if let destination = segue.destination as? VIEW_RemedyViewController {
                destination.rid = selectedRID
            }
        default:
            break
        }
    }

    // MARK: Related Remedies Table

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        false
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        relatedRemedies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let remedy = relatedRemedies[indexPath.row]
        cell.textLabel?.text = remedy.name
        cell.tag = remedy.rid
        FormFunctions.setBackGroundImage(cell.contentView)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRID = relatedRemedies[indexPath.row].rid
        performSegue(withIdentifier: "segueViewRemedyFromOils", sender: self)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
