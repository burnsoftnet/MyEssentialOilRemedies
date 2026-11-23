//
//  ActionClass.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 4/4/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

import UIKit

/// Builds the text and files for sharing oils and remedies, and presents the share sheet.
enum ActionClass {

    /// Present a share sheet to send data to another device (AirDrop, Messages, Mail, Notes, etc.).
    /// On iPad the sheet is shown in a popover anchored to `barButtonItem`.
    static func sendToActionSheet(from viewController: UIViewController, items: [Any], emailSubject: String,
                                  barButtonItem: UIBarButtonItem?) {
        let activityItems = items.map { ShareItem(item: $0, subject: emailSubject) }
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        if let popover = controller.popoverPresentationController {
            popover.permittedArrowDirections = .any
            if let barButtonItem {
                popover.barButtonItem = barButtonItem
            } else {
                popover.sourceView = viewController.view
            }
        }
        viewController.present(controller, animated: true)
    }

    /// Append a "field: value" line to the output.
    static func appendToOutput(_ output: String, field: String, value: String) -> String {
        output + "\(field): \(value)\n"
    }

    /// Write the oil XML to OilDetails.meo in Documents.
    /// - Returns: The path of the file.
    static func writeOilDetailsToFile(_ output: String) -> String {
        writeToDocuments(output, fileName: "OilDetails.meo", location: "writeOilDetailsToFile")
    }

    /// Write the remedy XML to RemedyDetails.meor in Documents.
    /// - Returns: The path of the file.
    static func writeRemedyDetailsToFile(_ output: String) -> String {
        writeToDocuments(output, fileName: "RemedyDetails.meor", location: "writeRemedyDetailsToFile")
    }

    private static func writeToDocuments(_ output: String, fileName: String, location: String) -> String {
        let path = (BurnSoftGeneral.documentsDirectory as NSString).appendingPathComponent(fileName)
        do {
            try output.write(toFile: path, atomically: true, encoding: .utf8)
        } catch {
            FormFunctions.logError(from: "ActionClass.\(location)", error: error)
        }
        return path
    }

    /// All the oil detail fields formatted as one string for sharing.
    static func oilDetailsToString(name: String, commonName: String, botanicalName: String, ingredients: String,
                                   safetyNotes: String, color: String, viscosity: String, inStock: String,
                                   vendor: String, website: String, description: String, isBlend: String) -> String {
        var output = "Oil Name: \(name)\n"
        output = appendToOutput(output, field: "Common Name", value: commonName)
        output = appendToOutput(output, field: "Botanical Name", value: botanicalName)
        output = appendToOutput(output, field: "Ingredients", value: ingredients)
        output = appendToOutput(output, field: "Safety Notes", value: safetyNotes)
        output = appendToOutput(output, field: "Color", value: color)
        output = appendToOutput(output, field: "Viscosity", value: viscosity)
        output = appendToOutput(output, field: "In-Stock", value: inStock)
        output = appendToOutput(output, field: "Vendor", value: vendor)
        output = appendToOutput(output, field: "WebSite", value: website)
        output = appendToOutput(output, field: "Description", value: description)
        output = appendToOutput(output, field: "Is-Blend", value: isBlend)
        return output
    }

    /// All the remedy detail fields formatted as one string for sharing.
    static func remedyDetailsToString(name: String, description: String, oils: String, howToUse: String) -> String {
        var output = "Remedy Name: \(name)\n"
        output = appendToOutput(output, field: "Description", value: description)
        output = appendToOutput(output, field: "\nOils", value: "\n")
        output += oils
        output = appendToOutput(output, field: "\n\nHow To Use", value: howToUse)
        return output
    }
}

/// Wraps a share sheet item so Mail gets a subject line.
private final class ShareItem: NSObject, UIActivityItemSource {
    let item: Any
    let subject: String

    init(item: Any, subject: String) {
        self.item = item
        self.subject = subject
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        item
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        item
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        subject
    }
}
