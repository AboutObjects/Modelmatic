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
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
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
        UITableView.appearance().backgroundColor = UIColor.headerColor()
        UITableViewCell.appearance().backgroundColor = UIColor.oddRowColor()
    }
}

// MARK: - Codex Color Scheme
extension UIColor
{
    public class func oddRowColor() -> UIColor {
        return UIColor(red: 1.0, green: 0.99, blue: 0.97, alpha: 1.0)
    }
    
    public class func evenRowColor() -> UIColor {
        return UIColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 1.0)
    }
    
    public class func headerColor() -> UIColor {
        return UIColor(red: 0.93, green: 0.91, blue: 0.87, alpha: 1.0)
    }
}
