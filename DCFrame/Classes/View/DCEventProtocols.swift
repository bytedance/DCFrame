//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

public protocol DCBaseOperationProtocol: NSObjectProtocol {
    func needReloadData()
    func needReloadData(indexPath: IndexPath?)
    func needReloadDataAtOnce()
    func needAnimateUpdate()
    func needAnimateUpdate(with animation: UITableView.RowAnimation)
    func needAnimateUpdate(completion: @escaping () -> Void)
    func needAnimateUpdate(with animation: UITableView.RowAnimation, completion: @escaping () -> Void)
    func getVisibleCells() -> [DCBaseCell]
    func scrollTo(offsetY: CGFloat)
    func scrollTo(offsetY: CGFloat, animated: Bool)
}
