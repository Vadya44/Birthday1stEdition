//  SharedLogic.swift
//  Birthday. (C) Dmitry Alexandrov
//  Business.RF
import Foundation
struct SharedLogic //: NSObject
{
    static var instance: SharedLogic {
        struct Singleton {
            static let instance = SharedLogic()
        }
        return Singleton.instance
    }

    
    let logic = BirthdayLogic()

    
//    let logic : BirthdayLogic
//
//    override init() {
//        logic = BirthdayLogic()
//        super.init()
//    }
}
