//
//  iOS_My_Essential_Oil_Remedies_UITests.swift
//  iOS My Essential Oil Remedies UITests
//
//  Created by burnsoft on 12/25/20.
//  Copyright © 2020 burnsoft. All rights reserved.
//

import XCTest

final class iOS_My_Essential_Oil_Remedies_UITests: XCTestCase {

    override func setUp() async throws {
        continueAfterFailure = false
    }

    @MainActor
    func testRunApp() {
        XCUIApplication().launch()
    }

    /// Measures how long it takes to launch the application.
    @MainActor
    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
