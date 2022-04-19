//
//  DCRefreshViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/28.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class DCRefreshViewController: DCCollectionController, DCRefreshControlProtocol, DCCollectionDelegate {

    public private(set) var isLoadMoreOpen = true
    public private(set) var isRereshOpen = true

    public private(set) var isRefreshing = false
    public private(set) var isLoading = false
    public private(set) var hasMoreData = true

    private weak var scrollView: UIScrollView?

    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        return view
    }()

    private var refreshContainerModel: DCRefreshContainerModel?
    private var originalInsets: UIEdgeInsets?

    override func viewDidLoad() {
        super.viewDidLoad()
        dcCollectionView.dcDelegate = self
        originalInsets = dcCollectionView.contentInset
        setLoadMore(true)
    }

    override func loadContainerModel(_ containerModel: DCContainerModel) {
        super.loadContainerModel(containerModel)
        if let containerModel = containerModel as? DCRefreshContainerModel {
            refreshContainerModel = containerModel
            refreshContainerModel?.refreshHandler = self
            refreshContainerModel?.refreshSubmodelHandler()
        }
    }

    open func loadMore() {
        isLoading = true
        refreshContainerModel?.loadMore()
    }

    open func refresh() {
        isRefreshing = true
        refreshContainerModel?.refresh()
    }

    func dcScrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let originalInsets = self.originalInsets else {
            return
        }
        let distance = (scrollView.contentOffset.y + scrollView.bounds.height) - scrollView.contentSize.height

        if distance > 0 && isLoadMoreOpen && !isLoading {
            if activityIndicator.superview == nil {
                scrollView.addSubview(activityIndicator)
            }

            activityIndicator.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.contentSize.height + 25)
            activityIndicator.startAnimating()

            loadMore()
        }

        let upDistance = scrollView.contentOffset.y + originalInsets.top

        if upDistance < 0 && isRereshOpen && !isRefreshing {
            if activityIndicator.superview == nil {
                scrollView.addSubview(activityIndicator)
            }
            activityIndicator.center = CGPoint(x: scrollView.bounds.midX, y: -25)
            if upDistance < -50 {
                activityIndicator.startAnimating()
                dcCollectionView.contentInset.top = originalInsets.top + 50
                refresh()
            }
        }
    }

    final public func setRefresh(_ isOpen: Bool) {
        isRefreshing = false
        isRereshOpen = isOpen
    }

    final public func setLoadMore(_ isOpen: Bool) {
        isLoadMoreOpen = isOpen
        isLoading = false
        hasMoreData = true

        if let originalInsets = self.originalInsets {
            dcCollectionView.contentInset.bottom = originalInsets.bottom + (isOpen ? 50 : 0)
        }
    }

    final public func endRefresh() {
        if !isRefreshing {
            return
        }
        isRefreshing = false

        dcCollectionView.setContentOffset(CGPoint(x: 0, y: -navbarHeight()), animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if let insets = self.originalInsets {
                self.dcCollectionView.contentInset = insets
            }
            self.activityIndicator.removeFromSuperview()
        }
    }

    final public func endLoadMore(_ state: DCEndLoadMoreState) {
        if !isLoading {
            return
        }
        isLoading = false
        activityIndicator.removeFromSuperview()
    }

    final public func beginRefreshing() {
        //
    }
}
