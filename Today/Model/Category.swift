//
//  Category.swift
//  Today
//
//  Created by Aaron Zhong on 11/06/18.
//  Copyright © 2018 Aaron Zhong. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let todoItems = List<TodoItem>()
}
