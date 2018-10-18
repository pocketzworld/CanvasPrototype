//
//  CanvasView.swift
//  CanvasPrototype
//
//  Created by Josh Johnson on 10/18/18.
//  Copyright © 2018 Highrise. All rights reserved.
//

import UIKit

enum CanvasBackgroundMode {
    case tiled
    case scaled
    case repeated
}

class CanvasView: UIView {
    
    private var backgroundCanvasMode: CanvasBackgroundMode = .scaled
    private var backgroundImageView: UIImageView?
    var widgetContainerView: UIView?
    
    override var backgroundColor: UIColor? {
        set {
            clearBackgroundImage()
            super.backgroundColor = newValue
        }
        get {
            return super.backgroundColor
        }
    }
    
    func addWidget(_ widget: UIView) {
        if widgetContainerView == nil {
            let container = UIView(frame: bounds)
            addSubview(container)
            container.isMultipleTouchEnabled = true
            container.isUserInteractionEnabled = true
            widgetContainerView = container
            
        }
        
        widgetContainerView?.addSubview(widget)
    }
    
    func applyBackgroundImage(_ image: UIImage, mode: CanvasBackgroundMode = .scaled) {
        if backgroundImageView == nil {
            let imageView = UIImageView()
            
            if let container = widgetContainerView {
                insertSubview(imageView, belowSubview: container)
            } else {
                addSubview(imageView)
            }
            
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: topAnchor),
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
                ])
            
            backgroundImageView = imageView
        }

        // TODO: Handle background modes later
        
        backgroundImageView?.image = image
    }
    
    private func clearBackgroundImage() {
        backgroundImageView?.removeFromSuperview()
        backgroundImageView = nil
    }
    
}
