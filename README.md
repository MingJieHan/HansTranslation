# HansTranslation
Call Translation of SwiftUI from Object-C into framework in Xcode.

存在的待解决问题：
在iOS 17.6设备上，调试程序时，报Translation_SwiftUI.framework 异常错误
即在低于iOS18的设备上，未找到运行程序的方法。

Apple Translation 提供了SwiftUI调用的例子，如 https://developer.apple.com/documentation/translation/translating-text-within-your-app

这个程序用Object-C调用Swift， 由Swift转调用 SwiftUI结构。 翻译文字结果通过Notification方式传送回Object-C程序监听。

未支持iOS macOS两个平台，在此framework中，涉及到不同编程语言下的预编译宏定义。


