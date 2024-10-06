//
//  BridgingClass.swift
//  HansTranslation
//
//  Created by MingJie Han on 2024/9/22.
//

import Foundation
import SwiftUI
import Translation

@available(iOS 18.0, macOS 15.0, *)
@objc public class BridgingClass:NSObject{
    @objc public var headerText:String = ""
    @objc public var buttonText:String = ""
    @objc public var footerText:String = ""
    
    @objc public var sourceArray:Array = ["Hans Translation"]
    @objc public var completedNotificationName:String = ""
    @objc public var sourceLanguageIdentifier:String = ""
    @objc public var targetLanguageIdentifier:String = ""
#if os(iOS)
    @objc public func makeTranslateViewController() -> UIViewController{
        let vc =  UIHostingController(rootView:MainViewInterface())
        vc.hidesBottomBarWhenPushed = true
        vc.rootView.headerText = headerText
        vc.rootView.translateText = buttonText
        vc.rootView.footerText = footerText
        
        vc.rootView.sourceArray = sourceArray
        vc.rootView.completedNotificationName = completedNotificationName
        vc.rootView.sourceLanguageIdentifier = sourceLanguageIdentifier
        vc.rootView.targetLanguageIdentifier = targetLanguageIdentifier
        return vc
    }
#elseif os(macOS)
    @objc public func makeTranslateViewController() -> NSViewController{
        let vc = NSHostingController(rootView: MainViewInterface())
        vc.rootView.headerText = headerText
        vc.rootView.translateText = buttonText
        vc.rootView.footerText = footerText
        
        vc.rootView.sourceArray = sourceArray
        vc.rootView.completedNotificationName = completedNotificationName
        vc.rootView.sourceLanguageIdentifier = sourceLanguageIdentifier
        vc.rootView.targetLanguageIdentifier = targetLanguageIdentifier
        return vc
    }
#endif

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
