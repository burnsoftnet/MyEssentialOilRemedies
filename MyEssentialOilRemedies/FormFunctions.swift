//
//  FormFunctions.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/23/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

import UIKit

/// Shared UI styling, alert and logging helpers used by all the forms.
enum FormFunctions {

    // MARK: Borders

    /// Creates a border around a text view.
    static func setBordersTextView(_ view: UITextView?) {
        applyBorder(to: view, color: .gray)
    }

    /// Creates a border around a regular text box.
    static func setBorderTextBox(_ textField: UITextField?) {
        applyBorder(to: textField, color: .gray)
    }

    /// Creates a border around a label.
    static func setBorderLabel(_ label: UILabel?) {
        applyBorder(to: label, color: .systemGray)
    }

    /// Creates a rounded border around a button.
    static func setBorderButton(_ button: UIButton?) {
        guard let button else { return }
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.layer.borderWidth = 2.3
        button.layer.cornerRadius = 10
        button.layer.allowsEdgeAntialiasing = true
        button.clipsToBounds = true
    }

    private static func applyBorder(to view: UIView?, color: UIColor) {
        guard let view else { return }
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = 2.3
        view.layer.cornerRadius = 2
    }

    // MARK: Colors and Fonts

    /// Set the background of a view to the default background image.
    static func setBackGroundImage(_ view: UIView?) {
        guard let view else { return }
        view.backgroundColor = defaultViewBackground
        // The Objective-C version assigned YES (1) to the mask, which is .flexibleLeftMargin.
        view.autoresizingMask = .flexibleLeftMargin
    }

    /// Highlight color for rows that are in stock.
    static var highlightColor: UIColor { .green }

    /// Color used for the table index text.
    static var textColor: UIColor { .white }

    /// Font for the table section headers.
    static var headerTextFont: UIFont { .boldSystemFont(ofSize: 18) }

    /// Expected height of the table header text.
    static var headerTextHeight: CGFloat { 18 }

    /// Height of the table section header.
    static var tableHeaderHeight: CGFloat { 30 }

    /// Default background color.
    static var defaultBackgroundColor: UIColor? { UIColor(named: "CustomColor") }

    /// Default background pattern, used for the table headers and index.
    static var defaultBackground: UIColor {
        UIImage(named: "systemBrown.png").map { UIColor(patternImage: $0) } ?? .brown
    }

    /// Default view background pattern.
    static var defaultViewBackground: UIColor {
        UIImage(named: "Background2.png").map { UIColor(patternImage: $0) } ?? .clear
    }

    /// Color of the edit swipe action.
    static var editColor: UIColor { .systemBlue }

    /// Color of the delete swipe action.
    static var deleteColor: UIColor { .systemRed }

    /// Color of the shopping cart swipe action.
    static var cartColor: UIColor { .systemGray }

    // MARK: Alerts

    /// Show a simple message box with an OK button on the view controller.
    static func sendMessage(_ message: String, title: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }

    /// Alert that the Lite limit was reached and offer to buy the full version from the App Store.
    static func alertOnLimit(for viewController: UIViewController) {
        let alert = UIAlertController(title: "Limit Reached!",
                                      message: "You Have reached your limit on the Lite Version!\n Please Purchase the Regular Version for Unlimited access!",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Purchase", style: .default) { _ in
            if let appStore = URL(string: "https://itunes.apple.com/us/app/my-essential-oil-remedies/id1188303079?ls=1&mt=8") {
                UIApplication.shared.open(appStore)
            }
        })
        alert.addAction(UIAlertAction(title: "No Thanks", style: .default))
        viewController.present(alert, animated: true)
    }

    /// Show the error in a message box if there is one.
    static func checkForError(_ errorMessage: String, title: String, viewController: UIViewController) {
        guard !errorMessage.isEmpty else { return }
        doBuggermeMessage(errorMessage, from: "CheckForError.\(title)")
        sendMessage(errorMessage, title: "\(title) Error", viewController: viewController)
    }

    /// Show the error in a message box if one was thrown.
    static func checkForError(_ error: Error?, title: String, viewController: UIViewController) {
        checkForError(error?.localizedDescription ?? "", title: title, viewController: viewController)
    }

    // MARK: Logging

    /// Write the error to the log if there is one.
    static func checkForErrorLogOnly(_ errorMessage: String, title: String) {
        guard !errorMessage.isEmpty else { return }
        doBuggermeMessage(errorMessage, from: "CheckForError.\(title)")
        NSLog("%@", errorMessage)
    }

    /// Runtime debugging messages, only written in debug builds when `MYSettings.buggerMe` is on.
    static func doBuggermeMessage(_ message: String, from location: String) {
        #if DEBUG
        if MYSettings.buggerMe {
            NSLog("DEBUG - %@ - %@", location, message)
        }
        #endif
    }

    /// General method for logging errors that were caught.
    static func logError(from location: String, error: Error) {
        NSLog("Exception Error from %@  - %@", location, error.localizedDescription)
    }
}
