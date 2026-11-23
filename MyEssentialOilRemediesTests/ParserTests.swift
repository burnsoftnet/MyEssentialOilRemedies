//
//  ParserTests.swift
//  My Essential Oil Remedies Tests
//
//  Unit tests for Parser: XML generation for AirDrop sharing
//  and parsing the generated XML back into oil/remedy values.
//

import Foundation
import Testing
@testable import My_Essential_Oil_Remedies

final class ParserTests {
    private var tempFiles: [String] = []

    deinit {
        for path in tempFiles {
            try? FileManager.default.removeItem(atPath: path)
        }
    }

    // MARK: Helpers

    private func writeXMLToTempFile(_ xml: String, extension ext: String) throws -> String {
        let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("ParserTests-\(UUID().uuidString).\(ext)")
        try xml.write(toFile: path, atomically: true, encoding: .utf8)
        tempFiles.append(path)
        return path
    }

    private var lavenderOilXML: String {
        Parser.oilDetailsToXML(name: "Lavender", commonName: "True Lavender", botanicalName: "Lavandula angustifolia",
                               ingredients: "100 percent lavender", safetyNotes: "Dilute before use", color: "Clear",
                               viscosity: "Thin", inStock: "1", vendor: "BurnSoft", website: "www.burnsoft.net",
                               description: "Calming oil", isBlend: "0")
    }

    private var sleepAidRemedyXML: String {
        Parser.remedyDetailsToXML(name: "Sleep Aid", description: "Helps with sleep", uses: "Diffuse at night",
                                  oils: ["Lavender", "Peppermint"])
    }

    // MARK: XML Generation

    @Test(arguments: [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>", "<oils>", "</oils>",
        "<Name>Lavender</Name>", "<commonName>True Lavender</commonName>",
        "<BotanicalName>Lavandula angustifolia</BotanicalName>", "<ingredients>100 percent lavender</ingredients>",
        "<safetyNotes>Dilute before use</safetyNotes>", "<color>Clear</color>", "<viscosity>Thin</viscosity>",
        "<instock>1</instock>", "<vendor>BurnSoft</vendor>", "<website>www.burnsoft.net</website>",
        "<description>Calming oil</description>", "<isblend>0</isblend>",
    ])
    func oilXMLContainsElement(_ element: String) {
        #expect(lavenderOilXML.contains(element))
    }

    @Test(arguments: [
        "<remedy>", "</remedy>", "<RemedyName>Sleep Aid</RemedyName>", "<description>Helps with sleep</description>",
        "<uses>Diffuse at night</uses>", "<oilList>", "<OilName>Lavender</OilName>",
        "<OilName>Peppermint</OilName>", "</oilList>",
    ])
    func remedyXMLContainsElement(_ element: String) {
        #expect(sleepAidRemedyXML.contains(element))
    }

    // MARK: Parsing Round Trip

    @Test func parsingOilXMLPopulatesOilValues() throws {
        let parser = Parser(xmlFile: try writeXMLToTempFile(lavenderOilXML, extension: "meo"))

        #expect(parser.isOil)
        #expect(!parser.isRemedy)
        #expect(parser.dataType == "oil")
        #expect(parser.oilName == "Lavender")
        #expect(parser.oilCommonName == "True Lavender")
        #expect(parser.oilBotanicalName == "Lavandula angustifolia")
        #expect(parser.oilIngredients == "100 percent lavender")
        #expect(parser.oilSafetyNotes == "Dilute before use")
        #expect(parser.oilColor == "Clear")
        #expect(parser.oilViscosity == "Thin")
        #expect(parser.oilInStock == "1")
        #expect(parser.oilVendor == "BurnSoft")
        #expect(parser.oilWebsite == "www.burnsoft.net")
        #expect(parser.oilDescription == "Calming oil")
        #expect(parser.oilDetails.description == "Calming oil")
    }

    @Test func parsingRemedyXMLPopulatesRemedyValues() throws {
        let parser = Parser(xmlFile: try writeXMLToTempFile(sleepAidRemedyXML, extension: "meor"))

        #expect(parser.isRemedy)
        #expect(!parser.isOil)
        #expect(parser.dataType == "remedy")
        #expect(parser.remedyName == "Sleep Aid")
        #expect(parser.remedyDescription == "Helps with sleep")
        #expect(parser.remedyUses == "Diffuse at night")
        #expect(parser.remedyOils == ["Lavender", "Peppermint"])
    }

    @Test("A missing file leaves the parser empty instead of crashing")
    func missingFile() {
        let parser = Parser(xmlFile: "/nonexistent/file.meo")
        #expect(!parser.isOil)
        #expect(!parser.isRemedy)
    }
}
