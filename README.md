# HansTranslation
Call Translation of SwiftUI from Object-C into framework in Xcode.


Apple Translation 提供了SwiftUI调用的例子，如 https://developer.apple.com/documentation/translation/translating-text-within-your-app

这个程序用Object-C调用Swift， 由Swift转调用 SwiftUI结构。 翻译文字结果通过Notification方式传送回Object-C程序监听。

未支持iOS macOS两个平台，在此framework中，涉及到不同编程语言下的预编译宏定义。


