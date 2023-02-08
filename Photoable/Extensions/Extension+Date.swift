//
//  Extension+Date.swift
//  Photoable
//
//  Created by 임채윤 on 2023/02/05.
//

import Foundation

extension Date {
    func dateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일"
        
        return dateFormatter.string(from: self)
    }
    
    func timeFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a h:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        return dateFormatter.string(from: self)
    }
}
