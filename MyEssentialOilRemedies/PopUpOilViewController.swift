//
//  PopUpOilViewController.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 9/13/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

import UIKit

/// Pop-up with a quick description of an oil, shown from a remedy.
@objc(PopUpOilViewController)
class PopUpOilViewController: UIViewController {

    /// Name of the oil to show.
    var oilName = ""

    @IBOutlet weak var lblOilName: UILabel?
    @IBOutlet weak var lblDescription: UITextView?

    private var dbPathString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        lblOilName?.text = ""
        lblDescription?.text = ""
        loadSettings()
        loadData()
    }

    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true)
    }

    private func loadSettings() {
        dbPathString = BurnSoftDatabase.databasePath(for: MYSettings.dbName)
        FormFunctions.setBorderLabel(lblOilName)
        FormFunctions.setBordersTextView(lblDescription)
    }

    /// Load the name and description of the oil from the database.
    private func loadData() {
        do {
            let db = try SQLiteConnection(path: dbPathString)
            try db.query("select * from view_eo_oil_list_all where name='\(BurnSoftGeneral.fcString(oilName))'") { row in
                if !row.isNull(1) { lblOilName?.text = row.string(1) }
                if !row.isNull(4) { lblDescription?.text = row.string(4) }
            }
        } catch {
            FormFunctions.checkForError(error, title: "Load Oil Details", viewController: self)
        }
    }
}

/// The same oil pop-up, shown from search.
@objc(PopUpOilSearchViewController)
final class PopUpOilSearchViewController: PopUpOilViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        FormFunctions.setBackGroundImage(view)
    }
}
