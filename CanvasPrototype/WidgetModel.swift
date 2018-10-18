//
//  WidgetModel.swift
//  CanvasPrototype
//
//  Created by Matt Kennedy on 10/18/18.
//  Copyright © 2018 Highrise. All rights reserved.
//

import Foundation

struct WidgetModel: Codable {
  var x: Double
  var y: Double
  var width: Double
  var height: Double
  var type: String // "sticker", "text"
  
  // text properties
  var textBackgroundColor: String?
  var textColor: String?
  var text: String?
  
  var imageBorderColor: String?
  var imageName: String?
}
