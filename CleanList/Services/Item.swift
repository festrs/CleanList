//
//  Item.swift
//  CleanList
//
//  Created by Felipe Dias Pereira on 2019-05-12.
//  Copyright © 2019 FelipeP. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var price = 0.0
    let quanity = RealmOptional<Int>()

    override static func primaryKey() -> String? {
        return "id"
    }
}
