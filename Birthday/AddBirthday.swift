//  AddBirthday.swift
//  Birthday. (C) Dmitry Alexandrov
//  Business.RF
//
import UIKit


class AddBirthday: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var dateText: UITextField!
    
    weak var delegate: NewBirthdayDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameText.delegate = self
        dateText.delegate = self
/*
        //добавляем распознаватель, чтобы убирать клавиатуру по нажатию
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(AddBirthday.tapView(_:)))
        self.view.addGestureRecognizer(recognizer)
        self.view.isUserInteractionEnabled = true
*/
    }
    
/*
    @objc func tapView(_ recognizer: UITapGestureRecognizer) {
        // если жест закончен (палец оторвали от экрана)
        if recognizer.state == UIGestureRecognizerState.ended {
            // закрываем клавиатуру, убирая фокус
            nameText.resignFirstResponder()
            dateText.resignFirstResponder()
        }
    }
*/
    
    @IBAction func cancelChanges(_ sender: UIBarButtonItem) {
        // presentingViewController тот, кто нас показывает
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
                delegate?.newBirthday(self, createdBirthdayOf: name!, date: date!)
                
            } else {
                dateText.backgroundColor = UIColor.red
            }
        }
        birthday.saveData()
    }

    // вызывается на ввод каждого символа
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


/*
    @IBAction func textFieldEditing(sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
    
        datePickerView.datePickerMode = UIDatePickerMode.date
    
        sender.inputView = datePickerView
    
        datePickerView.addTarget(self, action: #selector(AddBirthday.datePickerValueChanged), for: UIControlEvents.valueChanged)
    }

    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "dd.MM.yyyy"
        //dateFormatter.timeStyle = DateFormatter.Style.none
        print(sender.date)
        print(dateText.text)
        dateText.text = dateFormatter.string(from: sender.date)
    }
*/
    
}

// способ передачи информации обратно
protocol NewBirthdayDelegate: NSObjectProtocol {
    //"событие"
    func newBirthday(_ controller: AddBirthday, createdBirthdayOf name: String, date: String)
}



