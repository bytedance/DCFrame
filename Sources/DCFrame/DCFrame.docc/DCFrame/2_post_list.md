# Post List

This document uses 'Post List' as an example to create a more complex combination list, as shown below:

![post_list](post_list_1.png)

Using DCFrame can also easily create a combination list, still need three steps:

1. Define all the Cell and CellModel contained in the UI;
2. Define ContainerModels to assemble these CellModels;
3. Use ContainerTableView to load the root ContainerModel.

## Define Cells And CellModels

There are 4 types of cells in the Post List, as shown in the figure below:

![post_item](post_list_2.png)

**UserCell and UserModel:** 

In this example,  UserCell contains a `UILabel`, UserModel only needs to contain a `name` string data. So we can define two classes `UserInfoCell` and `UserInfoCellModel` as shown below.

```swift
class UserInfoCellModel: DCCellModel {
    var name: String!
    
    required init() {
        super.init()
        cellHeight = 41
        cellClass = UserInfoCell.self
    }
}

class UserInfoCell: DCCell<UserInfoCellModel> {
    // The detailed code can be found in the project example
  
    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
      
        nameLabel.text = cellModel.name
    }
}
```

**PhotCell and PhotoModel:** 

In order to simplify the display, here we define only the background color change in PhotoCell. So only need to define a color data in PhotoModel, as shown in `PhotoCellModel` below.

```swift
class PhotoCellModel: DCCellModel {
    var color: UIColor = UIColor(red: 4/255.0, green: 170/255.0, blue: 166/255.0, alpha: 1.0)

    required init() {
        super.init()
        
        cellClass = PhotoCell.self
        cellHeight = 375
    }
}

class PhotoCell: DCCell<PhotoCellModel> {
  	// The detailed code can be found in the project example
  
    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
      
        contentView.backgroundColor = cellModel.color
    }
}
```

**InteractiveCell and InteractiveModel:** 

In this example, InteractiveCell displays three buttons fixedly, so there is no need to define other UI data in `InteractiveCellModel`.

```swift
class InteractiveCellModel: DCCellModel {
    required init() {
        super.init()
        cellClass = InteractiveCell.self
        cellHeight = 41
    }
}

class InteractiveCell: DCCell<InteractiveCellModel> {
    // The detailed code can be found in the project example
}
```

**CommentCell and CommentModel:** 

We can see that the CommentCell contains only one label, so CommentModel only needs to contain one `comment` string data.

```swift
class CommentCellModel: DCCellModel {
    var comment: String!
    
    required init() {
        super.init()
        cellClass = CommentCell.self
        cellHeight = 25
    }
}

class CommentCell: DCCell<CommentCellModel> {
  	// The detailed code can be found in the project example
  
    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        
        commentLabel.text = cellModel.comment
    }
}
```

## Assemble CellModels

After completing the definition of the basic elements Cell and CellModel in the UI, the next step is to assemble the CellModels through ContainerModel. There are two tips for assembling CellModel and ContainerModel:

1. Find cells that will appear repeatedly in the UI, such as the CommentCell in the example above;
2. Multiple recurring elements can be packaged with a ContainerModel, for example each post above can be represented by a ContainerModel;

**Assemble CommentModels**

Here defines a `PostCommentsContainerModel` class to assemble the CommentModels of each post.

```swift
class PostCommentsContainerModel: DCContainerModel {
    init(with comments: [String]) {
        super.init()
        for comment in comments {
            let model = CommentCellModel()
            model.comment = comment
            addSubmodel(model)
        }
    }
}
```

**Assemble a post ContainerModel**

Another recurring UI module is Post, each post contains 4 types of Cell, so it also can be assembled with a ContainerModel, for example the following `PostItemContainerModel` class.

```swift
class PostItemContainerModel: DCContainerModel {
  	// The detailed code can be found in the project example
  	
    init(with post: PostData) {
        super.init()
        
        let userModel = UserInfoCellModel()
        userModel.name = post.username
        userModel.isHoverTop = true
        
        let photoModel = PhotoCellModel()
        let interactiveModel = InteractiveCellModel()
        
        let commentsCM = PostCommentsContainerModel(with: post.comments)
        addSubmodels([userModel, photoModel, interactiveModel, commentsCM])
    }
}
```

*Tips: ContainerModel has a powerful feature, it can assemble CellModel, and it can also assemble another ContainerModel, just like the commentsCM above.*

**Assemble the root ContainerModel**

Now every post can be represented by a `PostItemContainerModel`, in the last step, we use a `PostListContainerModel` to assemble each Post into a list, we can call it the root containerModel

```swift
class PostListContainerModel: DCContainerModel {
		// The detailed code can be found in the project example
  	
    override func cmDidLoad() {
        super.cmDidLoad()
        
        for data in mockData {
            let infoCM = PostInfoContainerModel(with: data)
            infoCM.bottomSeparator = DCSeparatorModel(color: .clear, height: 10)
            addSubmodel(infoCM)
        }
    }
}
```

## Load ContainerModel

Loading ContainerModel is similar to <doc:1_simple_list>, only create a DCContainerTableView and call the loadCM method to display the UI list.

```swift
let dcContainerTableView = DCContainerTableView()
// Omit layout code, the detailed code can be found in the project example

let postListContainerModel = PostListContainerModel()
dcContainerTableView.loadCM(postListContainerModel)
```

The structure of this example is shown in the figure below:

![post_component_cm](post_list_3.png)

Now we have learned how to use DCFrame to create a complex list, it can be found as simple as creating a simple list:

1. First create each basic UI Cells and CellModels;
2. Then use ContainerModel to combine CellModels;
3. Finally use ContainerTableView to load it. 

The power of ContainerModel is that it can not only assemble CellModel but also another ContainerModel.
