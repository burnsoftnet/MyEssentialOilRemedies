//
//  LIST_OilsTableViewController.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//
//  StoryboardiD: OilLists

import UIKit

@objc(LIST_OilsTableViewController)
final class LIST_OilsTableViewController: UITableViewController {

    @IBOutlet weak var myTableView: UITableView!

    private var dbPathString = ""
    private var oils: [Oil] = []
    /// Section letters for the table index (issue #63).
    private var oilSections: [String] = []
    /// Oils grouped by section letter (issue #63).
    private var oilsBySection: [String: [Oil]] = [:]
    private var selectedOID = 0
    /// Number of oils, for Lite version tracking.
    private var oilCount = 0

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGlobalVars()
        myTableView.delegate = self
        myTableView.dataSource = self
        loadData()

        tableView.allowsSelectionDuringEditing = false
        FormFunctions.setBackGroundImage(view)
        FormFunctions.setBackGroundImage(myTableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    // MARK: Data

    /// When you swipe down on the table, reload the data.
    @IBAction func refresh(_ sender: UIRefreshControl) {
        loadData()
        sender.endRefreshing()
        addNavButton()
    }

    /// Reload the data as if the view had first appeared.
    private func reloadData() {
        setupGlobalVars()
        loadData()
        addNavButton()
    }

    private func setupGlobalVars() {
        dbPathString = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
        FormFunctions.doBuggermeMessage(dbPathString, from: "LIST_OilsTableViewController.setupGlobalVars.DatabasePath")
    }

    /// Load the oils from the database and update the tab badges.
    private func loadData() {
        do {
            oils = try OilLists.allOils(databasePath: dbPathString)
        } catch {
            oils = []
            FormFunctions.checkForError(error, title: "LoadData:", viewController: self)
        }

        if MYSettings.useSectionsOil {
            oilsBySection = Dictionary(grouping: oils, by: \.section)
            var seen = Set<String>()
            oilSections = oils.map(\.section).filter { seen.insert($0).inserted }
        }
        myTableView.reloadData()

        let inStockCount = OilLists.inStockCount(in: oils)
        navigationController?.tabBarItem.badgeValue = inStockCount == 0 ? "\(oils.count)" : "\(inStockCount)/\(oils.count)"

        oilCount = oils.count
        let remedyCount = (try? BurnSoftDatabase.totalRows(inTable: "eo_remedy_list", databasePath: dbPathString)) ?? 0
        let tabItems = tabBarController?.tabBar.items ?? []
        if tabItems.count > 2 {
            tabItems[1].badgeValue = "\(remedyCount)"
            let reOrderCount = OilLists.shoppingCount(in: oils)
            tabItems[2].badgeValue = reOrderCount > 0 ? "\(reOrderCount)" : nil
        }
    }

    /// The oil shown at the index path.
    private func oil(at indexPath: IndexPath) -> Oil {
        if MYSettings.useSectionsOil {
            return oilsBySection[oilSections[indexPath.section], default: []][indexPath.row]
        }
        return oils[indexPath.row]
    }

    // MARK: Navigation Button

    /// Add the Add button to the navigation bar, unless the Lite limit has been reached.
    private func addNavButton() {
        if MYSettings.isLiteVersion && oilCount > MYSettings.liteLimit - 1 {
            navigationItem.rightBarButtonItem = nil
            FormFunctions.alertOnLimit(for: self)
        } else {
            let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addMoreOils))
            addButton.tintColor = .black
            navigationItem.rightBarButtonItem = addButton
        }
    }

    @objc private func addMoreOils() {
        performSegue(withIdentifier: "NewOil", sender: self)
    }

    // MARK: Table View

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        MYSettings.useSectionsOil ? oilSections.count : 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        MYSettings.useSectionsOil ? oilSections[section] : nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        MYSettings.useSectionsOil ? oilsBySection[oilSections[section], default: []].count : oils.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let oil = oil(at: indexPath)

        cell.textLabel?.text = oil.name
        cell.detailTextLabel?.text = oil.description
        cell.tag = oil.oid
        // Blends are shown in bold.
        cell.textLabel?.font = oil.isBlend ? .boldSystemFont(ofSize: 19) : .systemFont(ofSize: 16)

        if MYSettings.useSectionsOil {
            // Colors for the header and the index bar down the side.
            tableView.backgroundColor = FormFunctions.defaultBackgroundColor
            tableView.sectionIndexColor = FormFunctions.textColor
            tableView.sectionIndexTrackingBackgroundColor = FormFunctions.defaultBackgroundColor
            tableView.sectionIndexBackgroundColor = FormFunctions.defaultBackground
        }

        // Highlight oils that are in stock.
        if oil.inStock {
            cell.contentView.backgroundColor = FormFunctions.highlightColor
        } else {
            FormFunctions.setBackGroundImage(cell.contentView)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOID = oil(at: indexPath).oid
        performSegue(withIdentifier: "OilSelected", sender: self)
    }

    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let oil = oil(at: indexPath)
        let oid = oil.oid
        let oilName = oil.name

        let editAction = UIContextualAction(style: .destructive, title: "Edit") { [weak self] _, _, completion in
            guard let self,
                  let destination = storyboard?.instantiateViewController(withIdentifier: "EditOils") as? EDIT_OilDetailViewController else {
                completion(false)
                return
            }
            destination.oid = oid
            navigationController?.pushViewController(destination, animated: true)
            completion(true)
        }
        editAction.backgroundColor = FormFunctions.editColor

        let reOrderAction = UIContextualAction(style: .destructive, title: "Add to Shopping Cart") { [weak self] _, _, completion in
            guard let self else { return }
            do {
                try BurnSoftDatabase.runQuery("UPDATE eo_oil_list_details set reorder=1 where OID=\(oid)", databasePath: dbPathString)
                try? OilLists.updateStockStatus(false, oilID: oid, databasePath: dbPathString)
                FormFunctions.sendMessage("\(oilName) was put in the shopping cart!", title: "Order", viewController: self)
            } catch {
                FormFunctions.sendMessage("Error while adding to shopping cart! \(error.localizedDescription)", title: "ERROR", viewController: self)
            }
            reloadData()
            completion(true)
        }
        reOrderAction.backgroundColor = FormFunctions.cartColor

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self else { return }
            do {
                try BurnSoftDatabase.runQuery("Delete from eo_oil_list_details where OID=\(oid)", databasePath: dbPathString)
                try BurnSoftDatabase.runQuery("DELETE from eo_oil_list where ID=\(oid)", databasePath: dbPathString)
                FormFunctions.sendMessage("\(oilName) was deleted!", title: "Delete", viewController: self)
            } catch {
                FormFunctions.sendMessage("Error while deleting! \(error.localizedDescription)", title: "ERROR", viewController: self)
            }
            reloadData()
            completion(true)
        }
        deleteAction.backgroundColor = FormFunctions.deleteColor

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction, reOrderAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        MYSettings.useSectionsOil ? oilSections : nil
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
        label.text = "     \(oilSections[section])"
        headerView.addSubview(label)
        return headerView
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OilSelected", let destination = segue.destination as? VIEW_OilDetailsViewController {
            destination.oid = selectedOID
        }
    }
}
