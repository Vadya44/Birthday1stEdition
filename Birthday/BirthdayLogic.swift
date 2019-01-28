//  BirthdayLogic.swift
//  Birthday. (C) Dmitry Alexandrov
//  Business.RF
//
import Foundation
import Firebase
import UIKit
import CoreData

// It's a Provider, it has a delegate that is equal Observer (BirthdayList)

var birthdayList = [String]()
//    private static let birthdayList = [
//        "31.10.1949;The Dad's Birthday",
//        "25.10.0000;Daniela's Birthday",
//        ]

class BirthdayLogic: NSObject
{
    var empty: Bool = true
    //    var info: String = ""
    @objc dynamic var info: String = "" /// new
    
    
    var delegate: ObserverProtocol?
    var delegateW: ObserverProtocol?
    
    var refreshDelegate : RefreshTable?
    
    
    
    private static let dateFormatter = DateFormatter()
    private static let timeZoneLocal = NSTimeZone.local
    private static let dateTimeFormat = "dd.MM.yyyy HH:mm:ss"
    
    func refresh() {
        
        getData()
        logic()
        self.delegate?.refreshUI()
        self.delegateW?.refreshUI()
    }
    
    // сохранить данные в UserDefaults
    func saveData() {
        
        let ref = Database.database().reference(withPath: "data")
        
        let eventItemRef = ref.child("event")
        eventItemRef.setValue(birthdayList)
        
        deleteAllData()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        for next in birthdayList {
            let entity = NSEntityDescription.entity(forEntityName: "Event", in: context)
            let newEvent = NSManagedObject(entity: entity!, insertInto: context)
            newEvent.setValue(next, forKey: "eventString")
        }
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
        refresh()
    }
    
    func deleteAllData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Delete all data in UserData error : \(error) \(error.userInfo)")
        }
    }
    
    
    override init() {
        super.init()
        getData()
        logic()
    }
    
    // получить данные из UserDefaults
    private func getData() {
        
        
        let ref = Database.database().reference(withPath: "data")
        
        ref.queryOrdered(byChild: "event").observe(.value, with: { snapshot in
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    if let value = snapshot.value as? [String] {
                        if value.count != 0 {
                            birthdayList = value
                            self.refreshDelegate?.refreshTable()
                            return
                        }
                    }
                }
            }
            
        })
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let context = appDelegate.persistentContainer.viewContext


        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        request.returnsObjectsAsFaults = false
        var eventsArray = [String]()
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                let title = data.value(forKey: "eventString") as! String
                eventsArray.append(title)
            }
        } catch {

            print("Failed")
        }
        birthdayList = eventsArray
    
        refreshDelegate?.refreshTable()
    }
    
    
    func refreshLogic() {
        self.getData()
        self.logic()
    }
    
    // логика
    private func logic() {
        self.empty = true
        self.info = ""
        var resS = ""
        BirthdayLogic.dateFormatter.timeZone = BirthdayLogic.timeZoneLocal
        BirthdayLogic.dateFormatter.dateFormat = BirthdayLogic.dateTimeFormat
        let currentD = setTime(to: NSDate() as Date)
        
        // for test
        //        let currentDS = "22.10.2017 06:00:00" // the day before yesterday
        //        let currentDS = "23.10.2017 06:00:00" // yesterday
        //        let currentDS = "24.10.2017 06:00:00" // today
        //        let currentDS = "25.10.2017 06:00:00" // tomorrow
        //        let currentDS = "26.10.2017 06:00:00" // in 1 day
        //        let currentDS = "27.10.2017 06:00:00" // in 2 days
        //        let currentDS = "28.10.2017 06:00:00" // in 3 days
        //        let currentDS = "29.10.2017 06:00:00" // in 4 days
        //        let currentDS = "30.10.2017 06:00:00" // in 5 days
        //        let currentDS = "31.10.2017 06:00:00" // in 6 days
        //        let currentDS = "01.11.2017 06:00:00" // in a week
        //        let currentDS = "29.02.2020 06:00:00" // високосный год
        //        currentD = setTime(to: BirthdayLogic.dateFormatter.date(from: currentDS)!)
        
        let todayS = BirthdayLogic.dateFormatter.string(from: currentD as Date)
        
        let thisYear = getYearFromDate(from: todayS)
        let todayWoY = getDateWithoutYear(from : todayS)
        
        // поиск в массиве
        for birthDate in birthdayList {
            let birthDateNameA = birthDate.components(separatedBy: ";")
            let birthD = birthDateNameA.first!
            let birthN = birthDateNameA.last!
            
            var birthWoY = getDateWithoutYear(from : birthD)
            //let birthY = getYearFromDate(from : birthD)
            
            let day = Int(birthWoY.components(separatedBy: ".")[0])
            let month = Int(birthWoY.components(separatedBy: ".")[1])
            if ((day == 29) && (month == 02)) {
                do { try checkForLeapYear(dateWoY: birthWoY, year : thisYear) } catch { birthWoY = "01.03" }
            }
            
            let birthThisYearS = "\(birthWoY).\(thisYear) 06:00:00"
            
            let birthThisYearD = BirthdayLogic.dateFormatter.date(from: birthThisYearS)
            
            if isBirthdayDuringWeek(today: currentD as Date, birthday: birthThisYearD!) { // в течение недели
                
                let diff = datesDiff(pastDate: currentD as Date, nowDate: birthThisYearD!)
                
                if (diff.diffD == 0) { // today
                    self.empty = false
                    resS = "\(resS) \(birthN) \(diff.diffText)!"
                }
                else { resS = "\(resS) \(birthN) \(diff.diffText), on \(getDateWithoutYear(from : birthThisYearS))." }
            }
        }
        if self.empty { resS = " No birthday for now yet...\(resS)" }
        self.info = "Today is \(todayWoY).\(resS)"
        
        
        // test ok!!!!
        //notification.addNotif(withText: self.info)
        
    }
    
    // вычисление разницы между двумя датами в днях
    private func datesDiff(pastDate: Date, nowDate: Date) -> (diffD : Int, diffText : String) {
        let interval = Int(nowDate.timeIntervalSince(pastDate))
        let diffD = interval / (24 * 60 * 60)
        var diffText = ""
        switch diffD {
        case 0 : diffText = "TODAY"
        case 1 : diffText = "tomorrow"
        case 2 : diffText = "in 1 day"
        case 8 : diffText = "in a week"
        default:
            let days = diffD - 1
            diffText = "in \(days) days"
        }
        return (diffD, diffText)
    }
    
    // одна дата раньше или равна другой
    //    private func isBeforeBirthday(today: Date, birthday: Date) -> Bool {
    //        return Int(birthday.timeIntervalSince(today)) >= 0 ? true : false
    //    }
    
    // день рождения в течение недели
    private func isBirthdayDuringWeek(today: Date, birthday: Date) -> Bool {
        let timeInterval = Int(birthday.timeIntervalSince(today))
        if (timeInterval >= 0) {
            let diff = datesDiff(pastDate: today as Date, nowDate: birthday)
            if diff.diffD <= 8 { return true }
        }
        return false
    }
    
    // убрать год из даты
    private func getDateWithoutYear(from : String) -> String {
        let arr = from.components(separatedBy: ".")
        return "\(arr[0]).\(arr[1])"
    }
    
    // вернуть год из даты
    private func getYearFromDate(from : String) -> String {
        let arr = from.components(separatedBy: ".")
        let year = arr[2].components(separatedBy: " ").first!
        return "\(year)"
    }
    
    // убрать год из даты
    private func setTime(to : Date) -> Date {
        BirthdayLogic.dateFormatter.timeZone = BirthdayLogic.timeZoneLocal
        BirthdayLogic.dateFormatter.dateFormat = BirthdayLogic.dateTimeFormat
        
        let toS = BirthdayLogic.dateFormatter.string(from: to as Date).components(separatedBy: " ").first!
        
        let dateWithTimeS = toS + " 06.00.00"
        let dateWithTimeD = BirthdayLogic.dateFormatter.date(from: dateWithTimeS)!
        
        return dateWithTimeD
    }
    
    // проверка существования 29.02 в текущем году
    private func checkForLeapYear(dateWoY : String, year : String) throws {
        let newD = "\(dateWoY).\(year) 06.00.00"
        let res = BirthdayLogic.dateFormatter.date(from: newD)
        if res == nil {
            let err = NSError()
            throw err
        }
    }
}

protocol ObserverProtocol: class {
    func refreshUI()
}

