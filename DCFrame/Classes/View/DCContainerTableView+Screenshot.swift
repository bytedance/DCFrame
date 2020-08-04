//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

extension DCContainerTableView {
    /// Get screenshot of the current `UITableView`
    /// - Returns: screenshot of the `UITableView`
    public func dcScreenshot() -> UIImage? {
        func dcScreeshotOfCell(at indexPath: IndexPath) -> UIImage? {
            var cellScreenshot: UIImage? = nil
            scrollToRow(at: indexPath, at: .top, animated: false)
            if let dcCell = cellForRow(at: indexPath) as? DCBaseCell, dcCell.baseCellModel.willBeInScreenShot {
                dcCell.beforeScreenshot()
                cellScreenshot = dcCell.dc_snapShotImage()
                dcCell.afterScreenshot()
            }
            return cellScreenshot
        }
        var imagesArray = [UIImage]()
        let currentTableViewOffset = contentOffset
        for row in dataController.objects.indices {
            let indexPath = IndexPath(row: row, section: 0)
            if let image = dcScreeshotOfCell(at: indexPath) {
                imagesArray.append(image)
            }
        }
        setContentOffset(currentTableViewOffset, animated: false)
        return UIImage.dc_verticalImage(with: imagesArray)
    }
}
