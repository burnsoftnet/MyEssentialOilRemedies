//
//  SearchViewController.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 9/17/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

import UIKit

/// Lists every oil and remedy name, and searches them with a search controller.
@objc(SearchViewController)
final class SearchViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {

    @IBOutlet weak var mySearchBar: UISearchBar?
    @IBOutlet weak var myTableView: UITableView?

    private var dbPathString = ""

    /// All the oil and remedy names, loaded the first time they are needed.
    private lazy var combinedResults: [String] = SearchDatabase.allSearchDataSimple(databasePath: dbPathString)

    /// The search controller, which shows matches in SearchResultsViewController.
    private lazy var searchController: UISearchController = {
        let board = storyboard ?? UIStoryboard(name: "iphone", bundle: nil)
        let resultsController = board.instantiateViewController(withIdentifier: "SearchResults") as? SearchResultsViewController
        let controller = UISearchController(searchResultsController: resultsController)
        controller.searchResultsUpdater = self
        controller.delegate = self
        return controller
    }()

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGlobalVars()
        FormFunctions.setBackGroundImage(view)
        FormFunctions.setBackGroundImage(myTableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupGlobalVars()
    }

    private func setupGlobalVars() {
        dbPathString = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
    }

    // MARK: Selection

    /// Work out whether the selected name is an oil or a remedy and show it.
    /// - Remark: Also used by SearchResultsViewController.
    private func findLocationOfSelection(_ value: String) {
        let oilID = (try? SearchDatabase.oilID(byName: BurnSoftGeneral.fcString(value), databasePath: dbPathString)) ?? 0
        let remedyID = (try? SearchDatabase.remedyID(byName: BurnSoftGeneral.fcString(value), databasePath: dbPathString)) ?? 0

        switch (oilID > 0, remedyID > 0) {
        case (true, false):
            guard let controller = storyboard?.instantiateViewController(withIdentifier: "ViewOilDetailsFromSearch") as? VIEW_OilDetailsViewController else { return }
            controller.oid = oilID
            navigationController?.pushViewController(controller, animated: true)
        case (false, true):
            guard let controller = storyboard?.instantiateViewController(withIdentifier: "RemedyDetailsViewControllerFromSearchSingle") as? VIEW_SingleRemedyViewController else { return }
            controller.rid = remedyID
            navigationController?.pushViewController(controller, animated: true)
        case (true, true):
            // The name is both an oil and a remedy.
            let message = "\(value) is something!"
            FormFunctions.sendMessage(message, title: message, viewController: self)
        case (false, false):
            break
        }
    }

    // MARK: Table View

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        findLocationOfSelection(combinedResults[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        combinedResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = combinedResults[indexPath.row]
        FormFunctions.setBackGroundImage(cell.contentView)
        return cell
    }

    // MARK: Search

    /// Filter the names (case and diacritic insensitive) and pass the matches to the results table.
    func updateSearchResults(for searchController: UISearchController) {
        let lookFor = searchController.searchBar.text ?? ""
        guard !lookFor.isEmpty else { return }
        let results = combinedResults.filter { $0.range(of: lookFor, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
        (searchController.searchResultsController as? SearchResultsViewController)?.searchResults = results
    }

    /// Present the search controller when the button is touched.
    @IBAction func btnSearch(_ sender: Any) {
        present(searchController, animated: true)
    }
}
