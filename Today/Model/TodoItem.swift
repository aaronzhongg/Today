//
//  TodoItem.swift
//  Today
//
//  Created by Aaron Zhong on 11/06/18.
//  Copyright © 2018 Aaron Zhong. All rights reserved.
//

import Foundation
import RealmSwift

class TodoItem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var completed: Bool = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "todoItems")
}
