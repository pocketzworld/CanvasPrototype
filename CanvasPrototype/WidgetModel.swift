//
//  WidgetModel.swift
//  CanvasPrototype
//
//  Created by Matt Kennedy on 10/18/18.
//  Copyright © 2018 Highrise. All rights reserved.
//

import Foundation
import UIKit

struct WidgetModel: Codable {
  var x: CGFloat
  var y: CGFloat
  var width: CGFloat
  var height: CGFloat
  var type: String // "sticker", "text"
  
  // text properties
  var textBackgroundColor: String?
  var textColor: String?
  var text: String?
  
  var imageBorderColor: String?
  var imageName: String?
}
