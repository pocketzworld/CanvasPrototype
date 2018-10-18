//
//  WidgetView.swift
//  CanvasPrototype
//
//  Created by Jimmy Xu on 10/18/18.
//  Copyright © 2018 Highrise. All rights reserved.
//

import UIKit

protocol WidgetViewProtocol: NSObjectProtocol {
    func didInteract(sender: WidgetView)
    func didTap(sender: WidgetView)
}

class WidgetView: UIView {
    var lastScale = CGFloat(1.0)
    var lastRotation = CGFloat(0)
    var panGesture: UIPanGestureRecognizer?
    
    var delegate: WidgetViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        let tapGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)

        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(sender:)))
        rotateGesture.delegate = self
        addGestureRecognizer(rotateGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(sender:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        delegate?.didInteract(sender: self)

        let translation = sender.translation(in: self.superview)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.superview)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        delegate?.didTap(sender: self)
    }

    @objc func handleRotate(sender: UIRotationGestureRecognizer) {
        delegate?.didInteract(sender: self)

        let nextRotation = sender.rotation - lastRotation
        transform = transform.rotated(by: nextRotation)
        lastRotation = sender.rotation
    }

    @objc func handlePinch(sender: UIPinchGestureRecognizer) {
        delegate?.didInteract(sender: self)

        let nextScale = 1.0 - (lastScale - sender.scale)
        transform = transform.scaledBy(x: nextScale, y: nextScale)
        lastScale = sender.scale
    }
    
}

extension WidgetView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.view == self && otherGestureRecognizer.view == self
    }
}
