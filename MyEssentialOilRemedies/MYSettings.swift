//
//  MYSettings.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/23/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

import Foundation

/// App-wide constants and settings.
enum MYSettings {
    /// Database name.
    static let dbName = "MEO.db"
    /// Expected database version for the current version of this app.
    static let dbVersion = 1.4
    /// Display name of the full (non-Lite) version of the app.
    static let fullVersionName = "My Essential Oil Remedies"

    /// When true, debug messages are written to the console (debug builds only).
    #if DEBUG
    static let buggerMe = true
    #else
    static let buggerMe = false
    #endif

    /// Group the oil list into alphabetical sections.
    static let useSectionsOil = true
    /// Group the remedy list into alphabetical sections.
    static let useSectionsRemedies = true
    /// Maximum number of oils or remedies in the Lite version.
    static let liteLimit = 15

    /// True if the application is the Lite version, which restricts the number of items that can be entered.
    static var isLiteVersion: Bool {
        let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        return displayName != fullVersionName
    }
}
