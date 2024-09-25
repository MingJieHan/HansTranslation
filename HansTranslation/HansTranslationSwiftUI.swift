//
//  HansTranslationSwift.swift
//  HansTranslation
//
//  Created by jia yu on 2024/9/22.
//

import Foundation
import SwiftUI
import Translation

@available(iOS 18.0, *)
struct MainViewInterface:View{
    @State private var sourceText = "Default user name and password."
    @State private var targetText = ""
    @State private var configuration: TranslationSession.Configuration?
    
    var body:some View{
        VStack {
//            let filename = String.init(format: "%@%@", NSHomeDirectory(), sourceLanguageFileName)
//            let sourceIdentifier = try String.init(contentsOfFile: filename, encoding: .utf8)
//            Text(sourceIdentifier)
            Text("Press translate begin.")
            Text("Enter text to translate")
            Button("Translate"){
                triggerTranslation()
            }
            .translationTask(configuration) { session in
                Task { @MainActor in
                    var err:Error? = nil
                    let resultArray:NSMutableArray = NSMutableArray()
                    do {
                        let filename = String.init(format: "%@%@", NSHomeDirectory(), sourceFileName)
                        let array:NSArray = NSArray(contentsOfFile: filename)!
                        
                        for a in array{
                            sourceText = a as! String
//                            print (sourceText)
                            let response = try await session.translate(sourceText)
                            resultArray.add(response.targetText)
                        }
                    } catch {
                        err = error
                        print (error.localizedDescription)
                    }
                    
                    // Write translate result.
                    let resultname = String.init(format: "%@%@", NSHomeDirectory(), resultFileName)
                    if (resultArray.count > 0){
                        resultArray .write(toFile: resultname, atomically: true)
                    }else{
                        //TODO remove result file.
                    }
                    
                    // Sent notification.
                    let name:NSNotification.Name = NSNotification.Name(rawValue: completedNotificationName)
                    if (nil != err){
                        NotificationCenter.default.post(name: name, object: err, userInfo: nil)
                    }else{
                        NotificationCenter.default.post(name: name, object: session, userInfo: nil)
                    }
                }
                return
            }
        }
    }

    private func triggerTranslation() {
        guard configuration == nil else {
            configuration?.invalidate()
            print ("invalidate")
            return
        }
        configuration = .init()
        do {
            let filename = String.init(format: "%@%@", NSHomeDirectory(), sourceLanguageFileName)
            let sourceIdentifier = try String.init(contentsOfFile: filename, encoding: .utf8)
            configuration?.source = Locale.Language(identifier: sourceIdentifier)        //en
            print ("source language init with:" + sourceIdentifier)
        }catch{
            print ("Warning source language NOT init!")
        }
        do {
            let filename = String.init(format: "%@%@", NSHomeDirectory(), targetLanguageFileName)
            let targetIdentifier = try String.init(contentsOfFile: filename, encoding: .utf8)
            configuration?.target = Locale.Language(identifier: targetIdentifier)    //zh, ja, "zh-Hans-CN"
            print ("traget language init with:" + targetIdentifier)
        }catch{
            print ("Warning traget language NOT init!")
        }
    }
}

