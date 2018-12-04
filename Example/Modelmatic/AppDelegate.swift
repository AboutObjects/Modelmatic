//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder
{
    var window: UIWindow?
}

extension AppDelegate: UIApplicationDelegate
{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        configureAppearance()
        return true
    }
}

// MARK: - Configuring Appearance
extension AppDelegate
{
    func configureAppearance()
    {
        // Default background color for table views
        UITableView.appearance().backgroundColor = UIColor.headerColor
        // Default background color for table cells
        UITableViewCell.appearance().backgroundColor = UIColor.oddRowColor
        // Default text color for text fields contained in table cells
        UITextField.appearance(whenContainedInInstancesOf: [UITableViewCell.self])
            .textColor = UIColor.textColor
        // Default text color for ValueLabel (subclass of UILabel) contained in table cells
        ValueLabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self])
            .defaultTextColor = UIColor.textColor
    }
}

// MARK: - Color Scheme
extension UIColor
{
    class var oddRowColor: UIColor {
        return UIColor(red: 1.0, green: 0.99, blue: 0.97, alpha: 1.0)
    }
    class var evenRowColor: UIColor {
        return UIColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 1.0)
    }
    class var headerColor: UIColor {
        return UIColor(red: 0.93, green: 0.91, blue: 0.87, alpha: 1.0)
    }
    class var textColor: UIColor {
        return UIColor(red: 0.25, green: 0.125, blue: 0.0, alpha: 1.0)
    }
}

class ValueLabel: UILabel
{
    @objc dynamic var defaultTextColor: UIColor? {
        get { return textColor }
        set { textColor = newValue }
    }
}
