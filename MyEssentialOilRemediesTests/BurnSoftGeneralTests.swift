//
//  BurnSoftGeneralTests.swift
//  My Essential Oil Remedies Tests
//
//  Unit tests for the string and file helpers in BurnSoftGeneral.
//

import Foundation
import Testing
@testable import My_Essential_Oil_Remedies

struct BurnSoftGeneralTests {

    @Test func fcStringEscapesQuotesAndTrims() {
        #expect(BurnSoftGeneral.fcString("  Tea Tree's  ") == "Tea Tree''s")
        #expect(BurnSoftGeneral.fcString("back`tick") == "back''tick")
    }

    @Test func fcStringXMLAlsoEscapesAmpersands() {
        #expect(BurnSoftGeneral.fcStringXML("Salt & Pepper's") == "Salt &amp; Pepper''s")
    }

    @Test func boolString() {
        #expect(BurnSoftGeneral.boolString(true) == "Yes")
        #expect(BurnSoftGeneral.boolString(false) == "No")
    }

    @Test func copyFileReplacesTheDestination() throws {
        let directory = (NSTemporaryDirectory() as NSString).appendingPathComponent(UUID().uuidString)
        try BurnSoftGeneral.createDirectoryIfNotExists(directory)
        defer { try? FileManager.default.removeItem(atPath: directory) }

        let source = directory + "/source.txt"
        let destination = directory + "/destination.txt"
        try "new".write(toFile: source, atomically: true, encoding: .utf8)
        try "old".write(toFile: destination, atomically: true, encoding: .utf8)

        try BurnSoftGeneral.copyFile(from: source, to: destination)
        #expect(try String(contentsOfFile: destination, encoding: .utf8) == "new")

        try BurnSoftGeneral.deleteFile(atPath: destination)
        #expect(!FileManager.default.fileExists(atPath: destination))
        // Deleting a file that's already gone succeeds.
        try BurnSoftGeneral.deleteFile(atPath: destination)
    }

    @Test func copyFileFailsWhenNeitherFileExists() {
        #expect(throws: DatabaseError.self) {
            try BurnSoftGeneral.copyFile(from: "/nonexistent/a", to: "/nonexistent/b")
        }
    }
}
