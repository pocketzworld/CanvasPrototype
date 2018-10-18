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
    var widgetModel: WidgetModel?
    
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)

        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(sender:)))
        rotateGesture.delegate = self
        addGestureRecognizer(rotateGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(sender:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
        
        let deleteGesture = UILongPressGestureRecognizer(target: self, action: #selector(deleteWidget(sender:)))
        deleteGesture.delegate = self
        addGestureRecognizer(deleteGesture)
    }
    
    @objc func deleteWidget(sender: UILongPressGestureRecognizer) {
        removeFromSuperview()
        delegate?.didRemoveWidget()
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
    override var widgetModel: WidgetModel? {
        didSet {
            if let model = widgetModel {
                if let colorString = model.imageBorderColor, let color = UIColor.init(hexString: colorString) {
                    layer.borderColor = color.cgColor
                    layer.borderWidth = 3
                }

                if let name = model.imageName {
                    subviews.forEach { $0.removeFromSuperview() }

                    let iv = UIImageView(image: UIImage(named: name))
                    iv.isUserInteractionEnabled = true
                    iv.contentMode = .scaleAspectFit
                    addSubview(iv)
                    
                    frame = iv.bounds
                }
                
                if let t = widgetModel?.transform {
                    transform = t
                }
                
                if let x = widgetModel?.x, let y = widgetModel?.y {
                    center = CGPoint(x: x, y: y)
                }
            }
        }
    }
  
    override func handleTap(sender: UITapGestureRecognizer) {
        super.handleTap(sender: sender)
        transform = transform.concatenating(CGAffineTransform(scaleX: -1, y: 1))
    }
}

class TextWidgetView : WidgetView {
    override var widgetModel : WidgetModel? {
        didSet {
            if let model = widgetModel {
                var textColor = UIColor.black
                var backgroundColor = UIColor.clear
                
                if let textColorString = model.textColor, let color = UIColor(hexString: textColorString) {
                    textColor = color
                }
                
                if let backgroundColorString = model.textBackgroundColor, let color = UIColor(hexString: backgroundColorString) {
                    backgroundColor = color
                }

                if let text = model.text {
                    subviews.forEach { $0.removeFromSuperview() }

                    let label = UILabel()
                    label.text = text
                    label.adjustsFontSizeToFitWidth = true
                    label.font = UIFont.systemFont(ofSize: 100.0)
                    label.textColor = textColor
                    label.backgroundColor = backgroundColor
                    label.isUserInteractionEnabled = true
                    label.sizeToFit()
                    addSubview(label)

                    frame = CGRect(x: 0.0, y: 0.0, width: label.bounds.width, height: label.bounds.height)
                    label.frame = bounds
                }
                
                if let t = widgetModel?.transform {
                    transform = t
                }
                
                if let x = widgetModel?.x, let y = widgetModel?.y {
                    center = CGPoint(x: x, y: y)
                }
            }
        }
    }
  
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
      if let color = widgetModel?.textBackgroundColor {
        return UIColor.init(hexString: color)!
      } else {
        return UIColor.clear
      }
    }
  }
}
