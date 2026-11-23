//
//  MyEssentialOilRemediesTests.swift
//  My Essential Oil Remedies Tests
//
//  Shared helpers for the unit test suite.
//

import Foundation
import Testing
@testable import My_Essential_Oil_Remedies

/// A disposable copy of the factory MEO.db that ships inside the host app bundle,
/// so each test works against its own database. The copy is deleted when the object goes away.
final class TemporaryDatabase {
    let path: String

    init() throws {
        let source = try #require(Bundle.main.path(forResource: "MEO", ofType: "db"),
                                  "The factory MEO.db is missing from the host app bundle")
        path = (NSTemporaryDirectory() as NSString).appendingPathComponent("MEO-\(UUID().uuidString).db")
        try FileManager.default.copyItem(atPath: source, toPath: path)
    }

    deinit {
        try? FileManager.default.removeItem(atPath: path)
    }
}
