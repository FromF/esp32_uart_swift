//
//  debug.swift
//  esp32_uart
//
//  Created by 藤　治仁 on 2018/07/01.
//  Copyright © 2018年 Personal. All rights reserved.
//

///デバックモード設定
func debugLog(_ obj: Any?,
              function: String = #function,
              line: Int = #line) {
    #if DEBUG
    if let obj = obj {
        print("[\(function):\(line)] : \(obj)")
    } else {
        print("[\(function):\(line)]")
    }
    #endif
}

func errorLog(_ obj: Any?,
              function: String = #function,
              line: Int = #line) {
    #if DEBUG
    if let obj = obj {
        print("ERROR [\(function):\(line)] : \(obj)")
    } else {
        print("ERROR [\(function):\(line)]")
    }
    #endif
}
