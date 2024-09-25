//
//  BridgingClass.swift
//  HTranslation
//
//  Created by jia yu on 2024/9/22.
//

import Foundation
import SwiftUI
import Translation

@available(iOS 18.0, *)
@objc public class BridgingClass:NSObject{
    var myVC:MainViewInterface?
    
    @objc public func makeMainView() -> UIViewController{
        let vc = UIHostingController(rootView: MainViewInterface())
        vc.hidesBottomBarWhenPushed = true
        //rootView is MainViewInterface
        myVC = vc.rootView
        //UIHostingController is UIViewController
        return vc
    }

    func translationIsSupported(from source: Locale.Language, to target: Locale.Language) async -> Bool {
        let availability = LanguageAvailability()
        let status = await availability.status(from: source, to: target)
        switch status {
        case .installed, .supported:
                return true
        case .unsupported:
                return false
        default:
            return false
        }
    }
}
