//
//  CanvasModel.swift
//  CanvasPrototype
//
//  Created by Matt Kennedy on 10/18/18.
//  Copyright © 2018 Highrise. All rights reserved.
//

import Foundation

struct CanvasModel: Codable {
    var backgroundColor: String?
    var widgets: [WidgetModel]?
}
