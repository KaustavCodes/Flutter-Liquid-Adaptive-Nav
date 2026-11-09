import Flutter
import UIKit

public class LiquidAdaptiveNavPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let factory = LiquidGlassViewFactory(messenger: registrar.messenger())
    registrar.register(
      factory,
      withId: LiquidGlassViewFactory.viewTypeId
    )
  }
}

final class LiquidGlassViewFactory: NSObject, FlutterPlatformViewFactory {
  static let viewTypeId = "com.kauscoder.liquid_adaptive_nav/liquid_glass_capsule"
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return LiquidGlassPlatformView(
      frame: frame,
      viewIdentifier: viewId,
      arguments: args,
      messenger: messenger
    )
  }
}

private final class PassthroughGlassContainerView: UIView {
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    return nil
  }

  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    return false
  }
}

private final class LiquidGlassPlatformView: NSObject, FlutterPlatformView {
  private let containerView: PassthroughGlassContainerView
  private let effectView: UIVisualEffectView
  private let tintOverlayView: UIView
  private let channel: FlutterMethodChannel

  private var isDark: Bool
  private var cornerRadius: CGFloat
  private var isCapsule: Bool
  private var tintColor: UIColor?

  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    let params = args as? [String: Any]
    self.isDark = params?["isDark"] as? Bool ?? false
    self.cornerRadius = CGFloat(params?["cornerRadius"] as? Double ?? 32.0)
    self.isCapsule = params?["isCapsule"] as? Bool ?? true
    self.tintColor = LiquidGlassPlatformView.colorFromArgb(params?["tintColor"])

    let safeFrame = frame.isEmpty ? CGRect(x: 0, y: 0, width: 54, height: 64) : frame
    let container = PassthroughGlassContainerView(frame: safeFrame)
    container.backgroundColor = .clear
    container.isOpaque = false
    container.clipsToBounds = false
    container.isUserInteractionEnabled = false

    let effect = UIVisualEffectView(frame: container.bounds)
    effect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    effect.isUserInteractionEnabled = false
    effect.backgroundColor = .clear
    effect.isOpaque = false

    let overlay = UIView(frame: effect.contentView.bounds)
    overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    overlay.isUserInteractionEnabled = false
    overlay.backgroundColor = .clear
    overlay.isHidden = true
    effect.contentView.addSubview(overlay)

    container.addSubview(effect)

    self.containerView = container
    self.effectView = effect
    self.tintOverlayView = overlay
    self.channel = FlutterMethodChannel(
      name: "\(LiquidGlassViewFactory.viewTypeId)_\(viewId)",
      binaryMessenger: messenger
    )

    super.init()

    applyAppearance()

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(nil)
        return
      }
      if call.method == "updateStyle", let updateArgs = call.arguments as? [String: Any] {
        if let dark = updateArgs["isDark"] as? Bool {
          self.isDark = dark
        }
        if let radius = updateArgs["cornerRadius"] as? Double {
          self.cornerRadius = CGFloat(radius)
        }
        if let capsule = updateArgs["isCapsule"] as? Bool {
          self.isCapsule = capsule
        }
        if updateArgs.keys.contains("tintColor") {
          self.tintColor = LiquidGlassPlatformView.colorFromArgb(updateArgs["tintColor"])
        }
        self.applyAppearance()
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  deinit {
    channel.setMethodCallHandler(nil)
  }

  func view() -> UIView {
    return containerView
  }

  private static func colorFromArgb(_ value: Any?) -> UIColor? {
    guard let number = value as? NSNumber else { return nil }
    let argb = number.uint64Value
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }

  private func applyAppearance() {
    let style: UIUserInterfaceStyle = isDark ? .dark : .light
    containerView.overrideUserInterfaceStyle = style
    effectView.overrideUserInterfaceStyle = style

    #if compiler(>=6.2)
    if #available(iOS 26.0, *) {
      let glassEffect = UIGlassEffect(style: .regular)
      glassEffect.isInteractive = false
      glassEffect.tintColor = tintColor
      effectView.effect = glassEffect
      effectView.clipsToBounds = false
      effectView.cornerConfiguration = isCapsule
        ? .capsule(maximumRadius: cornerRadius > 0 ? cornerRadius : nil)
        : .uniformCorners(radius: .fixed(max(0.0, cornerRadius)))
      tintOverlayView.isHidden = true
      return
    }
    #endif

    effectView.effect = UIBlurEffect(
      style: isDark ? .systemChromeMaterialDark : .systemChromeMaterialLight
    )
    effectView.clipsToBounds = true
    effectView.layer.cornerRadius = max(0.0, cornerRadius)
    effectView.layer.cornerCurve = .continuous

    if let tint = tintColor {
      tintOverlayView.backgroundColor = tint
      tintOverlayView.isHidden = false
    } else {
      tintOverlayView.backgroundColor = .clear
      tintOverlayView.isHidden = true
    }
  }
}
