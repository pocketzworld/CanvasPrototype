import UIKit

protocol WidgetViewProtocol: NSObjectProtocol {
    func didInteract(sender: WidgetView)
    func didTap(sender: WidgetView)
    func didRemoveWidget()
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
  
class StickerWidgetView : WidgetView {
  var widgetModel: StickerWidgetModel?
  
  var borderColor: UIColor {
    get {
      if let color = widgetModel?.borderColor {
        return UIColor.init(hexString: color)!
      } else {
        return UIColor.clear
      }
    }
  }
}

class TextWidgetView : WidgetView {
  var widgetModel : TextWidgetModel?
  
  var text: String? {
    didSet {
      widgetModel?.text = text
      if text?.isEmpty ?? false {
        delegate?.didRemoveWidget()
      }
    }
  }
  
  var textColor: UIColor {
    get {
      if let color = widgetModel?.textColor {
        return UIColor.init(hexString: color)!
      } else {
        return UIColor.white
      }
    }
  }
  
  var textBackgroundColor: UIColor {
    get {
      if let color = widgetModel?.backgroundColor {
        return UIColor.init(hexString: color)!
      } else {
        return UIColor.clear
      }
    }
  }
}

// base model for serializing view attributes
class WidgetModel {
  var x: Int
  var y: Int
  var width: Int
  var height: Int
  var type: String?
  
  init(x: Int, y: Int, width: Int, height: Int) {
    self.x = x
    self.y = y
    self.width = width
    self.height = height
  }
}

// sticker widget model
class StickerWidgetModel : WidgetModel {
  var borderColor: String?
  
  override init(x: Int, y: Int, width: Int, height: Int) {
    super.init(x: x, y: y, width: width, height: height)
    self.type = "sticker"
  }
}

// text widget model
class TextWidgetModel : WidgetModel {
  var backgroundColor: String?
  var textColor: String?
  var text: String?

  override init(x: Int, y: Int, width: Int, height: Int) {
    super.init(x: x, y: y, width: width, height: height)
    self.type = "text"
  }
}
