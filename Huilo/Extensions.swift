//
//  Extensions.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 14.12.2022.
//

import UIKit
import Kingfisher
import FirebaseStorage
import Lottie
import AVFoundation

extension UITableViewCell {
    static var identifier: String {
        "\(self)"
    }
}

extension UICollectionReusableView {
    static var identifier: String {
        "\(self)"
    }
}


extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { self.addSubview($0) }
    }
    
    func addTapGesture(target: Any?, action: Selector?) {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: target, action: action)
        
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    func roundOnlyTopCorners(radius: CGFloat = 20) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}

extension UIStackView {
    func addArranged(subviews:[UIView]) {
        subviews.forEach { self.addArrangedSubview($0) }
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") { cString.removeFirst() }

        if (cString.count) != 6 {
            self.init(hex: "ffffff")
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension UIFont {
    static func futura(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "Futura", size: size)!
    }
}

struct Layout {
    /// 20
    static let leading: CGFloat = 20
}


extension UIColor {
    /// FF4364
    static let scarlet = UIColor(hex: "#FF4364")
    /// 30BA8F
    static let grass = UIColor(hex: "#30BA8F")
    /// #5b5b5b
    static let commonGrey = UIColor(hex: "#5b5b5b")
    /// 370258
    static let violet = UIColor(hex: "#370258")
    /// #920CE5
    static let violetLight = UIColor(hex: "#920CE5")
}

extension String {
    func textToImage() -> UIImage? {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: 1024) // you can change your font size here
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
        UIColor.clear.set() // clear background
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize)) // set rect size
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect
        let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
        UIGraphicsEndImageContext() //  end image context

        return image ?? nil
    }
}

class VerticalStackView: UIStackView {
    init(distribution: UIStackView.Distribution = .fill, spacing: CGFloat, alignment: UIStackView.Alignment = .fill) {
        super.init(frame: .zero)
        axis = .vertical
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HorizontalStackView: UIStackView {
    init(distribution: UIStackView.Distribution = .fill, spacing: CGFloat, alignment: UIStackView.Alignment = .fill) {
        super.init(frame: .zero)
        axis = .horizontal
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class InsetTextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}


class ScarletButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? .scarlet : .grass
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .selected)
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        backgroundColor = .scarlet
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class GradientView: UIView {
    
    var startColor:   UIColor = .black { didSet { updateColors() }}
    var endColor:     UIColor = .white { didSet { updateColors() }}
    var startLocation: Double =   0.05 { didSet { updateLocations() }}
    var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    var diagonalMode:    Bool =  false { didSet { updatePoints() }}
    
    override class var layerClass: AnyClass { return CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }
    
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors    = [startColor.cgColor, endColor.cgColor]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}

extension UIViewController {
    func shortVibrate() {
        AudioServicesPlaySystemSound(1519)
    }
}

class GradientVC: UIViewController {
    let iconConfig = UIImage.SymbolConfiguration(scale: .large)
    let gradientContentView = GradientView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(gradientContentView)
        gradientContentView.startLocation = 0
        gradientContentView.endLocation = 0.2
        
        gradientContentView.startColor = .violet
        gradientContentView.endColor = .black
        gradientContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupNavigationBar(with title: String) {
        navigationItem.title = title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
}


extension UIViewController {
    func setupTapRecognizer(for view: UIView, action: Selector?) {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: action)

        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(singleTapGestureRecognizer)
    }
}

extension UIViewController
{
    func startAvoidingKeyboard()
    {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(_onKeyboardFrameWillChangeNotificationReceived(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    func stopAvoidingKeyboard()
    {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillChangeFrameNotification,
                                                  object: nil)
    }

    @objc private func _onKeyboardFrameWillChangeNotificationReceived(_ notification: Notification)
    {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)

        let animationDuration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        self.additionalSafeAreaInsets.bottom = intersection.height

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve)
        {
            self.view.layoutIfNeeded()
        }
    }
}


class ActivityView: UIView {
    private let animationView = AnimationView()
    private let timerLabel = UILabel()
    private var estimatedTime: Int = 20
    private var countdownTimer: Timer?
    
    init(animation: Animation?, frame: CGRect, withoutAppearAnimation: Bool) {
        super.init(frame: frame)
        addSubview(animationView)
        addSubview(timerLabel)
        
        timerLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(90)
            $0.leading.equalToSuperview().offset(Layout.leading)
            $0.trailing.equalToSuperview().offset(-Layout.leading)
        }
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        timerLabel.font = .futura(withSize: 30)
        timerLabel.numberOfLines = 0
        timerLabel.text = "estimated time \(estimatedTime) sec"
        
        animationView.animation = animation
        backgroundColor = .black
        animationView.frame = self.frame
        animationView.center = center
        let window = UIApplication.shared.keyWindow ?? UIWindow()
//        let c = window.center
        self.center.y += window.center.y
        self.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
        let duration: Double = withoutAppearAnimation ? 0 : 1
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
            self.center.y -= window.center.y
            self.transform = .identity
        }
    }
    
    func play(isInitial: Bool = false) {
        if isInitial {
            countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.updateLabel()
            }
            
            countdownTimer?.fire()
        }
        animationView.play { [weak self] isComplete in
            self?.play()
        }
    }
    
    func stopTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    private func updateLabel() {
        estimatedTime -= 1
        if estimatedTime > 0 {
            timerLabel.text = "estimated time \(estimatedTime) sec"
        } else {
            timerLabel.text = "we need a little bit more time..."
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Animations {
        static let plane = Animation.named("plane")
    }
    
    deinit {
        stopTimer()
    }
}

extension UIViewController {
    var window: UIWindow { UIApplication.shared.keyWindow ?? UIWindow() }
    
    func showActivity(animation: Animation?, withoutAppearAnimation: Bool = false) {
        let activityView = ActivityView(animation: animation, frame: window.bounds, withoutAppearAnimation: withoutAppearAnimation)
        activityView.play(isInitial: true)
        window.addSubview(activityView)
    }
    
    func removeActivity(withoutAnimation: Bool = false, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let activity = self.window.subviews.first { $0 is ActivityView }
            let duration: TimeInterval = withoutAnimation ? 0 : 1
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
                activity?.center.y += activity?.center.y ?? 0
                activity?.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
            } completion: { _ in
                activity?.removeFromSuperview()
                completion?()
            }
        }
    }
}
