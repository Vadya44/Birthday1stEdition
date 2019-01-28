//  EditVC.swift
//  Birthday. (C) Dmitry Alexandrov
//  Business.RF
//
import UIKit

class EditVC: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var dateText: UITextField!

    var index: Int?
    weak var delegate: EditBirthdayDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameText.delegate = self
        dateText.delegate = self
        
        if let ind = index {
            let birthDate = birthdayList[ind]
            let arr = birthDate.components(separatedBy: ";")
            dateText.text = arr[0]
            nameText.text = arr[1]
        }
        
/*
        //добавляем распознаватель, чтобы убирать клавиатуру по нажатию
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(AddBirthday.tapView(_:)))
        self.view.addGestureRecognizer(recognizer)
        self.view.isUserInteractionEnabled = true
 */
    }

/*
    @objc func tapView(_ recognizer: UITapGestureRecognizer) {
        //если жест закончен (палец оторвали от экрана)
        if recognizer.state == UIGestureRecognizerState.ended {
            //закрываем клавиатуру, убирая фокус
            nameText.resignFirstResponder()
            dateText.resignFirstResponder()
        }
    }
*/
    
    @IBAction func cancelChanges(_ sender: UIBarButtonItem) {
        //presentingViewController тот, кто нас показывает
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveChanges(_ sender: UIBarButtonItem) {
        let name = nameText.text
        let date = dateText.text

        if name!.count == 0 {
            nameText.backgroundColor = UIColor.red
        } else {
            nameText.backgroundColor = UIColor.darkGray
        }
        
        if date!.count != 10 {
            dateText.backgroundColor = UIColor.red
        } else {
            dateText.backgroundColor = UIColor.darkGray
        }

        if date!.count == 10 && name!.count > 0 {
            let fullDate = "\(date!) 06:00:00"
            let dateFormatter = DateFormatter()
            let timeZoneLocal = NSTimeZone.local
            let dateTimeFormat = "dd.MM.yyyy HH:mm:ss"
            dateFormatter.timeZone = timeZoneLocal
            dateFormatter.dateFormat = dateTimeFormat
            
            let td = dateFormatter.date(from: fullDate)
            if td != nil{
            
                delegate?.editBirthday(self, editedBirthdayOf: name!, date: date!)
            } else {
                dateText.backgroundColor = UIColor.red
            }
        }
        birthday.saveData()
    }
    
    //вызывается на ввод каждого символа
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        nameText.backgroundColor = UIColor.darkGray
        dateText.backgroundColor = UIColor.darkGray
        return true
    }
    
    // Для сокрытия клавиатуры после нажатия на фоне (вне текстового поля ввода)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //в этот момент пользователь нажал на Enter (Next)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // отдать фокус, опустить клавиатуру в случае textField
        nameText.resignFirstResponder() // ?
        //получить фокус
        //dateText.becomeFirstResponder()
        dateText.resignFirstResponder() // ?
        return false
    }
}

// способ передачи информации обратно
protocol EditBirthdayDelegate: NSObjectProtocol {
    //"событие"
    func editBirthday(_ controller: EditVC, editedBirthdayOf name: String, date: String)
}




