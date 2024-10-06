//
//  HansTranslationSwift.swift
//  HansTranslation
//
//  Created by MingJie Han on 2024/9/22.
//

import Foundation
import SwiftUI
import Translation

@available(iOS 18.0, *)
struct MainViewInterface:View{
    public var headerText:String = ""
    public var translateText:String  = "Translate"
    public var footerText:String = ""
    
    public var sourceArray:Array = ["Hans Translation"]
    public var resultArray:NSMutableArray = NSMutableArray()
    
    public var completedNotificationName:String = ""
    public var sourceLanguageIdentifier:String = ""
    public var targetLanguageIdentifier:String = ""
    
    @State private var sourceText = ""
    @State private var targetText = ""
    @State private var configuration: TranslationSession.Configuration?
    
    var body:some View{
        VStack {
            Text(headerText)
            Button(translateText){
                triggerTranslation()
            }
            .translationTask(configuration) { session in
                await translateAction(session: session)
                return
            }
            Text(footerText)
        }
    }

    func translateAction(session:TranslationSession) async{
        var err:Error? = nil
        do {
            for aLine in sourceArray{
                let response = try await session.translate(aLine)
                resultArray.add(response.targetText)
            }
        } catch {
            err = error
            print (error.localizedDescription)
        }

        // Sent notification.
        let name:NSNotification.Name = NSNotification.Name(rawValue: completedNotificationName)
        if (nil != err){
            NotificationCenter.default.post(name: name, object: err, userInfo: nil)
        }else{
            NotificationCenter.default.post(name: name, object: resultArray, userInfo: nil)
        }
    }
    
    private func triggerTranslation() {
        guard configuration == nil else {
            configuration?.invalidate()
            print ("invalidate")
            return
        }
        configuration = .init()
        configuration?.source = Locale.Language(identifier: sourceLanguageIdentifier)
        configuration?.target = Locale.Language(identifier: targetLanguageIdentifier)
    }
}

