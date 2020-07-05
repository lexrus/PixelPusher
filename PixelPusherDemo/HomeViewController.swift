//
//  HomeViewController.swift
//  PixelPusher
//
//  Created by Lex on 2020/7/3.
//

import UIKit
import SwiftUI
import PixelPusher


class HomeViewController: UIViewController {

    private let imageView = UIImageView(image: UIImage(named: "screenshot_ios14"))

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Original native content"

        view.backgroundColor = .black
        view.addSubview(imageView)

        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showCompareButton(with: "screenshot_ios13")
    }

    override func viewDidLayoutSubviews() {
        imageView.frame = view.bounds
    }
}
