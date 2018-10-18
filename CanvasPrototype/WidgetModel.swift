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
  
    var textBackgroundColor: String?
    var textColor: String?
    var text: String?
  
    var imageBorderColor: String?
    var imageName: String?
  
    var transform: CGAffineTransform?
    
    static func imageWidgetModel(imageName: String, borderColor: String?) -> WidgetModel {
        return WidgetModel(x: 0.0, y: 0.0, width: 0.0, height: 0.0, type: "image", textBackgroundColor: nil, textColor: nil, text: nil, imageBorderColor: borderColor, imageName: imageName, transform: CGAffineTransform.identity)
    }
    
    static func textWidgetModel(text: String) -> WidgetModel {
        return WidgetModel(x: 0.0, y: 0.0, width: 0.0, height: 0.0, type: "text", textBackgroundColor: nil, textColor: nil, text: text, imageBorderColor: nil, imageName: nil, transform: CGAffineTransform.identity)
    }
}
