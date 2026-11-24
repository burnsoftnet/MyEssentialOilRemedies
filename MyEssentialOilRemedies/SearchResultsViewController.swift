//
//  SearchResultsViewController.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 9/22/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

import UIKit

/// Shows the names that match the search in SearchViewController.
@objc(SearchResultsViewController)
final class SearchResultsViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    /// The matching oil and remedy names, set by SearchViewController.
    var searchResults: [String] = [] {
        didSet { tableView.reloadData() }
    }

    private var dbPathString = ""
    private var selectedID = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        dbPathString = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
        FormFunctions.setBackGroundImage(view)
    }

    // MARK: Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) {
            FormFunctions.setBackGroundImage(cell.contentView)
        }
        findLocationOfSelection(searchResults[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        FormFunctions.setBackGroundImage(cell.contentView)
        cell.textLabel?.text = searchResults[indexPath.row]
        return cell
    }

    // MARK: Selection

    /// Work out whether the selected name is an oil or a remedy and show it.
    private func findLocationOfSelection(_ value: String) {
        let oilID = (try? SearchDatabase.oilID(byName: BurnSoftGeneral.fcString(value), databasePath: dbPathString)) ?? 0
        let remedyID = (try? SearchDatabase.remedyID(byName: BurnSoftGeneral.fcString(value), databasePath: dbPathString)) ?? 0

        switch (oilID > 0, remedyID > 0) {
        case (true, false):
            selectedID = oilID
            performSegue(withIdentifier: "segueViewOilFromSearch", sender: self)
        case (false, true):
            selectedID = remedyID
            performSegue(withIdentifier: "segueViewRemedyFromSearch", sender: self)
        case (true, true):
            // The name is both an oil and a remedy.
            let message = "\(value) is something!"
            FormFunctions.sendMessage(message, title: message, viewController: self)
        case (false, false):
            break
        }
    }

    /// Runs when a search result is touched; browsing the full list without searching uses SearchViewController instead.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueViewOilFromSearch", let destination = segue.destination as? VIEW_OilDetailsViewController {
            destination.oid = selectedID
        } else if segue.identifier == "segueViewRemedyFromSearch" {
            (segue.destination as? RemedyIDReceiving)?.rid = selectedID
            segue.destination.modalPresentationStyle = .automatic
            navigationController?.pushViewController(segue.destination, animated: true)
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
