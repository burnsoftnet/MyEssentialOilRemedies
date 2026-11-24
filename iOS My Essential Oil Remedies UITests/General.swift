//
//  General.swift
//  iOS My Essential Oil Remedies UITests
//
//  Created by burnsoft on 12/25/20.
//  Copyright © 2020 burnsoft. All rights reserved.
//

import XCTest

/// Helpers shared by the UI tests.
enum General {

    /// Type a string on the software keyboard one key at a time, switching to the number
    /// keyboard for digits and back again afterwards.
    @MainActor
    static func sendTextToKeyBoard(_ app: XCUIApplication, _ value: String) {
        for character in value {
            var key = String(character)
            var isNumber = character.isASCII && character.isNumber
            if key == " " {
                key = "space"
            }
//            else if isNumber {
//                app.keys["more"].tap()
//            }
//            app.keys[key].tap()
//            if isNumber {
//                app.keys["more"].tap()
//            }
        }
    }
}
