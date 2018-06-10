//
//  TodoItem.swift
//  Today
//
//  Created by Aaron Zhong on 9/06/18.
//  Copyright © 2018 Aaron Zhong. All rights reserved.
//

import Foundation

class TodoItem: Encodable, Decodable {
    var title: String = ""
    var completed: Bool = false
    
    convenience init(newItemTitle: String) {
        self.init()
        self.title = newItemTitle
    }
    
//    convenience init(newItemTitle: String, completed: Bool) {
//        self.init()
//        self.title = newItemTitle
//        self.completed = completed
//    }
}
