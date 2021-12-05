# Module Communication

This document continues to expand the 'Post List' example, we try to communicate between modules, as shown below:

![post_item_click](module_communication_1.gif)

DCFrame provides powerful **event sending** and **data sharing** capabilities, which can easily implement communication problems between different modules. To achieve the above functions, we need the following three steps:

1. Expand the functions of `InteractiveCell` and `PhotoCell` in the Post List example;
2. Define events and share data;
3. Handling module events and data sharing in ContainerModel.

## Expand Functions

In order to be able to support the above interactions, we need to add Button touch event to InteractiveCell.

```swift
class InteractiveCell: DCCell<InteractiveCellModel> {
  	// The detailed code can be found in the project example
    private lazy var likeButton: UIButton = {
        return createButton(with: "Like")
    }()
    private lazy var commentButton: UIButton = {
        return createButton(with: "Comment")
    }()
    private lazy var shareButton: UIButton = {
        return createButton(with: "Share")
    }()

    private func createButton(with title: String) -> UIButton {
        let button = UIButton()
     		// The detailed code can be found in the project example
        button.addTarget(self, action: #selector(touch(sender:)), for: .touchUpInside)
        return button
    }
    
    @objc func touch(sender: UIButton) {
        switch sender {
        case likeButton:
            // do something
        case commentButton:
            // do something
        case shareButton:
            // do something
        default: break
        }
    }
```

PhotoCell needs to add a new Label to display the text of the InteractiveCell button clicked, and PhotoCellModel needs to add a text string property

```swift
class PhotoCellModel: DCCellModel {
    var text = ""
    // The detailed code can be found in the project example
}

class PhotoCell: DCCell<PhotoCellModel> {
		// The detailed code can be found in the project example
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.darkText
        label.textAlignment = .center
        contentView.addSubview(label)
        return label
    }()

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        
        infoLabel.text = cellModel.text
        contentView.backgroundColor = cellModel.color
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        infoLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: infoLabel.font.lineHeight)
        infoLabel.center = CGPoint(x: contentView.bounds.width / 2, y: contentView.bounds.height / 2)
    }
}
```

## Define Event and Share Data

Now `InteractiveCell` has the ability to respond to touch events, it can pass the touch event through `DCEventID`, like this:

```swift
class InteractiveCell: DCCell<InteractiveCellModel> {
    static let likeTouch = DCEventID()
    static let commentTouch = DCEventID()
    static let shareTouch = DCEventID()
    
  	// The detailed code can be found in the project example
    
    @objc func touch(sender: UIButton) {
        switch sender {
        case likeButton:
            sendEvent(Self.likeTouch, data: sender.titleLabel?.text)
        case commentButton:
            sendEvent(Self.commentTouch, data: sender.titleLabel?.text)
        case shareButton:
            sendEvent(Self.shareTouch, data: sender.titleLabel?.text)
        default: break
        }
    }
}
```

In this example, PhotoCell needs to change background color and text, so it can define a shared data through `DCSharedDataID`,  subscribe to data changes.

```swift
class PhotoCell: DCCell<PhotoCellModel> {
    static let data = DCSharedDataID()
    // The detailed code can be found in the project example
    
    override func cellModelDidLoad() {
        super.cellModelDidLoad()
        
        subscribeData(Self.data) { [weak self] (text: String, color: UIColor) in
            guard let `self` = self else { return }
            
            self.cellModel.text = text
            self.cellModel.color = color
            
            self.infoLabel.text = text
            self.contentView.backgroundColor = color
        }
    }
}
```

**Note: To subscribe data changes in the Cell, it must be in the `cellModelDidLoad()` method.**

## Handle Communication

In DCFrame, the `sendEvent()` method will pass the event to the ContainerModel that contains it, and then the event will continue to be passed to the root ContainerModel, each ContainerModel can respond to this event. 

For shared data, it is generally from ContainerModel to Cell or CellModel. Therefore, the communication between two modules need to coordination through ContainerModel, avoid dependencies between modules, as shown below:

![event_data](module_communication_2.png)

In this example, the interaction between `InteractiveCell` and `PhotoCell` can be placed in `PostItemContainerModel`. Because `PostItemContainerModel` is the nearest CM that can handle the event.

```swift
class PostItemContainerModel: DCContainerModel {
    // The detailed code can be found in the project example
    
    override func cmDidLoad() {
        super.cmDidLoad()
        
        subscribeEvent(InteractiveCell.likeTouch) { [weak self] (text: String) in
            self?.shareData((text, UIColor.red), to: PhotoCell.data)
        }.and(InteractiveCell.commentTouch) { [weak self] (text: String) in
            self?.shareData((text, UIColor.yellow), to: PhotoCell.data)
        }.and(InteractiveCell.shareTouch) { [weak self] (text: String) in
            self?.shareData((text, UIColor.blue), to: PhotoCell.data)
        }
    }
}
```

**Note: To subscribe event in the ContainerModel, it must be in the `cmDidLoad()` method.**

