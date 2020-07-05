//
//  ContentView.swift
//  PixelPusher
//
//  Created by Lex on 2020/7/3.
//

import SwiftUI
import UIKit


// MARK: - CompareMask

public struct CompareMask: View {
    @State var dragPosition: CGFloat = 0
    @State var opacity: Double = 1
    @State var isHudVisible = false

    public var imageName: String

    public init(imageName: String) {
        self.imageName = imageName
    }

    public var body: some View {
        ZStack {
            Image(imageName)
                .aspectRatio(contentMode: .fit)
                .mask(
                    Rectangle()
                        .offset(x: dragPosition)
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragPosition = min(0, value.translation.width * 1.5)
                        }
                        .onEnded { _ in
                            dragPosition = 0
                        }
                )
                .onTapGesture(count: 2) {
                    Self.dismiss()
                }
                .animation(.easeInOut)
                .background(Color.clear)
                .opacity(opacity)
                .edgesIgnoringSafeArea(.all)
                .frame(alignment: .top)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            VStack {
                Spacer()
                Text("Double tap to dismiss")
                    .font(.headline)
                    .shadow(radius: 2, y: 1)
                    .padding()
                    .foregroundColor(Color.black)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .blur(radius: isHudVisible ? 0 : 5)
                    .opacity(isHudVisible ? 1 : 0)
                    .scaleEffect(isHudVisible ? 1 : 1.5, anchor: .center)
                    .onAppear {
                        withAnimation(.easeInOut) {
                            isHudVisible = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeIn) {
                                isHudVisible = false
                            }
                        }
                    }
                Spacer().frame(maxHeight: 90)
            }
        }
        .background(Color.clear)
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private static weak var viewController: UIViewController?

    public static func show(imageName: String) {
        let swiftUIView = CompareMask(imageName: imageName)
        let vc = UIHostingController(rootView: swiftUIView)

        vc.view.backgroundColor = .clear
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.view.frame = UIScreen.main.bounds
        vc.modalPresentationStyle = .overCurrentContext

        keyWindow()?.rootViewController?.present(vc, animated: true, completion: nil)

        viewController = vc
    }

    public static func dismiss(animated: Bool = true) {
        viewController?.dismiss(animated: animated) {
            NotificationCenter.default.post(name: .CompareMaskDidDisappear, object: nil)
        }
    }
}

// May be replaced with passthrough subject instead?
extension NSNotification.Name {
    static let CompareMaskDidDisappear = NSNotification.Name(rawValue: "CompareMaskDidDisappear")
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Image("screenshot_ios14")
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            CompareMask(imageName: "screenshot_ios13")
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .previewDevice("iPhone 11 Pro Max")
    }
}
#endif

// MARK: - Present in UIWindow

private func keyWindow() -> UIWindow? {
    return UIApplication.shared.connectedScenes
        .first(where: { $0.activationState == .foregroundActive })
        .flatMap({ $0 as? UIWindowScene })?
        .flatMap({ $0.delegate as? UIWindowSceneDelegate })?
        .flatMap({ $0.window as? UIWindow })
        ?? UIApplication.shared.keyWindow
}

extension UIViewController {

    public func showCompareButton(with imageName: String) {
        guard let image = UIImage(named: imageName) else {
            return
        }
        compareButton.setImage(image, for: .normal)
        compareButton.accessibilityLabel = imageName

        let size = image.size
        compareButton.frame.size = CGSize(width: size.width / 8, height: size.height / 8)
        compareButton.center = view.center
        compareButton.frame.origin.x = view.bounds.width - compareButton.bounds.width - 20
    }

    var compareButton: UIButton {
        if let button = view.viewWithTag(kCompareButtonTag) as? UIButton {
            return button
        }
        let button = UIButton(type: .custom)
        button.tag = kCompareButtonTag
        button.imageEdgeInsets = .init(top: 1, left: 1, bottom: 1, right: 1)
        button.backgroundColor = UIColor.white
        button.setTitleColor(.white, for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(showCompareMask), for: .touchUpInside)

        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = .init(width: 2, height: 2)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true

        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragButton))
        button.addGestureRecognizer(dragGesture)

        NotificationCenter.default.addObserver(forName: .CompareMaskDidDisappear, object: nil, queue: nil) { [weak self] _ in
            self?.compareButton.isHidden = false
        }

        return button
    }

    @objc private func showCompareMask() {
        guard let imageName = compareButton.accessibilityLabel else {
            return
        }
        CompareMask.show(imageName: imageName)
        compareButton.isHidden = true
    }

    @objc private func dragButton(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let origin = gesture.translation(in: view)
            compareButton.center = CGPoint(
                x: compareButton.center.x + origin.x,
                y: compareButton.center.y + origin.y
            )
            gesture.setTranslation(.zero, in: view)
        default: ()
        }
    }
}

private let kCompareButtonTag = 1
