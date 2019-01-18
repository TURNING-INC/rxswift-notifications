//
//  Notifiable + Listeners.swift
//  Notifications
//
//  Created by Leandro Perez on 11/26/18.
//  Copyright © 2018 Leandro perez. All rights reserved.
//

import Foundation
import RxSwift

public extension Notifiable {

    public func addListener(handler: @escaping (ParameterType) -> Void) -> Disposable {
        return self.asObservable().subscribe(onNext: handler)
    }

    public func addListener(handler: @escaping (ParameterType, Notification) -> Void) -> Disposable {
        return self.notificationObservable()
            .subscribe(onNext: { notification in
                guard let parameter = notification.userInfo?[self.identifier] as? ParameterType
                    else {fatalError("The notification must have the right parameter")}
                handler(parameter, notification)
            })
    }

    public func addListener<T:AnyObject>(weak object:T,  handler: @escaping (T, ParameterType) -> Void ) -> Disposable {
        return self.addListener(weak: object, handler: curry(handler))
    }

    public func addListener<T:AnyObject>(weak object:T,  handler: @escaping (T) -> (ParameterType) -> Void ) -> Disposable {
        return self.addListener { [weak object] (parameter) in
            guard let object = object else {return}

            handler(object)(parameter)
        }
    }

    public func addNoParamsListener<T:AnyObject>(weak object:T, _ handler: @escaping (T) -> () -> Void ) -> Disposable {

        return self.addListener { [weak object] (_) in
            guard let object = object else {return}

            handler(object)()
        }
    }
}

//MARK:- private
private func curry<A,B>(_ f:@escaping (A,B) -> Void ) -> (A) -> (B) -> Void {
    return { a in { b in f(a,b) } }
}
