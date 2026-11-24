//
//  Parser.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 4/28/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

import Foundation

/// Reads the oil (.meo) and remedy (.meor) XML files that are shared between devices,
/// and formats oil and remedy details into that XML.
final class Parser: NSObject, XMLParserDelegate {

    private(set) var isOil = false
    private(set) var isRemedy = false
    private(set) var dataType = ""

    // Oil values
    private(set) var oilName = ""
    private(set) var oilInStock = ""
    private(set) var oilIsBlend = ""
    private(set) var oilDescription = ""
    private(set) var oilBotanicalName = ""
    private(set) var oilIngredients = ""
    private(set) var oilSafetyNotes = ""
    private(set) var oilColor = ""
    private(set) var oilViscosity = ""
    private(set) var oilCommonName = ""
    private(set) var oilVendor = ""
    private(set) var oilWebsite = ""

    // Remedy values
    private(set) var remedyName = ""
    private(set) var remedyDescription = ""
    private(set) var remedyUses = ""
    private(set) var remedyOils: [String] = []

    /// Text collected for the element currently being parsed.
    private var element = ""

    /// Parse the XML file at the path.
    init(xmlFile path: String) {
        super.init()
        guard let parser = XMLParser(contentsOf: URL(fileURLWithPath: path)) else { return }
        parser.delegate = self
        parser.parse()
    }

    /// The oil details from the file, ready to insert or update in the database.
    var oilDetails: OilDetails {
        OilDetails(description: oilDescription, botanicalName: oilBotanicalName, ingredients: oilIngredients,
                   safetyNotes: oilSafetyNotes, color: oilColor, viscosity: oilViscosity, commonName: oilCommonName,
                   vendor: oilVendor, website: oilWebsite, isBlend: Int(oilIsBlend) == 1)
    }

    // MARK: XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        FormFunctions.doBuggermeMessage("Started Element \(elementName)", from: "Parser.didStartElement")
        element = ""
        if elementName == "oils" {
            isOil = true
            isRemedy = false
            dataType = "oil"
        } else if elementName == "remedy" {
            isRemedy = true
            isOil = false
            dataType = "remedy"
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        FormFunctions.doBuggermeMessage("Found an element named: \(elementName) with a value of: \(element)", from: "Parser.didEndElement")
        if isOil {
            setOilDetail(column: elementName, value: element)
        }
        if isRemedy {
            setRemedyDetail(column: elementName, value: element)
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        element += string
    }

    // MARK: Private

    private func setRemedyDetail(column: String, value: String) {
        switch column {
        case "RemedyName": remedyName = value
        case "description": remedyDescription = value
        case "uses": remedyUses = value
        case "OilName": remedyOils.append(value)
        default: break
        }
    }

    private func setOilDetail(column: String, value: String) {
        switch column {
        case "Name": oilName = value
        case "commonName": oilCommonName = value
        case "BotanicalName": oilBotanicalName = value
        case "ingredients": oilIngredients = value
        case "safetyNotes": oilSafetyNotes = value
        case "color": oilColor = value
        case "viscosity": oilViscosity = value
        case "instock": oilInStock = value
        case "vendor": oilVendor = value
        case "website": oilWebsite = value
        case "description": oilDescription = value
        default: break
        }
    }

    // MARK: Formatting

    /// Format a single XML element, optionally followed by a new line.
    private static func xmlElement(_ name: String, value: String, newLine: Bool = false) -> String {
        "<\(name)>\(value)</\(name)>" + (newLine ? "\n" : "")
    }

    /// Format the oil details into the XML used for sharing oils.
    static func oilDetailsToXML(name: String, commonName: String, botanicalName: String, ingredients: String,
                                safetyNotes: String, color: String, viscosity: String, inStock: String,
                                vendor: String, website: String, description: String, isBlend: String) -> String {
        var output = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<oils>\n"
        output += xmlElement("Name", value: name)
        output += xmlElement("commonName", value: commonName)
        output += xmlElement("BotanicalName", value: botanicalName)
        output += xmlElement("ingredients", value: ingredients)
        output += xmlElement("safetyNotes", value: safetyNotes)
        output += xmlElement("color", value: color)
        output += xmlElement("viscosity", value: viscosity)
        output += xmlElement("instock", value: inStock)
        output += xmlElement("vendor", value: vendor)
        output += xmlElement("website", value: website)
        output += xmlElement("description", value: description)
        output += xmlElement("isblend", value: isBlend)
        output += "</oils>\n"
        return output
    }

    /// Format the remedy details into the XML used for sharing remedies.
    static func remedyDetailsToXML(name: String, description: String, uses: String, oils: [String]) -> String {
        var output = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<remedy>\n"
        output += xmlElement("RemedyName", value: name)
        output += xmlElement("description", value: description)
        output += xmlElement("uses", value: uses)
        output += "<oilList>\n"
        for oil in oils {
            output += xmlElement("OilName", value: oil)
        }
        output += "</oilList>\n"
        output += "</remedy>\n"
        return output
    }
}
