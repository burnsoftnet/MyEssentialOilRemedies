//
//  RunViewingTests.swift
//  iOS My Essential Oil Remedies UITests
//
//  Created by burnsoft on 12/25/20.
//  Copyright © 2020 burnsoft. All rights reserved.
//

import XCTest

/// UI tests that browse each section of the app.
final class RunViewingTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = await XCUIApplication()
        await app.launch()
    }

    /// Open the oil section and view the Rosemary oil details.
    @MainActor
    func testViewOils() {
        let tablesQuery = app.tables
        tablesQuery.otherElements["Section index"].tap()
        tablesQuery.staticTexts["Rosemary"].tap()

        let scrollViewsQuery = app.scrollViews
        let toolbarElement = scrollViewsQuery.otherElements.containing(.toolbar, identifier: "Toolbar").element
        toolbarElement.tap()
        toolbarElement.tap()

        scrollViewsQuery.otherElements.containing(.toolbar, identifier: "Toolbar")
            .children(matching: .textView).element(boundBy: 2).tap()
        toolbarElement.tap()
        toolbarElement.tap()
        toolbarElement.tap()

        let toolbar = scrollViewsQuery.otherElements.toolbars["Toolbar"]
        toolbar.buttons["Related Remedies"].tap()
        toolbar.buttons["Description"].tap()
        app.navigationBars["View Oil Details"].buttons["Oils"].tap()
    }

    /// Open the remedy section and view the Detox and Allergy Migraines remedies.
    @MainActor
    func testViewRemedies() {
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Remedies"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["Detox"].tap()

        let toolbar = app.toolbars["Toolbar"]
        let oilsButton = toolbar.buttons["Oils"]
        let usesButton = toolbar.buttons["Uses"]
        let dotButton = toolbar.buttons["Dismiss context menu"]
        let closeButton = toolbar.buttons["Close"]
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let dismissElement = springboard.descendants(matching: .any)["Dismiss context menu"]
        oilsButton.tap()
        usesButton.tap()
        dismissElement.tap()
        closeButton.tap()

        tablesQuery.staticTexts["Allergy Migraines"].tap()
        toolbar.buttons["Description"].tap()
        oilsButton.tap()
        usesButton.tap()
        closeButton.tap()
        tabBar.buttons["Oils"].tap()
    }

    /// Open the shopping section and view the oils in the cart.
    @MainActor
    func testViewShopping() {
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Shopping"].tap()

        let tablesQuery = app.tables
        tablesQuery.cells.containing(.staticText, identifier: "Lemon").element.tap()

        let shoppingCartButton = app.navigationBars["View Oil Details"].buttons["Shopping Cart"]
        shoppingCartButton.tap()
        tablesQuery.cells.containing(.staticText, identifier: "Orange").element.tap()
        shoppingCartButton.tap()
        tabBar.buttons["Oils"].tap()
    }

    /// Open the settings section and the iTunes file sharing backup screen.
    @MainActor
    func testViewSettings() {
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Settings"].tap()
        let version = "1.3.16.18"
        let dbVersion = "1.4"
        let elementsQuery = app.scrollViews.otherElements
        elementsQuery.staticTexts["   Use iTunes File Sharing for Backup & Restore   "].tap()
        app.navigationBars["Settings Nav Controller"].buttons["Settings"].tap()
        elementsQuery.staticTexts[version].press(forDuration: 0.9)
        elementsQuery.staticTexts[version].press(forDuration: 0.9)
        elementsQuery.staticTexts[dbVersion].press(forDuration: 0.6)
        tabBar.buttons["Oils"].tap()
    }
}
