//
//  MainStartViewController.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/23/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//
//  StoryboardiD: MainController

import UIKit

@objc(MainStartViewController)
final class MainStartViewController: UITabBarController {

    /// Prepare the database and start watching the inbox for shared oils and remedies.
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try BurnSoftDatabase.copyDbIfNeeded(MYSettings.dbName)
        } catch {
            FormFunctions.logError(from: "MainStartViewController.viewDidLoad", error: error)
        }
        DBUpgrade.checkDBVersionAgainstExpectedVersion()
        DatabaseManagement.startiCloudSync()

        NotificationCenter.default.addObserver(self, selector: #selector(checkInBox),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(checkInBox), userInfo: nil, repeats: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    /// Check for files to process from the inbox.
    @objc private func checkInBox() {
        if BurnSoftGeneral.newFilesFoundProcessing() {
            AirDropHandler.processAllInBoxFiles(from: self)
        }
    }
}
