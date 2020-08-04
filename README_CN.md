# DCFrame

[![CI Status](https://travis-ci.org/bytedance/DCFrame.svg?branch=master&style=flat)](https://travis-ci.org/github/bytedance/DCFrame)
[![Version](https://img.shields.io/cocoapods/v/DCFrame.svg?style=flat)](https://cocoapods.org/pods/DCFrame)
[![License](https://img.shields.io/cocoapods/l/DCFrame.svg?style=flat)](https://cocoapods.org/pods/DCFrame)
[![Platform](https://img.shields.io/cocoapods/p/DCFrame.svg?style=flat)](https://cocoapods.org/pods/DCFrame)

DCFrame是一个由Model驱动的界面组合框架，通过使用该框架可以实现：轻松组装和管理复杂界面；0成本进行界面模块的复用和迁移；0耦合进行界面模块间的通信。

DCFrame和[IGListKit](https://github.com/Instagram/IGListKit)相比具有如下优势：

1. 更加轻量级：代码行数3K；
2. 支持Model组合：分而治之管理和组合复杂界面；
3. 上手门槛低： 接口简洁易用，直接Model驱动界面，告别代理方式进行数据管理；
4. 模块0耦合通信：提供了完善的模块间事件传递和数据共享机制，可实现模块间0耦合通信。

## 环境要求

* Xcode 10.2+
* iOS 9.0+
* Swift 5.0+

## 安装

```ruby
pod 'DCFrame'
```

## 如何使用

### 例子

为了便于已经熟悉IGListKit的同学快速上手DCFrame，这里提供了和 [IGListKit](https://github.com/Instagram/IGListKit) 一样的例子供大家参考。拉取该仓库，在Example文件夹下执行`pod install`来运行Example项目。

<img src="./Docs/examples.gif" alt="examples" width="300" />

### 创建一个简单列表

<img src="./Docs/list.png" alt="list" width="300" />

使用DCFrame可以非常容易的创建一个列表，只需要三步即可：1. 创建CellModel；2. 创建Cell界面；3.使用容器View加载一组CellModel。

#### 1. 创建CellModel

上面的列表只需要显示一个Label，所以这里将CellModel命名为：`LabelModel`，该Model需要继承自DCCellModel。CellModel中包含Cell界面中所需要的数据，除了包含界面所需的数据和数据处理逻辑外，还需要指定对应Cell的类型以及Cell的高度。

* *如果Cell是使用Xib布局，需要指定`isXibCell = true`；*

* *如果Cell使用自动布局约束，也可以不指定cellHeight，DCFrame会自动适配Cell高度*。

```swift
class LabelModel: DCCellModel {
    var text: String = ""
    
    required init() {
        super.init()
        cellHeight = 50
        cellClass = LabelCell.self
        isXibCell = true
    }
}
```

#### 2. 创建Cell界面

这里使用Xib创建一个包含UILabel的Cell，这里命名为：`LabelCell`。`LabelCell`需要继承自`DCCell`，并且需要指定该Cell需要的CellModel范型，这里为：`LabelModel`。覆写DCCell的`cellModelDidUpdate()`方法，在该方法中将cellModel中的数据赋值给界面中的Label。

* *DCFrame基于`UITableView`进行封装，`cellModelDidUpdate()`的触发时机在`UITableView`的`tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell`中*
* *为了避免`UITabelViewCell`因为复用导致界面数据错误问题，需要在`cellModelDidUpdate()`中刷新界面数据*

```swift
class LabelCell: DCCell<LabelModel> {
    @IBOutlet weak var label: UILabel!

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
      
        label.text = cellModel.text
    }
}
```

#### 3. 加载CellModel

我们可以看出每一个CellModel其实都能表示一个列表Cell，要将Cell显示在界面上还需要做如下2步操作：

1. 创建一个`DCContainerModel`，并将一组CellModel添加到`DCContainerModel`中；
2. 创建一个`DCContainerTableView`，调用`DCContainerTableView`的`loadCM(_ cm: DCContainerModel)`方法来加载CellModel了。

`DCContainerModel`可以看成是一个**"文件夹"**，用来组装CellModel，`DCContainerTableView`是加载`DCContainerModel`的容器View。

* *`DCFrame`中View的概念有两个：`DCCell`和`DCContainerTableView`*
  * *`DCCell`继承自`UITabelViewCell`代表列表中具体的界面元素*
  * *`DCContainerTableView`继承自`UITableView`是`DCCell`的容器*
* *`DCFrame`中Model的概念也有两个：`DCCellModel`和`DCContainerModel`*
  * *`DCCellModel`为`DCCell`提供界面数据和数据处理逻辑*
  * *`DCContainerModel`是`DCCellModel`的容器*

```swift
class MyListViewController: UIViewController {
    public let dcTableView = DCContainerTableView()

    override func viewDidLoad() {
        super.viewDidLoad()
      
        view.addSubview(dcTableView)

        loadData()
    }

  	private func loadData() {
      	let listCM = DCContainerModel()
      	for num in 1..<100 {
          	let model = LabelModel()
          	model.text = "\(num)"
          	listCM.addSubmodel(model)
        }
      	dcTableView.loadCM(listCM)
    }
  
  	override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    		dcTableView.frame = view.frame
        dcTableView.contentInset = UIEdgeInsets(top: navbarHeight(), left: 0, bottom: safeBottomMargin(), right: 0)
        dcTableView.contentOffset = CGPoint(x: 0, y: -navbarHeight())
    }
}
```

### 创建一个复杂列表

<img src="./Docs/post_list.png" alt="post_list" width="300" />

#### 1. 创建Cell和CellModel

和创建简单列表例子一样，要创建一个复杂的列表首先需要创建界面中不同Cell界面元素的。可以看出上面复杂列表界面中，包含的cell类型有4种。每一个Cell对应有一个CellModel，为其提供数据，如下图所示：

<img src="./Docs/post_item.png" alt="post_item" width="600" />



#### 2. 组合CellModel

创建4中界面Cell和CellModel后，就可以通过`DCContainerModel`来进行组合界面了，要构建上面的复杂列表，可以通过下面的组合方式管理CellModel：

<img src="./Docs/post_component_cm.png" alt="post_component_cm" width="700" />

1. `CommentCM`：包含多个`CommentModel`

```swift
/// CommentCM
class CommentCM: DCContainerModel {
    func update(with comments: [String]) {
        removeAllSubmodels()
        for comment in comments {
            let model = CommentModel(comment: comment)
            addSubmodel(model)
        }
    }
}
```

2. `PostItemCM`：组装`UserModel`、`PhotoModel`、`InteractiveModel`和`CommentCM`

```swift
/// PostItemCM
class PostItemCM: DCContainerModel {
    func update(with post: PostData) {
        removeAllSubmodels()
        
        let userModel = UserModel(name: post.username)        
        let photoModel = PhotoModel()
        let interactiveModel = InteractiveModel()
        let commentCM = CommentCM()
        commentCM.update(with: post.comments)
        
        addSubmodels([userModel, photoModel, interactiveModel, commentCM])
    }
}
```

3. `PostListCM`：包含多个`PostItemCM`，从而实现列表中多个用户信息的展示

```swift
/// PostListCM
class PostListCM: DCContainerModel {
    private let mockData = [
        PostData(username: "userA", comments: [
            "Luminous triangle",
            "Awesome",
            "Super clean",
            "Stunning shot",
        ]),
        PostData(username: "userB", comments: [
            "The simplicity here is superb",
            "thanks!",
            "That's always so kind of you!",
            "I think you might like this",
        ]),
        PostData(username: "userC", comments: [
            "So good",
        ]),
        PostData(username: "userD", comments: [
            "hope she might like it.",
            "I love it."
        ]),
    ]
    
    override func cmDidLoad() {
        super.cmDidLoad()
        
        for data in mockData {
            let itemCM = PostItemCM()
            itemCM.update(with: data)
            itemCM.bottomSeparator = DCSeparatorModel(color: .clear, height: 10)
            addSubmodel(infoCM)
        }
    }
}
```

可以发现`DCContainerModel`不仅可以包含`DCCellModel`也可以包含`DCContainerModel`类型，就像"**文件夹**"一样，通过这样的结构可以非常轻松的管理复杂的界面。

### 事件传递与数据共享

<img src="./Docs/post_item_click.gif" alt="post_item_click" width="300" />

在上面的复杂列表中，`InteractiveCell`中可以点击“Like Comment Share”三个按钮，控制`PhotoCell`中进行背景和文案的变化。在DCFrame中通过CellModel来驱动Cell的加载和显示，所以不同Cell模块间不能直接进行依赖和传递数据。要实现上面模块间的通信，需要三步：

#### 1. 在InteractiveCell定义事件

DCFrame中的Cell无需关心具体的业务逻辑，只需关心自己的功能实现，比如上面例子中`InteractiveCell`点击按钮改变`PhotoCell`的背景颜色就是具体的业务逻辑，而点击事件本身是Cell的所能提供的功能。

Cell通过定义`DCEventID`，来进行事件的传递。`DCEventID`是`DCFrame`中的一个事件数据类型，主要包含是一个递增的`Int64`位整型数字。

通常将事件定义为`static`类型，因为事件ID可以看成是一个事件的名字，属于`InteractiveCell`类本身。当按钮点击后，通过`sendEvent()`方法将事件发送出去。

```swift
class InteractiveCell: DCCell<InteractiveCellModel> {
  	// 定义事件
    static let likeTouch = DCEventID()
    static let commentTouch = DCEventID()
    static let shareTouch = DCEventID()
    
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

#### 2. 在PhotoModel中定义共享数据

对于`PhotoCell`来说，界面的变化是通过`PhotoModel`数据变化进行驱动的，所以可以在`PhotoModel`中通过监听共享数据的变化，来控制界面的变化。

这里`DCSharedDataID()`和`DCEventID()`一样也是一个`Int64`整型数据。用来表示需要获取的共享数据名字。这里要强调的是：

* *订阅共享数据不仅可以在`DCCellModel`中，也可以在`DCCell`中进行订阅，这里因为`PhotoCell`会被复用，所以在`DCCellModel`中订阅更合适；*
* *在该例子中，因为`PhotoModel`直接被`PostItemCM`包含，所以也可以在`PostItemCM`中监听到点击事件后，对`PhotoModel`进行直接的数据赋值，然后调用`needReloadCellData()`方法完成界面的刷新。*

```swift
class PhotoModel: DCCellModel {
    static let data = DCSharedDataID()
    
    var text = ""
    var color: UIColor = UIColor(red: 4/255.0, green: 170/255.0, blue: 166/255.0, alpha: 1.0)

    required init() {
        super.init()
        
        cellClass = PhotoCell.self
        cellHeight = 375
    }
    
    override func cellModelDidLoad() {
        super.cellModelDidLoad()
      
        // 订阅共享数据
        subscribeData(Self.data) { [weak self] (text: String, color: UIColor) in
            self?.text = text
            self?.color = color
            self?.needReloadCellData()
        }
    }
}
```

#### 3. 在CM中进行模块间的交互处理

CM除了可以像**"文件夹"**一样组合CellModel和CM外，还可以扮演处理模块间通信的中介者角色，模块间的交互逻辑通常放在他们最近的公共CM节点进行处理。

本例子中`InteractiveModel`和`PhotoModel`最近的公共CM节点为`PostItemCM`，所以可以在`PostItemCM`中处理这两个模块的交互逻辑，如下代码所示：

```swift
class PostItemCM: DCContainerModel {
    override func cmDidLoad() {
        super.cmDidLoad()
        
      	// 在CM中进行事件响应和数据的共享
        subscribeEvent(InteractiveCell.likeTouch) { [weak self] (text: String) in
            self?.shareData((text, UIColor.red), to: PhotoModel.data)
        }.and(InteractiveCell.commentTouch) { [weak self] (text: String) in
            self?.shareData((text, UIColor.yellow), to: PhotoCellModel.data)
        }.and(InteractiveCell.shareTouch) { [weak self] (text: String) in
            self?.shareData((text, UIColor.blue), to: PhotoCellModel.data)
        }
    }
}
```

### 事件传递和数据共享的规则

DCFrame事件传递和数据共享有两个规则：

1. 事件向上传递：CM树中任何一个节点可以产生和发送事件，事件从当前节点向上传递，直到根节点CM结束，在其中任何一个中间CM中都能响应事件，且不会打断向上传递的事件；
2. 数据向下共享：在任何一个节点可以共享数据，数据会沿着当前节点向下传递，先序遍历当前节点下的子孙节点，在其子孙节点中可以订阅该节点进行共享的数据。（上面例子中给PhotoModel.data共享数据，属于定向为PhotoModel共享数据，其它Model其实也可以订阅到PhotoModel.data的数据，但通常不会这么做）。

<img src="./Docs/event_data.png" alt="event_data" width="500" />

在`DCFrame`中通过组合CellModel来驱动界面，所以不同界面元素从框架层面解除了依赖。要实现上图中Model_A和B的通信，就需要通过Model_A和B的公共CM节点来处理他们的交互：

* *Model_A发送一个事件，事件会沿着CM树形结构向上传递，直到根节点；*

* *在CM中响应Model_A的事件，根据业务逻辑要求，为Model_B共享相关的数据，从而实现驱动Model_B界面的变化。*

## License

DCFrame is available under the MIT license. See the LICENSE file for more info.
