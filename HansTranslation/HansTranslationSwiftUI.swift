//
//  HansTranslationSwift.swift
//  HansTranslation
//
//  Created by MingJie Han on 2024/9/22.
//

import Foundation
import SwiftUI
import Translation

@available(iOS 18.0, macOS 15.0, *)
struct MainViewInterface:View{
    public var headerText:String = ""
    public var translateText:String  = "Translate"
    public var translatingText:String = "Translating ..."
    public var footerText:String = ""
    
    public var sourceArray:Array = ["Hans Translation"]
    public var resultArray:NSMutableArray = NSMutableArray()
    
    public var progressNotificationName:String = ""
    public var completedNotificationName:String = ""
    public var sourceLanguageIdentifier:String = ""
    public var targetLanguageIdentifier:String = ""
    
    @State var bindHeaderText = ""
    @State var bindTranslateText = ""
    @State private var sourceText = ""
    @State private var targetText = ""
    @State private var configuration: TranslationSession.Configuration?
    @State var bandTranslatingText = ""
    
    @State private var currentLine = ""  //正在翻译的文字
    @State private var value:Float = 0
    @State private var progressString:String = ""
    @State private var boardWidth:CGFloat = 2.2
    @State private var translating = false
    var body:some View{
        VStack {
            if (!translating){
                Text(bindHeaderText)
                    .foregroundColor(.black)    //文字颜色
                    .frame(height: 100)     //Text 高度
                //                .padding(10)            //Text 内部文字左右锁进像素数
                    .padding(EdgeInsets(top: 50, leading: 5, bottom: 0, trailing: 0))   //指定内部锁进的像素数
//                    .background(.blue.opacity(0.8), in: Rectangle())        //背景颜色
            }
            if (translating){   //翻译中显示的内容
                Spacer()        //竖向空间，自动延展
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.gray))
                    .frame(width:40, height:40)
                Text(currentLine)
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
                HStack{
                    Slider(value: $value, in: 0...100)
                        .frame(width: 200)
                        .background(.clear)
                        .disabled(true)
                    Text(progressString)
                }
                Text(bandTranslatingText)
                    .multilineTextAlignment(.center)
//                    .background(.blue.opacity(0.8), in: Rectangle())
            }
            Button(action: triggerTranslation, label: {
                Text(bindTranslateText)
                .frame(width: 200, height:60)
                .font(.system(size: 14))
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                .background(.clear)
                    .border(.blue, width:boardWidth)
                    .cornerRadius(6)
            })
            .translationTask(configuration) { session in
                let progressName:NSNotification.Name = NSNotification.Name(rawValue: progressNotificationName)
                NotificationCenter.default.post(name: progressName, object: nil, userInfo: nil)
                translating = true
                boardWidth = 0;
                bindTranslateText = ""
                await translateAction(session: session)
                return
            }
            .disabled(translating)
            
            Spacer()        //竖向空间，自动延展
            Text(footerText)
                .bold()
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .frame(height:50)
        }
        .onAppear(){
            viewappeared()
            
            //action translate after appear, No need button click
            triggerTranslation()
        }
        .background(.clear)
    }
    
    func viewappeared(){
        bindHeaderText = headerText
        bindTranslateText = translateText
        bandTranslatingText = translatingText
    }
    
    func translateAction(session:TranslationSession) async{
        var err:Error? = nil
        do {
            var index = 0;
            while (index < sourceArray.count){
                let aLine = sourceArray[index]
                value = 100 * Float(index)/Float(sourceArray.count)
                currentLine = aLine
                progressString = String(Int(value)) + "%"   //取整数后，再转换为字符串，可控制取得的字符串长度
                let response = try await session.translate(aLine)
                resultArray.add(response.targetText)
                index += 1
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

