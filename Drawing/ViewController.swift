//
//  ViewController.swift
//  Drawing
//
//  Created by MickyMikeH on 2024/1/26.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupButtons()
    }
    
    func setupUI() {
        view.backgroundColor = .darkGray
    }
    
    func setupButtons() {
        // 創建三個按鈕
        let button1 = UIButton(type: .system)
        button1.setTitle("文字", for: .normal)
        button1.addTarget(self, action: #selector(textHandler(_:)), for: .touchUpInside)
        
        let button2 = UIButton(type: .system)
        button2.setTitle("矩形", for: .normal)
        button2.addTarget(self, action: #selector(squareHandler(_:)), for: .touchUpInside)
        
        let button3 = UIButton(type: .system)
        button3.setTitle("圓形", for: .normal)
        button3.addTarget(self, action: #selector(circleHandler(_:)), for: .touchUpInside)
        
        let screenShotButton = UIButton(type: .system)
        screenShotButton.setTitle("ScreenShot", for: .normal)
        screenShotButton.addTarget(self, action: #selector(screenShotHandler(_:)), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [button1, button2, button3, screenShotButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 8
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc func textHandler(_ sender: UIButton) {
        let textView = ResizableTextView(titleColor: .white)
        view.addSubview(textView)
        textView.adjustPositionIfNeeded()
    }
    
    @objc func squareHandler(_ sender: UIButton) {
        let squre = ResizableSqure(layerColor: .white)
        view.addSubview(squre)
        squre.adjustPositionIfNeeded()
    }
    
    @objc func circleHandler(_ sender: UIButton) {
        let circle = ResizableCircleView(layerColor: .white)
        view.addSubview(circle)
        circle.adjustPositionIfNeeded()
    }
    
    @objc func screenShotHandler(_ sender: UIButton) {
        if let image = MNSreenShotUtility.takeScreenShot(view: self.view) {
            let demo = ScreenShotDemoViewController()
            demo.image = image
            present(demo, animated: true)
        }
        else {
            // 截圖失敗
            print("Failed to take screenshot.")
        }
    }
}

class ResizableCircleView: ResizableSqure {
    private var circleView: UIView!

    override var isEditing: Bool {
        get {
            return super.isEditing
        }
        set {
            super.isEditing = newValue
            topLeftHandle.isHidden = true
            bottomRightHandle.isHidden = true
            bottomLeftHandle.isHidden = !newValue
            borderLayer.isHidden = !newValue
        }
    }
    
    override func setupDefaultValue() {
        super.setupDefaultValue()
        
        borderLayer.borderColor = UIColor.gray.cgColor
        topLeftHandle.isHidden = true
        bottomRightHandle.isHidden = true
        
        /// 圓形
        let circleDiameter = min(bounds.width, bounds.height)  // 取最小值，確保圓形能夠放得下
        circleView = UIView(frame: CGRect(x: (bounds.width - circleDiameter) / 2.0,
                                          y: (bounds.height - circleDiameter) / 2.0,
                                          width: circleDiameter,
                                          height: circleDiameter))
        circleView.layer.cornerRadius = circleDiameter / 2.0
        circleView.layer.masksToBounds = true
        circleView.layer.borderWidth = 1
        circleView.layer.borderColor = layerColor?.cgColor
        addSubview(circleView)
    }
    
    override func handleResize(_ gestureRecognizer: UIPanGestureRecognizer, xMultiplier: CGFloat, yMultiplier: CGFloat) {
        
        let translation = gestureRecognizer.translation(in: self)
        // 只允許往左下和右上
        guard translation.x <= 0 && translation.y >= 0 ||
                translation.x >= 0 && translation.y <= 0 else {
            return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)  // 關閉動畫

        // 左下
        if translation.x < 0 && translation.y > 0 {
            bounds = CGRect(x: bounds.origin.x + xMultiplier * translation.x,
                            y: bounds.origin.y + translation.y,
                            width: bounds.width + xMultiplier * translation.x,
                            height: bounds.width)
            
        }
        // 右上
        else if translation.x > 0 && translation.y < 0 {
            bounds = CGRect(x: bounds.origin.x + translation.x,
                            y: bounds.origin.y + translation.y,
                            width: bounds.width + -1 * translation.x,
                            height: bounds.width)
        }
        
        borderLayer.frame = bounds
        
        // 計算新的圓形大小和位置
        let newRadius = min(bounds.width, bounds.height) / 2.0
        circleView.frame.size = CGSize(width: newRadius * 2, height: newRadius * 2)
        circleView.layer.cornerRadius = newRadius

        // 調整圓形的中心點
        let centerX = bounds.origin.x + bounds.width / 2.0
        let centerY = bounds.origin.y + bounds.height / 2.0
        circleView.center = CGPoint(x: centerX, y: centerY)

        // 更新其他元素的位置
        borderLayer.frame = bounds
        bottomLeftHandle.center = CGPoint(x: bounds.origin.x, y: bounds.origin.y + bounds.height)
        deleteButton.center = CGPoint(x: bounds.origin.x + bounds.width, y: bounds.origin.y)
        CATransaction.commit()

        gestureRecognizer.setTranslation(CGPoint.zero, in: self)
    }
}

class ResizableSqure: UIView {
    var deleteButton: UIButton!
    var topLeftHandle: UIView!
    var bottomLeftHandle: UIView!
    var bottomRightHandle: UIView!
    var borderLayer = CALayer()
    
    var isEditing: Bool = false {
        didSet {
            topLeftHandle.isHidden = !isEditing
            bottomLeftHandle.isHidden = !isEditing
            bottomRightHandle.isHidden = !isEditing
            deleteButton.isHidden = !isEditing
        }
    }
    var layerColor: UIColor?
    
    convenience init(layerColor: UIColor) {
        let initialFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
        var centerPoint = UIApplication.shared.keyWindow?.center ?? CGPoint.zero
        self.init(frame: initialFrame)
        center = centerPoint
        
        self.layerColor = layerColor
        setupDefaultValue()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHandles()
        setupDeleteButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDefaultValue()
        setupHandles()
        setupDeleteButton()
    }
    
    func setupDefaultValue() {
        clipsToBounds = false
        borderLayer.frame = bounds
        borderLayer.borderColor = layerColor?.cgColor
        borderLayer.borderWidth = 1.0
        layer.insertSublayer(borderLayer, at: 0)
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleMove(_:))))
        isEditing = true
    }
    
    private func setupHandles() {
        let handleSize: CGFloat = 10

        // Calculate the center point of the handles based on the bounds
        let handleCenterX = bounds.origin.x + bounds.width / 2
        let handleCenterY = bounds.origin.y + bounds.height / 2

        // Top left handle
        topLeftHandle = createHandlerView(frame: CGRect(x: handleCenterX - handleSize / 2,
                                                        y: handleCenterY - handleSize / 2,
                                                        width: handleSize,
                                                        height: handleSize),
                                          center: CGPoint(x: bounds.origin.x,
                                                          y: bounds.origin.y))
        addSubview(topLeftHandle)

        // Bottom left handle
        bottomLeftHandle = createHandlerView(frame: CGRect(x: handleCenterX - handleSize / 2,
                                                           y: handleCenterY + bounds.height / 2 - handleSize / 2,
                                                           width: handleSize,
                                                           height: handleSize),
                                             center: CGPoint(x: bounds.origin.x,
                                                             y: bounds.origin.y + bounds.height))
        addSubview(bottomLeftHandle)

        // Bottom right handle
        bottomRightHandle = createHandlerView(frame: CGRect(x: handleCenterX + bounds.width / 2 - handleSize / 2,
                                                            y: handleCenterY + bounds.height / 2 - handleSize / 2,
                                                            width: handleSize,
                                                            height: handleSize),
                                              center: CGPoint(x: bounds.origin.x + bounds.width,
                                                              y: bounds.origin.y + bounds.height))
        addSubview(bottomRightHandle)

        // Pan gesture for handles
        topLeftHandle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
        bottomLeftHandle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
        bottomRightHandle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
    }
    
    private func createHandlerView(frame: CGRect, center: CGPoint) -> UIView {
        let backgroundColor = UIColor(red: 12/255, green: 139/255, blue: 207/255, alpha: 1)
        let borderColor = UIColor.white
        
        let view = UIView(frame: frame)
        view.backgroundColor = backgroundColor
        view.layer.cornerRadius = frame.width / 2
        view.layer.borderColor = borderColor.cgColor
        view.layer.borderWidth = 1
        view.center = center
        
        return view
    }

    private func setupDeleteButton() {
        let buttonSize: CGFloat = 20

        // Assuming handleSize is the size of your handles
        let handleCenterX = bounds.origin.x + bounds.width / 2
        let handleCenterY = bounds.origin.y + bounds.height / 2

        // Delete button in the top right corner of the bounds
        deleteButton = UIButton(frame: CGRect(x: handleCenterX + bounds.width / 2 - buttonSize / 2,
                                              y: handleCenterY - buttonSize / 2,
                                              width: buttonSize,
                                              height: buttonSize))
        deleteButton.center = CGPoint(x: bounds.origin.x + bounds.width,
                                      y: bounds.origin.y)
        deleteButton.setImage(UIImage(named: "close_full_20_dark_n"), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        addSubview(deleteButton)
    }

    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let handleView = gestureRecognizer.view else { return }

        switch gestureRecognizer.state {
        case .began, .changed:
            if handleView == topLeftHandle {
                handleResize(gestureRecognizer, xMultiplier: -1, yMultiplier: -1)
            }
            else if handleView == bottomRightHandle {
                handleResize(gestureRecognizer, xMultiplier: 1, yMultiplier: 1)
            }
            else if handleView == bottomLeftHandle {
                handleResize(gestureRecognizer, xMultiplier: -1, yMultiplier: 1)
            }
        default:
            break
        }
    }

    // 移動整個 ResizableSqure 的邏輯
    @objc private func handleMove(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        gestureRecognizer.setTranslation(CGPoint.zero, in: self)
    }

    // 縮放邏輯
    func handleResize(_ gestureRecognizer: UIPanGestureRecognizer, xMultiplier: CGFloat, yMultiplier: CGFloat) {
        
        let translation = gestureRecognizer.translation(in: self)

        CATransaction.begin()
        CATransaction.setDisableActions(true)  // 關閉動畫

        bounds = CGRect(x: bounds.origin.x + xMultiplier * translation.x,
                        y: bounds.origin.y + yMultiplier * translation.y,
                        width: bounds.width + xMultiplier * translation.x,
                        height: bounds.height + yMultiplier * translation.y)
        borderLayer.frame = bounds
        
        topLeftHandle.center = CGPoint(x: bounds.origin.x, y: bounds.origin.y)
        bottomLeftHandle.center = CGPoint(x: bounds.origin.x, y: bounds.origin.y + bounds.height)
        bottomRightHandle.center = CGPoint(x: bounds.origin.x + bounds.width, y: bounds.origin.y + bounds.height)
        
        deleteButton.center = CGPoint(x: bounds.origin.x + bounds.width,
                                      y: bounds.origin.y)
        CATransaction.commit()

        gestureRecognizer.setTranslation(CGPoint.zero, in: self)
    }

    @objc private func deleteButtonTapped() {
        removeFromSuperview()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 檢查觸摸點是否在各個 handleView 上
        if bounds.contains(self.convert(point, from: self)) {
            isEditing = true
            return super.hitTest(point, with: event)
        }
        else {
            if topLeftHandle.bounds.contains(topLeftHandle.convert(point, from: self)) {
                return topLeftHandle
            }
            else if bottomLeftHandle.bounds.contains(bottomLeftHandle.convert(point, from: self)) {
                return bottomLeftHandle
            }
            else if bottomRightHandle.bounds.contains(bottomRightHandle.convert(point, from: self)) {
                return bottomRightHandle
            }
            else if deleteButton.bounds.contains(deleteButton.convert(point, from: self)) {
                return deleteButton
            }
            else {
                isEditing = false
            }
            
            return super.hitTest(point, with: event)
        }
    }
}

class ResizableTextView: UITextView, UITextViewDelegate {
    private var borderLayer = CALayer()
    private var deleteButton: UIButton!
    var titleColor: UIColor?
    
    var isEditing: Bool = false {
        didSet {
            borderLayer.isHidden = !isEditing
            deleteButton.isHidden = !isEditing
        }
    }
    
    lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "文字"
        placeholderLabel.font = .systemFont(ofSize: 15)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, 
                                                y: (bounds.height - placeholderLabel.frame.height) / 2)
        return placeholderLabel
    }()
    
    convenience init(titleColor: UIColor) {
        let initialFrame = CGRect(x: 0, y: 0, width: 120, height: 34)
        var centerPoint = UIApplication.shared.keyWindow?.center ?? CGPoint.zero
        self.init(frame: initialFrame)
        center = centerPoint
        self.titleColor = titleColor
        setupDefaultValue()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupDeleteButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDefaultValue()
        setupDeleteButton()
    }
    
    func setupDefaultValue() {
        /// placholder
        addSubview(self.placeholderLabel)
        
        textContainer.lineBreakMode = .byCharWrapping
        textContainer.maximumNumberOfLines = 3

        delegate = self
        isUserInteractionEnabled = true
        isEditable = true
        isSelectable = true
        keyboardType = .default
        clipsToBounds = false
        keyboardDismissMode = .onDrag
        isScrollEnabled = false
        font = .systemFont(ofSize: 15)
        backgroundColor = .clear
        textColor = titleColor
        
        borderLayer = CALayer()
        borderLayer.frame = bounds
        borderLayer.borderWidth = 1.0
        borderLayer.borderColor = UIColor.gray.cgColor
        borderLayer.cornerRadius = 1.0
        layer.insertSublayer(borderLayer, at: 0)
    
        isEditing = true
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleMove(_:))))
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = textView.text.isEmpty ? false : true
        guard let font = textView.font else { return }
        // 計算實際行數
        let numberOfLines = Int(textView.contentSize.height / font.lineHeight)
        
        // 計算新的框架大小，但不允許比預設寬度還小
        let newSize = calculateNewSize(for: textView, numberOfLines: numberOfLines, minWidth: textView.bounds.width)
        
        // 設置新的框架大小
        textView.frame.size = newSize
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        borderLayer.frame = textView.bounds
        CATransaction.commit()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let font = textView.font else { return false }
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        var textWidth = CGRectGetWidth(textView.frame.inset(by: textView.textContainerInset))
        textWidth -= 2.0 * textView.textContainer.lineFragmentPadding;

        let boundingRect = sizeOfString(string: newText, constrainedToWidth: Double(textWidth), font: textView.font!)
        let numberOfLines = boundingRect.height / font.lineHeight;
        /// 計算不超過最大行數
        return numberOfLines <= CGFloat(textView.textContainer.maximumNumberOfLines);
    }
    /// 計算總行數的大小
    func sizeOfString (string: String, constrainedToWidth width: Double, font: UIFont) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                 attributes: [NSAttributedString.Key.font: font],
                                                 context: nil).size
    }
    
    func calculateNewSize(for textView: UITextView, numberOfLines: Int, minWidth: CGFloat) -> CGSize {
        // 計算新的高度
        var newSize = textView.sizeThatFits(CGSize(width: minWidth, height: CGFloat.greatestFiniteMagnitude))
        
        // 如果超過最大行數，則限制高度
        let maximumLines = textView.textContainer.maximumNumberOfLines
        if numberOfLines > maximumLines {
            newSize.height = textView.font?.lineHeight ?? 0.0 * CGFloat(maximumLines)
        }
        
        // 確保新寬度不小於預設寬度
        newSize.width = max(newSize.width, minWidth)

        return newSize
    }
    
    private func setupDeleteButton() {
        let buttonSize: CGFloat = 20

        // Assuming handleSize is the size of your handles
        let handleCenterX = bounds.origin.x + bounds.width / 2
        let handleCenterY = bounds.origin.y + bounds.height / 2

        // Delete button in the top right corner of the bounds
        deleteButton = UIButton(frame: CGRect(x: handleCenterX + bounds.width / 2 - buttonSize / 2,
                                              y: handleCenterY - buttonSize / 2,
                                              width: buttonSize,
                                              height: buttonSize))
        deleteButton.center = CGPoint(x: bounds.origin.x + bounds.width,
                                      y: bounds.origin.y)
        deleteButton.setImage(UIImage(named: "close_full_20_dark_n"), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        addSubview(deleteButton)
    }
    
    // 移動整個 ResizableTextView 的邏輯
    @objc private func handleMove(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        gestureRecognizer.setTranslation(CGPoint.zero, in: self)
    }

    @objc private func deleteButtonTapped() {
        removeFromSuperview()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if bounds.contains(self.convert(point, from: self)) {
            isEditing = true
            endEditing(false)
            return super.hitTest(point, with: event)
        }
        else {
            // 計算觸摸點相對於 deleteButton 的位置
            let touchPointInDeleteButton = deleteButton.convert(point, from: self)
            
            // 檢查觸摸點是否在 deleteButton 上
            if deleteButton.bounds.contains(touchPointInDeleteButton) {
                return deleteButton
            }
            isEditing = false
            endEditing(true)
            // 如果觸摸點不在 deleteButton 上，則執行默認的 hitTest 行為
            return super.hitTest(point, with: event)
        }
    }
    
}

extension UIView {
    func adjustPositionIfNeeded() {
        guard let superview = superview else { return }

        var newPosition = superview.center
        var overlaps = false

        // 找到最後一個不同於當前視圖的 subview
        let subviewsCount = superview.subviews.count
        let index = subviewsCount > 2 ? subviewsCount - 2 : 0
        let lastSubview = superview.subviews[index]

        // 檢查是否有重疊
        if superview.subviews.first(where: { $0 != self && frame.intersects($0.frame) }) != nil {
            overlaps = true
        }

        // 如果有重疊，將自己放在最後一個 subview 的右下
        if overlaps {
            newPosition.x = lastSubview.center.x + lastSubview.bounds.width / 2
            newPosition.y = lastSubview.center.y + lastSubview.bounds.height / 2
            // 如果超過畫面，重置到畫面正中心
            if lastSubview.frame.maxX >= superview.frame.maxX {
                center = superview.center
            }
            else {
                center = newPosition
            }
        }
    }
}
