//
//  List_ReOrderTableViewController.swift
//  My Essential Oil Remedies
//
//  Created by burnsoft on 6/30/18.
//  Copyright © 2018 burnsoft. All rights reserved.
//

import UIKit

/// The shopping cart: oils that are marked for re-order.
@objc(List_ReOrderTableViewController)
final class List_ReOrderTableViewController: UITableViewController {

    @IBOutlet weak var myTableView: UITableView!

    private var dbPathString = ""
    private var reOrderList: [Oil] = []
    private var selectedOID = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGlobalVars()
        myTableView.delegate = self
        myTableView.dataSource = self
        loadData()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        myTableView.addSubview(refreshControl)
        FormFunctions.setBackGroundImage(view)
        FormFunctions.setBackGroundImage(myTableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    /// Reload the data from the database and refresh the table.
    func refreshData() {
        loadData()
    }

    private func setupGlobalVars() {
        dbPathString = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
        FormFunctions.doBuggermeMessage(dbPathString, from: "List_ReOrderTableViewController.setupGlobalVars.DatabasePath")
    }

    private func reloadData() {
        setupGlobalVars()
        loadData()
    }

    /// Refresh the data when the table is pulled down.
    @IBAction func refresh(_ sender: UIRefreshControl) {
        loadData()
        sender.endRefreshing()
    }

    private func loadData() {
        do {
            reOrderList = try OilLists.oilsForReOrder(databasePath: dbPathString)
        } catch {
            reOrderList = []
            FormFunctions.checkForError(error, title: "LoadData:", viewController: self)
        }
        myTableView.reloadData()

        let reOrderCount = (try? OilLists.shoppingCount(databasePath: dbPathString)) ?? 0
        if let items = tabBarController?.tabBar.items, items.count > 2 {
            items[2].badgeValue = reOrderCount > 0 ? "\(reOrderCount)" : nil
        }
    }

    // MARK: Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reOrderList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        FormFunctions.setBackGroundImage(cell.contentView)
        let oil = reOrderList[indexPath.row]
        cell.textLabel?.text = oil.name
        cell.detailTextLabel?.text = oil.description
        cell.tag = oil.oid
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let oil = reOrderList[indexPath.row]

        let inStockAction = UIContextualAction(style: .destructive, title: "Oil is Now In Stock.") { [weak self] _, _, completion in
            guard let self else { return }
            do {
                try BurnSoftDatabase.runQuery("UPDATE eo_oil_list_details set reorder=0 where OID=\(oil.oid)", databasePath: dbPathString)
                try? OilLists.updateStockStatus(true, oilID: oil.oid, databasePath: dbPathString)
                FormFunctions.sendMessage("\(oil.name) was removed from shopping cart and marked as In Stock!", title: "Order", viewController: self)
            } catch {
                FormFunctions.sendMessage("Error while removing from shopping cart! \(error.localizedDescription)", title: "ERROR", viewController: self)
            }
            reloadData()
            completion(true)
        }
        inStockAction.backgroundColor = .darkGray

        let removeAction = UIContextualAction(style: .destructive, title: "Remove from Cart") { [weak self] _, _, completion in
            guard let self else { return }
            do {
                try BurnSoftDatabase.runQuery("UPDATE eo_oil_list_details set reorder=0 where OID=\(oil.oid)", databasePath: dbPathString)
                FormFunctions.sendMessage("\(oil.name) was removed from shopping cart!", title: "Order", viewController: self)
            } catch {
                FormFunctions.sendMessage("Error while removing from shopping cart! \(error.localizedDescription)", title: "ERROR", viewController: self)
            }
            reloadData()
            completion(true)
        }
        removeAction.backgroundColor = .red

        let configuration = UISwipeActionsConfiguration(actions: [inStockAction, removeAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOID = reOrderList[indexPath.row].oid
        performSegue(withIdentifier: "segueShoppingViewOil", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShoppingViewOil", let destination = segue.destination as? VIEW_OilDetailsViewController {
            destination.oid = selectedOID
        }
    }
}
