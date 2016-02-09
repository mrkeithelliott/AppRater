//
//  APAppRater.swift
//  AppRaterSample
//
//  Created by Keith Elliott on 2/9/16.
//  Copyright © 2016 GittieLabs. All rights reserved.
//

import UIKit

let AP_APP_LAUNCHES = "com.gittielabs.applaunches"
let AP_APP_LAUNCHES_CHANGED = "com.gittielabs.applaunches.changed"
let AP_INSTALL_DATE = "com.gittielabs.install_date"
let AP_APP_RATING_SHOWN = "com.gittielabs.app_rating_shown"

public class APAppRater: NSObject, UIAlertViewDelegate {
    var application: UIApplication!
    var userdefaults = NSUserDefaults()
    let requiredLaunchesBeforeRating = 0
    public var appId: String!
    
    public static var sharedInstance = APAppRater()
    
    //MARK: - Initialize
    override init() {
        super.init()
        setup()
    }
    
    func setup(){
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidFinishLaunching:" , name: UIApplicationDidFinishLaunchingNotification, object: nil)
    }
    
    //MARK: - NSNotification Observers
    func appDidFinishLaunching(notification: NSNotification){
        if let _application = notification.object as? UIApplication{
            self.application = _application
            displayRatingsPromptIfRequired()
        }
    }
    
    //MARK: - App Launch count
    func getAppLaunchCount() -> Int {
        let launches = userdefaults.integerForKey(AP_APP_LAUNCHES)
        return launches
    }
    
    func incrementAppLaunches(){
        var launches = userdefaults.integerForKey(AP_APP_LAUNCHES)
        launches++
        userdefaults.setInteger(launches, forKey: AP_APP_LAUNCHES)
        userdefaults.synchronize()
    }
    
    func resetAppLaunches(){
        userdefaults.setInteger(0, forKey: AP_APP_LAUNCHES)
        userdefaults.synchronize()
    }
    
    //MARK: - First Launch Date
    func setFirstLaunchDate(){
        userdefaults.setValue(NSDate(), forKey: AP_INSTALL_DATE)
        userdefaults.synchronize()
    }
    
    func getFirstLaunchDate()->NSDate{
        if let date = userdefaults.valueForKey(AP_INSTALL_DATE) as? NSDate{
            return date
        }
    
        return NSDate()
    }
    
    //MARK: App Rating Shown
    func setAppRatingShown(){
        userdefaults.setBool(true, forKey: AP_APP_RATING_SHOWN)
        userdefaults.synchronize()
    }
    
    func hasShownAppRating()->Bool{
        let shown = userdefaults.boolForKey(AP_APP_RATING_SHOWN)
        return shown
    }
    
    //MARK: - Rating the App
    private func displayRatingsPromptIfRequired(){
        let appLaunchCount = getAppLaunchCount()
        if appLaunchCount >= self.requiredLaunchesBeforeRating {
            if #available(iOS 8.0, *) {
                // show App Ratings
                rateTheApp()
            }
            else{
               rateTheAppOldVersion()
            }
        }
        
        incrementAppLaunches()
    }
    
    @available(iOS 8.0, *)
    private func rateTheApp(){
        let app_name = NSBundle(forClass: application.delegate!.dynamicType).infoDictionary!["CFBundleName"] as? String
        let message = "Do you love the \(app_name!) app?  Please rate us!"
        let rateAlert = UIAlertController(title: "Rate Us", message: message, preferredStyle: .Alert)
        let goToItunesAction = UIAlertAction(title: "Rate Us", style: .Default, handler: { (action) -> Void in
            let url = NSURL(string: "itms-apps://itunes.apple.com/app/id\(self.appId)")
            UIApplication.sharedApplication().openURL(url!)
            
            self.setAppRatingShown()
        })
        
        let cancelAction = UIAlertAction(title: "Not Now", style: .Cancel, handler: { (action) -> Void in
           self.resetAppLaunches()
        })
        
        rateAlert.addAction(cancelAction)
        rateAlert.addAction(goToItunesAction)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let window = self.application.windows[0]
            window.rootViewController?.presentViewController(rateAlert, animated: true, completion: nil)
        })
    
    }
    
    private func rateTheAppOldVersion(){
        let app_name = NSBundle(forClass: application.delegate!.dynamicType).infoDictionary!["CFBundleName"] as? String
        let message = "Do you love the \(app_name!) app?  Please rate us!"
        let alert = UIAlertView(title: "Rate Us", message: message, delegate: self, cancelButtonTitle: "Not Now", otherButtonTitles: "Rate Us")
        alert.show()
    }
    
    //MARK: - Alert Views
    public func alertViewCancel(alertView: UIAlertView) {
        // reset app launch count
        self.resetAppLaunches()
    }
    
    public func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        setAppRatingShown()
        
        let url = NSURL(string: "itms-apps://itunes.apple.com/app/id\(self.appId)")
        UIApplication.sharedApplication().openURL(url!)
    }
}