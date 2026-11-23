//
//  ManageOils.swift
//  iOS My Essential Oil Remedies UITests
//
//  Created by burnsoft on 12/26/20.
//  Copyright © 2020 burnsoft. All rights reserved.
//

import XCTest

/// UI tests to manage the oil section: add, edit, delete, etc.
final class ManageOils: XCTestCase {

    private let oilName = "Rosemary V2"
    private let oilIngredients = "Rosemary Rosmarinus officinalis leaf oil.  Rosemary Oil is extracted from the flowering rosemary tops using the steam distillation method"
    private let safe = "yeah it's safe"
    private let oilDescription = "Rosemary is a familiar herb with a strong woodsy scent that can promote feelings of clarity. Used in shampoos to enhance the color of dark hair, counters split ends, and reduces static charge. Great in massage oils and in the bath. Said to aid the memory.Blends well with clary sage pine, oregano, basil, geranium, tea tree, cinnamon, eucalyptus, thyme, peppermint, grapefruit, black pepper, bergamot, mandarin, frankincense, lemon, cedarwood, and lavender.  Aids with skin conditions such as acne, eczema, varicose veins, greasy skin, oily skin, dry skin, and insect bites.  Highly regarded for assisting with memory.  Cosmetically other than the use in skin care products it is commonly used in hair care products such as shampoos, conditioners, hair treatments, used to increase hair growth naturally as well.  Relieves symptoms of the common cold including, headache, fatigue, exhaustion, diarrhea, constipation, cough, whooping cough, and overall body discomfort.  Because it is a natural anti-inflammatory it may be used to treat rheumatism, arthritis, muscle pain, joint pain, and sore muscles."
    private let website = "http://www.burnsoft.net"
    private var commonName: String { oilName }
    private let botanicalName = "Rosmarinus officinalis"
    private let vendor = "BurnSoft"

    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = await XCUIApplication()
        await app.launch()
    }

    /// Add a junk test oil: open the oil section and type a few keys into a new oil.
    @MainActor
    func testAddOilJunk() {
        app.navigationBars["Oils"].buttons["Add"].tap()
        app.scrollViews.otherElements.textFields["Name on Bottle"].tap()

        let moreKey = app.keys["more"]
        moreKey.tap()
        moreKey.tap()

        let key = app.keys["2"]
        key.tap()
        key.tap()
        app.keys["more"].tap()
    }

    /// Add an oil: open the oil section and fill in every field of a new oil.
    @MainActor
    func testAddOil() {
        app.tabBars["Tab Bar"].buttons["Oils"].tap()
        app.navigationBars["Oils"].buttons["Add"].tap()

        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        elementsQuery.textFields["Name on Bottle"].tap()
        General.sendTextToKeyBoard(app, oilName)

        elementsQuery.textFields["Also Known As"].tap()
        General.sendTextToKeyBoard(app, commonName)

        elementsQuery.textFields["Formal Scientific Name"].tap()
        General.sendTextToKeyBoard(app, botanicalName)

        let nameOnBottleQuery = scrollViewsQuery.otherElements.containing(.textField, identifier: "Name on Bottle")
        nameOnBottleQuery.children(matching: .textView).element(boundBy: 0).tap()
        General.sendTextToKeyBoard(app, oilIngredients)

        nameOnBottleQuery.children(matching: .textView).element(boundBy: 1).tap()
        General.sendTextToKeyBoard(app, safe)

        let nameOnBottleElement = nameOnBottleQuery.element
        nameOnBottleElement.tap()
        elementsQuery.textFields["Blueish/green etc."].tap()
        General.sendTextToKeyBoard(app, "Blue")
        elementsQuery.textFields["Thick, Thin, etc."].tap()
        General.sendTextToKeyBoard(app, "Thick")

        elementsQuery.textFields["Company Name"].tap()
        General.sendTextToKeyBoard(app, vendor)

        elementsQuery.textFields["Link to Product"].tap()
        General.sendTextToKeyBoard(app, website)

        elementsQuery.staticTexts["Vendor:"].tap()
        nameOnBottleQuery.children(matching: .textView).element(boundBy: 2).tap()
        General.sendTextToKeyBoard(app, oilDescription)

        nameOnBottleElement.tap()
        app.scrollViews.otherElements.staticTexts["Add"].tap()
    }
}
