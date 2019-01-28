//  TodayBirthdayList.swift
//  BirthdayLogic
//  Birthday. (C) Dmitry Alexandrov
//  Business.RF
import UIKit
import NotificationCenter
//import UserNotifications

//let logic = SharedLogic()
//let logic = SharedLogic.instance
//let birthday = SharedLogic.logic
//var birthday = BirthdayLogic()
//var notification = LocalNotification()

let instance = SharedLogic()

//var timer = Timer()
//var goesAnimation = true

class TodayBirthdayList: UIViewController, ObserverProtocol, NCWidgetProviding
//, UNUserNotificationCenterDelegate
{
    
    func refreshUI() {
        birthday.refreshLogic()
        info.text = birthday.info // label
        info.textColor = birthday.empty ? UIColor.gray : UIColor.white
    }
    
    func infoDidChange() {
        refreshUI()
    }

    let keyLogic = \SharedLogic.logic
    var birthday = instance.logic

    @IBOutlet weak var info: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        birthday.delegateW = self
        refreshUI()
    }

    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        refreshUI()
        completionHandler(NCUpdateResult.newData)
    }

}
