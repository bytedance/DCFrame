# Simple list

This document describes how to create a list of a single Cell type through DCFrame, as shown in the following figure:

<img src="./Images/simple_list_1.png" alt="list" width="300" />

With DCFrame, you can easily create a list in three steps: 

1. Define a `CellModel` type and the corresponding `Cell` type;
2. Create a `ContainerModel` to wrap `CellModel`;
3. Use ContainerTableView to load `ContainerModel`.

## Define CellModel And Cell

The definition of CellModel needs to meet the following conditions:

1. Need to inherit from `DCCellModel`;
2. Define the data needed for the Cell;
3. Set Cell type and height.

In the above example, Cell has only one string data, so we can define CellModel like this:

```swift
class SimpleLabelModel: DCCellModel {
    var text: String = ""
    
    required init() {
        super.init()
        cellClass = SimpleLabelCell.self
        cellHeight = 50
    }
}
```

The definition of Cell needs to meet the following conditions:

1. Inherited from` DCCell`, specify CellModel generic type;
2. Define UI elements and layout them in `SetupUI()` function;
3. Assign cell UI data in the `cellModelDidUpdate()` method.

In the above example, it can be seen that the Cell contains a Label and separate line, so we can define Cell like this:

```swift
class SimpleLabelCell: DCCell<SimpleLabelModel> {
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()

    let separateLine: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.lightGray.cgColor
        return layer
    }()
    
    override func setupUI() {
        super.setupUI()
        
        contentView.addSubview(label)
        contentView.layer.addSublayer(separateLine)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let left: CGFloat = 15
        let height: CGFloat = 1.0 / UIScreen.main.scale
        
        label.frame = bounds.inset(by: UIEdgeInsets(top: 8, left: left, bottom: 8, right: 15))
        separateLine.frame = CGRect(x: left, y: bounds.height - height, width: bounds.width - left, height: height)
    }

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        
        label.text = cellModel.text
    }
}
```

**Note: Cell UI assignment operations are recommended in the `cellModelDidUpdate()` method, because it will be reused for the list Cell, The `cellModelDidUpdate()` will be called back before the Cell is reused.**

## Create A ContainerModel

The single element of the list contains need two roles CellModel and Cell which have been defined. To assemble these single elements, another role is needed, this is the ContainerModel. Define a ContainerModel needs to meet the following conditions:

1. Need to inherit from `DCContainerModel`;
2. Execute the initialization logic in the `cmDidLoad()` method, such as: create a list in the above example;
3. Use `addSubmodel()` method to assemble cellModel.

In the above example, the initialization logic is to assemble a list, so we can define ContainerModel like this:

```swift
class SimpleListContainerModel: DCContainerModel {
    override func cmDidLoad() {
        super.cmDidLoad()
        for num in 0...100 {
            let model = SimpleLabelModel()
            model.text = "\(num)"
            addSubmodel(model)
        }
    }
}
```

*Tip: For the simple list above, you can directly create a `DCContainerModel` object to assemble the CellModel without creating a new SimpleListContainerModel class. This way can be found in the project example.*

## Load ContainerModel

After completing the definition of ContainerModel, the UI data and logic of the list have been completed. The `DCContainerTableView` provided by DCFrame can be used to load and display ContaienrModel like this:

```swift
class SimpleListViewController: UIViewController {
    let dcTableView = DCContainerTableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(dcTableView)
        
        let simpleListCM = SimpleListContainerModel()
        dcTableView.loadCM(simpleListCM)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dcTableView.frame = view.bounds
    }
}
```





