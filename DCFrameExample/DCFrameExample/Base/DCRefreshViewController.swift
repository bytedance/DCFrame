//
//  DCRefreshViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/28.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class DCRefreshViewController: DCViewController, DCRefreshControlProtocol, DCTableViewDelegate {

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

    private var refreshCM: DCRefreshContainerModel?
    private var originalInsets: UIEdgeInsets?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dcTableView.dc_delegate = self
        originalInsets = dcTableView.contentInset
    }
    
    override func loadCM(_ cm: DCContainerModel) {
        super.loadCM(cm)
        if let cm = cm as? DCRefreshContainerModel {
            refreshCM = cm
            refreshCM?.refreshHandler = self
            refreshCM?.refreshSubmodelHandler()
        }
    }
    
    open func loadMore() {
        isLoading = true
        refreshCM?.loadMore()
    }
    
    open func refresh() {
        isRefreshing = true
        refreshCM?.refresh()
    }
    
    func dc_scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let originalInsets = self.originalInsets else {
            return
        }
        let distance = (scrollView.contentOffset.y + scrollView.bounds.height) - scrollView.contentSize.height
        
        if distance > 0 && isLoadMoreOpen && !isLoading {
            if activityIndicator.superview == nil {
                scrollView.addSubview(activityIndicator)
            }
            activityIndicator.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.contentSize.height + 25)
            
            if distance > 50 {
                activityIndicator.startAnimating()
                dcTableView.contentInset.bottom = originalInsets.bottom + 50
                loadMore()
            }
        }
        
        let upDistance = scrollView.contentOffset.y + originalInsets.top
        
        if upDistance < 0 && isRereshOpen && !isRefreshing {
            if activityIndicator.superview == nil {
                scrollView.addSubview(activityIndicator)
            }
            activityIndicator.center = CGPoint(x: scrollView.bounds.midX, y: -25)
            if upDistance < -50 {
                activityIndicator.startAnimating()
                dcTableView.contentInset.top = originalInsets.top + 50
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
    }
    
    final public func endRefresh() {
        if !isRefreshing {
            return
        }
        isRefreshing = false
        
        dcTableView.setContentOffset(CGPoint(x: 0, y: -navbarHeight()), animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if let insets = self.originalInsets {
                self.dcTableView.contentInset = insets
            }
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    final public func endLoadMore() {
        if !isLoading {
            return
        }
        isLoading = false
        activityIndicator.removeFromSuperview()
        if let insets = self.originalInsets {
            self.dcTableView.contentInset = insets
        }
    }
    
    final public func beginRefreshing() {
        //
    }
    
    final public func endWithNoMoreData() {
        //
    }
}
