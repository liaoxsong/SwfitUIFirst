//
//  PageControl.swift
//  SwiftUIFirst
//
//  Created by Song Liao on 7/9/20.
//  Copyright © 2020 Personal. All rights reserved.
//

import Foundation
import SwiftUI

struct PrintView<Content: View>: View {
    var text: String
    var content: Content

    var body: some View {
        print(text)
        return content
    }
}

extension View {
    func debug(_ text: String) -> some View {
        PrintView(text: text, content: self)
    }
}

//https://stackoverflow.com/questions/58388071/how-to-implement-pageview-in-swiftui
struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.pageIndicatorTintColor = UIColor.lightGray
        control.currentPageIndicatorTintColor = UIColor.darkGray
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged)

        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage

    }

    class Coordinator: NSObject {
        var control: PageControl

        init(_ control: PageControl) {
            self.control = control
        }
        @objc
        func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
}

struct PageView<Page: View>: View {
    var viewControllers: [UIHostingController<Page>]
    @Binding var currentPage: Int
//    @State var currentPage: Int = 0


    init(currentPage: Binding<Int>, _ views: [Page]) {
        self._currentPage = currentPage
        self.viewControllers = views.map {
            let u = UIHostingController(rootView: $0)
            u.view.backgroundColor = .clear
            return u
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            PageViewController(controllers: viewControllers, currentPage: $currentPage)
                .debug("current page is \(currentPage)")
            PageControl(numberOfPages: viewControllers.count, currentPage: $currentPage)
        }
    }
}

struct PageViewController: UIViewControllerRepresentable {

    var controllers: [UIViewController]

    @Binding var currentPage: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        pageViewController.view.backgroundColor = .clear

        return pageViewController
    }

    @State var lastPage: Int = 0
    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        let animated = lastPage != currentPage
        let direction: UIPageViewController.NavigationDirection = currentPage > lastPage ? .forward : .reverse
        pageViewController.setViewControllers(
        [controllers[currentPage]], direction: direction, animated: animated) { _ in
            DispatchQueue.main.async {
                self.lastPage = self.currentPage
            }
        }

    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewController

        init(_ pageViewController: PageViewController) {
            self.parent = pageViewController
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index == 0 {
                return parent.controllers.last
            }
            return parent.controllers[index - 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index + 1 == parent.controllers.count {
                return parent.controllers.first
            }
            return parent.controllers[index + 1]
        }

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed,
                let visibleViewController = pageViewController.viewControllers?.first,
                let index = parent.controllers.firstIndex(of: visibleViewController) {
                parent.currentPage = index
            }
        }
    }
}
