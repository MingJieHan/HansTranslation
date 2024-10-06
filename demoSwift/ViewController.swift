//
//  ViewController.swift
//  demoSwift
//
//  Created by jia yu on 2024/10/1.
//

import UIKit
import HansTranslation
import SwiftUI
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 18.0, *) {
            var languages:Array = HansTranslation.existLanguageIdentfiers()
            print ("System installed languages:", languages)
            
            languages = HansTranslation.availableLanguageIdentifiers()
            print ("Available but install needed.", languages)
            
//            let transfer = HansTranslation.init(sourceLanguage: "en-CN", withTargetLanguage: "ja")    //trans to 日文
            let transfer = HansTranslation.init(sourceLanguage: "en-CN", withTargetLanguage: "zh-Hans-CN") // 翻译为中文
            
            let word = "Hello World!"
            let word1 = "Hello Hans!"
            transfer.translate([word, word1], withRootVC: self) {translater, results, error in
                if (nil != error){
                    print (error!.localizedDescription)
                    return
                }
                let resArray:Array = results!
                let res:NSMutableString = NSMutableString()
                for a in resArray{
                    res.append(a)
                    res.append("\n")
                }
                let alert = UIAlertController(title: res as String, message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }
}

