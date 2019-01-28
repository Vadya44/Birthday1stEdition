//  BirthdayList.swift
//  Birthday. (C) Dmitry Alexandrov
//  Business.RF
//
import UIKit
import Foundation
import SystemConfiguration


// It's an Observer with refresh() function
class BirthdayList : UIViewController, RefreshTable, UITableViewDataSource, UITableViewDelegate, NewBirthdayDelegate, EditBirthdayDelegate, ObserverProtocol
{
    func refreshTable() {
        self.tableBirthday.reloadData()
    }
    
    
    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var tableBirthday: UITableView!

    var index : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableBirthday.separatorStyle = .none
        tableBirthday.dataSource = self
        tableBirthday.delegate = self  //реализовать UITableViewDelegate

        birthday.delegate = self
        birthday.refreshDelegate = self
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(BirthdayList.swiped(_:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeUp)

        //сказать таблице, что мы подаем данные
        //необходимо реализовать UITableViewDataSource протокол
        //в заголовке класса
        tableBirthday.dataSource = self
        tableBirthday.delegate = self  //реализовать UITableViewDelegate
        
        //создать pull-to-refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(BirthdayList.refresh(_:)), for: .valueChanged)
        tableBirthday.addSubview(refreshControl)
        birthday.refresh()
        refreshUI()
        
        tableBirthday.reloadData()
        
        reloadBirthday()
        // загрузить из источника
        refresh(nil)
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl?) {
        refreshControl?.endRefreshing()
    }

    func refreshUI() { // conforms to ObserverProtocol
        time.text = birthday.info // label
        time.textColor = birthday.empty ? UIColor.gray : UIColor.white
        self.reloadBirthday()
    }
       
    //прямо перед показом представления (view)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadBirthday()
        // загрузить из источника
        refresh(nil)
    }
        
    func reloadBirthday() {
        self.tableBirthday.reloadData()
    }
    
    @objc func swiped(_ swipe: UISwipeGestureRecognizer){
        switch swipe.direction {
        case UISwipeGestureRecognizerDirection.down:
            birthday.refresh()
            refreshUI()
            return
        default:
            break
        }
    }
    
    // задать число строк в таблице
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let aa = String(birthdayList.count)
//        defaults?.set(aa, forKey: "str")
//        defaults?.synchronize()
        return birthdayList.count
    }
    
    // сконфигурировать ячейку по indexPath(.row, .section)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // достать ячейку из кеша
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "BirthdayCell") as! BirthdayListCell
        // конфигурируем ячейку
        let birthday = birthdayList[indexPath.row]
        let arr = birthday.components(separatedBy: ";")
        cell.name.text = arr.first
        cell.date.text = arr.last
        return cell
    }
    
    // можно ли редактировать ячейки
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // как можно их редактировать
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    // применить редактирование
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // удаление ячейки + удаление из модели
        tableView.beginUpdates()
        
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
        
        birthdayList.remove(at: indexPath.row)
        birthday.saveData()
        //завершить обновление
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        index = indexPath.row // save
        return indexPath
    }
    
    //выбрана ячейка
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // убрать выделение с анимацией
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? UINavigationController
        if let newBirthdayController = controller?.viewControllers.first as? AddBirthday {
            newBirthdayController.delegate = self
        } else if let editBirthdayController = controller?.viewControllers.last as? EditVC {
            editBirthdayController.delegate = self
            editBirthdayController.index = index
        }
    }
    
    // to conform to the protocol NewBirthdayDelegate
    func newBirthday(_ controller: AddBirthday, createdBirthdayOf name: String, date: String) {
        let birthDate = date + ";" + name
        birthdayList.append(birthDate)
        
        // do save into userdefaults !
        birthday.saveData()
        
        
        //попросить таблицу обновить данные
        //вызовется numberOfRows..., cellForRow...
        tableBirthday.reloadData()
        
        //убрать текущий модальный контроллер
        dismiss(animated: true, completion: nil)
    }
    
    func editBirthday(_ controller: EditVC, editedBirthdayOf name: String, date: String) {
        
        let birthDate = date + ";" + name
//        let path = tableBirthday.indexPathForSelectedRow
//        birthdayList[(path?.row)!] = birthDate
        
        birthdayList[index!] = birthDate
        
        // do save into userdefaults !
        birthday.saveData()
        
        //попросить таблицу обновить данные
        //вызовется numberOfRows..., cellForRow...
        tableBirthday.reloadData()
        
        //убрать текущий модальный контроллер
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ViewControllers view ist fully loaded and could present further ViewController
        //Here you could do any other UI operations
        if Reachability.isConnectedToNetwork() == true
        {
            print("Connected")
        }
        else
        {
            let alert = UIAlertController(title: "Warning", message: "The Internet is not available. Data and all other changes are locally.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
        }
        
    }
}
public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        return isReachable && !needsConnection
    }
}

protocol RefreshTable {
    func refreshTable()
}
