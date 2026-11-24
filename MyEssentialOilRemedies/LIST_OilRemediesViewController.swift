//
//  LIST_OilRemediesViewController.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//
//  StoryboardiD: RemedyListController

import UIKit

/// View controllers that show or edit a single remedy, so segues can pass the remedy ID along.
protocol RemedyIDReceiving: AnyObject {
    var rid: Int { get set }
}

@objc(LIST_OilRemediesViewController)
final class LIST_OilRemediesViewController: UITableViewController {

    @IBOutlet weak var myTableView: UITableView!

    private var dbPathString = ""
    private var remedies: [Remedy] = []
    /// Section letters for the table index (issue #79).
    private var remedySections: [String] = []
    /// Remedies grouped by section letter (issue #79).
    private var remediesBySection: [String: [Remedy]] = [:]
    private var selectedRID = 0
    /// Number of remedies, for Lite version tracking.
    private var remedyCount = 0

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGlobalVars()
        myTableView.delegate = self
        myTableView.dataSource = self
        loadTableData()
        FormFunctions.setBackGroundImage(view)
        FormFunctions.setBackGroundImage(myTableView)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addRemedy))
        tableView.allowsSelectionDuringEditing = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    // MARK: Data

    @IBAction func refresh(_ sender: UIRefreshControl) {
        loadTableData()
        sender.endRefreshing()
        addNavButton()
    }

    private func reloadData() {
        setupGlobalVars()
        loadTableData()
        addNavButton()
    }

    private func setupGlobalVars() {
        dbPathString = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
    }

    /// Load the remedies from the database and update the tab badges.
    private func loadTableData() {
        do {
            remedies = try OilRemedies.allRemedies(databasePath: dbPathString)
        } catch {
            remedies = []
            FormFunctions.checkForError(error, title: "LoadData", viewController: self)
        }

        if MYSettings.useSectionsRemedies {
            remediesBySection = Dictionary(grouping: remedies, by: \.section)
            var seen = Set<String>()
            remedySections = remedies.map(\.section).filter { seen.insert($0).inserted }
        }
        myTableView.reloadData()

        let inStockCount = (try? OilLists.inStockCount(databasePath: dbPathString)) ?? 0
        let oilCount = (try? BurnSoftDatabase.totalRows(inTable: "eo_oil_list", databasePath: dbPathString)) ?? 0
        let reOrderCount = (try? OilLists.shoppingCount(databasePath: dbPathString)) ?? 0
        if let items = tabBarController?.tabBar.items, items.count > 2 {
            items[0].badgeValue = inStockCount == 0 ? "\(oilCount)" : "\(inStockCount)/\(oilCount)"
            items[2].badgeValue = reOrderCount > 0 ? "\(reOrderCount)" : nil
        }

        remedyCount = remedies.count
        navigationController?.tabBarItem.badgeValue = "\(remedies.count)"
    }

    /// The remedy shown at the index path.
    private func remedy(at indexPath: IndexPath) -> Remedy {
        if MYSettings.useSectionsRemedies {
            return remediesBySection[remedySections[indexPath.section], default: []][indexPath.row]
        }
        return remedies[indexPath.row]
    }

    // MARK: Navigation Button

    /// Add the Add button to the navigation bar, unless the Lite limit has been reached.
    private func addNavButton() {
        if MYSettings.isLiteVersion && remedyCount > MYSettings.liteLimit - 1 {
            navigationItem.rightBarButtonItem = nil
            FormFunctions.alertOnLimit(for: self)
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addRemedy))
        }
    }

    @objc private func addRemedy() {
        performSegue(withIdentifier: "segueNewRemedy", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueViewRemedy", let destination = segue.destination as? VIEW_RemedyViewController {
            destination.rid = selectedRID
        }
    }

    // MARK: Table View

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        MYSettings.useSectionsRemedies ? remedySections.count : 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        MYSettings.useSectionsRemedies ? remedySections[section] : nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        MYSettings.useSectionsRemedies ? remediesBySection[remedySections[section], default: []].count : remedies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        FormFunctions.setBackGroundImage(cell.contentView)

        let remedy = remedy(at: indexPath)
        cell.textLabel?.text = remedy.name
        cell.tag = remedy.rid

        if MYSettings.useSectionsRemedies {
            tableView.backgroundColor = FormFunctions.defaultBackgroundColor
            // Colors of the index bar.
            tableView.sectionIndexColor = FormFunctions.textColor
            tableView.sectionIndexBackgroundColor = FormFunctions.defaultBackground
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRID = remedy(at: indexPath).rid
        performSegue(withIdentifier: "segueViewRemedy", sender: self)
    }

    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let remedy = remedy(at: indexPath)

        let editAction = UIContextualAction(style: .destructive, title: "Edit") { [weak self] _, _, completion in
            guard let self,
                  let destination = storyboard?.instantiateViewController(withIdentifier: "EditRemedy_Description_ViewController") as? EDIT_RemedyViewController else {
                completion(false)
                return
            }
            destination.rid = remedy.rid
            navigationController?.pushViewController(destination, animated: true)
            completion(true)
        }
        editAction.backgroundColor = .blue

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self else { return }
            do {
                try OilRemedies.deleteRemedy(id: remedy.rid, databasePath: dbPathString)
                FormFunctions.sendMessage("\(remedy.name) was deleted!", title: "Delete", viewController: self)
            } catch {
                FormFunctions.sendMessage("Error while deleting! \(error.localizedDescription)", title: "ERROR", viewController: self)
            }
            reloadData()
            completion(true)
        }
        deleteAction.backgroundColor = FormFunctions.deleteColor

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        MYSettings.useSectionsRemedies ? remedySections : nil
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        index
    }

    /// Section header with the custom background, font and color.
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let width = tableView.bounds.width
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: FormFunctions.tableHeaderHeight))
        headerView.backgroundColor = FormFunctions.defaultBackground
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: FormFunctions.headerTextHeight))
        label.font = FormFunctions.headerTextFont
        label.text = "     \(remedySections[section])"
        headerView.addSubview(label)
        return headerView
    }
}
