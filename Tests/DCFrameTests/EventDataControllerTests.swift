//
//  EventDataControllerTests.swift
//  DCFrame_ExampleTests
//
//  Created by 张政桢 on 2020/3/29.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import DCFrame

class EventDataControllerTests: BaseUnitTestCase {
    var rootEDC: DCEventDataController!
    var level1ChildEDC: [DCEventDataController]!
    var level2ChildEDC: [[DCEventDataController]]!
    
    
    /// 一级二级边界case
    var edc1_first: DCEventDataController!
    var edc1_last: DCEventDataController!
    var edc2_first: DCEventDataController!
    var edc2_last: DCEventDataController!

    let numChildEDC = 5
    
    override func setUp() {
        super.setUp()
        // 构建一个2层5叉树结构
        
        rootEDC = DCEventDataController()
        level1ChildEDC = [DCEventDataController]()
        level2ChildEDC = [[DCEventDataController]]()
        
        for _ in 0..<numChildEDC {
            let childEDC = DCEventDataController()
            rootEDC.addChildEDC(childEDC)
            level1ChildEDC.append(childEDC)
        }
        
        for (index, edc) in level1ChildEDC.enumerated() {
            level2ChildEDC.append([DCEventDataController]())
            for _ in 0..<numChildEDC {
                let childEDC = DCEventDataController()
                edc.addChildEDC(childEDC)
                level2ChildEDC[index].append(childEDC)
            }
        }
        
        edc1_first = level1ChildEDC[0]
        edc1_last = level1ChildEDC[numChildEDC - 1]
        edc2_first = level2ChildEDC[0][0]
        edc2_last = level2ChildEDC[numChildEDC - 1][numChildEDC - 1]
    }
    
    override func tearDown() {
        super.tearDown()
        rootEDC.removeAllChildEDC()
        level1ChildEDC.removeAll()
        level2ChildEDC.removeAll()
    }
    
    func testRootEDCIsRight() {
        XCTAssertTrue(edc1_first.rootEDC === rootEDC)
        XCTAssertTrue(edc2_last.rootEDC === rootEDC)
        
        XCTAssertTrue(edc2_first.parentEDC === edc1_first)
        XCTAssertTrue(edc2_last.parentEDC === edc1_last)
    }

    func testSharedData() {
        let dataID = DCSharedDataID()
        rootEDC.shareData(111, to: dataID)
        edc1_last.shareData(222, to: dataID)
        
        XCTAssertEqual(edc1_first.sharedData(of: dataID, default: 0), 111)
        XCTAssertEqual(edc2_last.sharedData(of: dataID, default: 0), 222)
        XCTAssertEqual(edc2_first.sharedData(of: dataID, default: 0), 111)
        
        XCTAssertEqual((edc1_first.sharedData(of: dataID) as! Int), 111)
        XCTAssertEqual((edc2_last.sharedData(of: dataID) as! Int), 222)
        XCTAssertEqual((edc2_first.sharedData(of: dataID) as! Int), 111)
    }
    
    func testSubscribeDataNoBroadcast() {
        let dataID = DCSharedDataID()
        
        var edc1_first_nowData = 111
        edc1_first.subscribeData(dataID, target: self) { (data: Int) in
            edc1_first_nowData = data
        }
        
        var edc2_last_nowData = 111
        edc2_last.subscribeData(dataID, target: self) { (data: Int) in
            edc2_last_nowData = data
        }
        
        var edc2_first_nowData = 111
        edc2_first.subscribeData(dataID, target: self, completion: { (data: Int) in
            edc2_first_nowData = data
        }) {
            edc2_first_nowData = -1
        }
        
        rootEDC.shareData(222, to: dataID, broadcast: false)
        
        XCTAssertEqual(edc1_first_nowData, 111)
        XCTAssertEqual(edc2_last_nowData, 111)
        XCTAssertEqual(edc2_first_nowData, -1)
    }
    
    func testSubscribeDataBroadcast() {
        let dataID = DCSharedDataID()
        
        var edc1_first_nowData = 111
        edc1_first.subscribeData(dataID, target: self) { (data: Int) in
            edc1_first_nowData = data
        }
        
        var edc2_last_nowData = 111
        edc2_last.subscribeData(dataID, target: self) { (data: Int) in
            edc2_last_nowData = data
        }
        
        var edc2_first_nowData = 111
        edc2_first.subscribeData(dataID, target: self, completion: { (data: Int) in
            edc2_first_nowData = data
        }) {
            edc2_first_nowData = -1
        }
        
        var edc3_first_nowData = 111
        edc1_last.subscribeData(dataID, target: self) { (data) in
            if let _data = data as? Int {
                edc3_first_nowData = _data
            } else {
                edc3_first_nowData = -1
            }
        }
        
        XCTAssertEqual(edc2_first_nowData, -1)
        XCTAssertEqual(edc3_first_nowData, -1)
        
        rootEDC.shareData(222, to: dataID)
        XCTAssertEqual(edc2_first_nowData, 222)
        XCTAssertEqual(edc3_first_nowData, 222)
        
        rootEDC.shareData(nil, to: dataID)
        XCTAssertEqual(edc1_first_nowData, 222)
        XCTAssertEqual(edc2_last_nowData, 222)
        XCTAssertEqual(edc2_first_nowData, -1)
        XCTAssertEqual(edc3_first_nowData, -1)
    }
    
    func testSubscribeDataAndLogic() {
        let dataID1 = DCSharedDataID()
        let dataID2 = DCSharedDataID()
        let dataID3 = DCSharedDataID()
        let dataID4 = DCSharedDataID()
        
        var data1 = 0
        var data2 = 0
        var data3 = 0
        var data4 = 0
        
        edc2_last.subscribeData(dataID1, target: self) { (data: Int) in
            data1 = data
        }.and(dataID2) { (data: Int) in
            data2 = data
        }.and(dataID3) { (data: Int) in
            data3 = data
        }.and(dataID4) { (data) in
            if let _data = data as? Int {
                data4 = _data
            } else {
                data4 = -1
            }
        }
        
        XCTAssertEqual(data4, -1)
        
        rootEDC.shareData(1111, to: dataID1)
        rootEDC.shareData(2222, to: dataID2)
        edc1_last.shareData(3333, to: dataID3)
        edc1_last.shareData(4444, to: dataID4)

        XCTAssertEqual(data1, 1111)
        XCTAssertEqual(data2, 2222)
        XCTAssertEqual(data3, 3333)
        XCTAssertEqual(data4, 4444)
    }
    
    func testSubscribeClosureData() {
        let dataID = DCSharedDataID()
        
        var edc1_first_nowData = 111
        edc1_first.subscribeData(dataID, target: self) { (data: Int) in
            edc1_first_nowData = data
        }
        
        var edc2_last_nowData = 111
        edc2_last.subscribeData(dataID, target: self) { (data: Int) in
            edc2_last_nowData = data
        }
        
        var edc2_first_nowData = 111
        edc2_first.subscribeData(dataID, target: self, completion: { (data: Int) in
            edc2_first_nowData = data
        }) {
            edc2_first_nowData = -1
        }
        
        rootEDC.shareData(to: dataID) { () -> Any? in
            return 222
        }
        rootEDC.shareData(to: dataID) { () -> Any? in
            return nil
        }

        XCTAssertEqual(edc1_first_nowData, 222)
        XCTAssertEqual(edc2_last_nowData, 222)
        XCTAssertEqual(edc2_first_nowData, -1)
    }
    
    func testSubscribeClosureDataNoBroadcast() {
        let dataID = DCSharedDataID()
        
        var edc1_first_nowData = 111
        edc1_first.subscribeData(dataID, target: self) { (data: Int) in
            edc1_first_nowData = data
        }
        
        var edc2_last_nowData = 111
        edc2_last.subscribeData(dataID, target: self) { (data: Int) in
            edc2_last_nowData = data
        }
        
        var edc2_first_nowData = 111
        edc2_first.subscribeData(dataID, target: self, completion: { (data: Int) in
            edc2_first_nowData = data
        }) {
            edc2_first_nowData = -1
        }
        
        rootEDC.shareData(to: dataID, broadcast: false) { () -> Any? in
            return 222
        }

        XCTAssertEqual(edc1_first_nowData, 111)
        XCTAssertEqual(edc2_last_nowData, 111)
        XCTAssertEqual(edc2_first_nowData, -1)
    }
    
    func testRemoveSharedData() {
        let dataID = DCSharedDataID()
        
        var edc1_first_nowData = 111
        var edc2_last_nowData = 111
        
        rootEDC.shareData(222, to: dataID)
        
        edc1_first.subscribeData(dataID, target: self) { (data: Int) in
            edc1_first_nowData = data
        }
        
        rootEDC.removeSharedData(with: dataID)
        
        edc2_last.subscribeData(dataID, target: self) { (data: Int) in
            edc2_last_nowData = data
        }
        
        XCTAssertEqual(edc1_first_nowData, 222)
        XCTAssertEqual(edc2_last_nowData, 111)
    }
 
    func testSubscribeEvent() {
        let eventID1 = DCEventID()
        var data1 = 0
        rootEDC.subscribeEvent(eventID1, target: self) {
            data1 = -1
        }
        edc1_last.sendEvent(eventID1)
        XCTAssertEqual(data1, -1)
        
        let eventID2 = DCEventID()
        var data2 = 0
        rootEDC.subscribeEvent(eventID2, target: self) { (data) in
            if let _data = data as? Int {
                data2 = _data
            }
        }
        edc2_first.sendEvent(eventID2, data: 222)
        XCTAssertEqual(data2, 222)
        
        let eventID3 = DCEventID()
        var data3 = 0
        rootEDC.subscribeEvent(eventID3, target: self) { (data: Int) in
            data3 = data
        }
        edc2_last.sendEvent(eventID3, data: 222)
        XCTAssertEqual(data3, 222)
        
        // 测试and逻辑
        rootEDC.removeAllSubscribeEvent(frome: self)
        
        rootEDC.subscribeEvent(eventID1, target: self) { (data: Int) in
            data1 = data
        }.and(eventID2) { (data: Int) in
            data2 = data
        }.and(eventID3) { (data) in
            if let _data = data as? Int {
                data3 = _data
            }
        }
        
        edc1_last.sendEvent(eventID1, data: 1111)
        edc2_first.sendEvent(eventID2, data: 2222)
        edc2_last.sendEvent(eventID3, data: 3333)
        
        XCTAssertEqual(data1, 1111)
        XCTAssertEqual(data2, 2222)
        XCTAssertEqual(data3, 3333)
    }
    
    func testSubscribeEvents() {
        let eventID1 = DCEventID()
        let eventID2 = DCEventID()
        let eventID3 = DCEventID()
        
        var data1 = 0
        var data2 = 0
        var data3 = 0
        
        rootEDC.subscribeEvents([eventID1, eventID2, eventID3], target: self) { (id: DCEventID, data: Int) in
            if id == eventID1 {
                data1 = data
            }
            if id == eventID2 {
                data2 = data
            }
            if id == eventID3 {
                data3 = data
            }
        }
        
        edc1_last.sendEvent(eventID1, data: 1111)
        edc2_first.sendEvent(eventID2, data: 2222)
        edc2_last.sendEvent(eventID3, data: 3333)
        
        XCTAssertEqual(data1, 1111)
        XCTAssertEqual(data2, 2222)
        XCTAssertEqual(data3, 3333)
        
        // 测试非范型
        rootEDC.removeAllSubscribeEvent(frome: self)
        
        var dataStr2 = ""
        rootEDC.subscribeEvents([eventID1, eventID2, eventID3], target: self) { (id: DCEventID, data: Any?) in
            if id == eventID1, let data = data as? Int {
                data1 = data
            }
            if id == eventID2, let data = data as? String  {
                dataStr2 = data
            }
            if id == eventID3, let data = data as? Int {
                data3 = data
            }
        }
        
        edc1_last.sendEvent(eventID1, data: 1111)
        edc2_first.sendEvent(eventID2, data: "2222")
        edc2_last.sendEvent(eventID3, data: 3333)
        
        XCTAssertEqual(data1, 1111)
        XCTAssertEqual(dataStr2, "2222")
        XCTAssertEqual(data3, 3333)
    }
    
    func testSubscribeEventsAndLogic() {
        let eventID1 = DCEventID()
        let eventID2 = DCEventID()
        let eventID3 = DCEventID()
        
        var data1 = 0
        var data2 = ""
        var data3 = 0
        
        rootEDC.subscribeEvent(eventID1, target: self) { (data) in
            data1 = data
        }.and([eventID2, eventID3]) { (id: DCEventID, data: Any?) in
            if id == eventID2, let data = data as? String  {
                data2 = data
            }
            if id == eventID3, let data = data as? Int {
                data3 = data
            }
        }

        edc1_last.sendEvent(eventID1, data: 1111)
        edc2_first.sendEvent(eventID2, data: "2222")
        edc2_last.sendEvent(eventID3, data: 3333)
        
        XCTAssertEqual(data1, 1111)
        XCTAssertEqual(data2, "2222")
        XCTAssertEqual(data3, 3333)
    }
    
    func testRemoveChildList() {
        let parentEDC = DCEventDataController()
        
        let child1EDC = DCEventDataController()
        let child2EDC = DCEventDataController()
        let child3EDC = DCEventDataController()
        
        parentEDC.addChildsEDC([child1EDC, child2EDC, child3EDC])

        parentEDC.removeChildEDC(child1EDC)
        parentEDC.removeChildEDC(child3EDC)

        XCTAssertNil(child1EDC.parentEDC)
        XCTAssertNil(child1EDC.parentEDC)
        XCTAssertNotNil(child2EDC.parentEDC)
    }
    
    func testremoveAllSubscribeData() {
        var data1 = 111
        let dataID = DCSharedDataID()
        edc2_last.subscribeData(dataID, target: self) { (data: Int) in
            data1 = data
        }
        
        var data2 = 111
        let dataID2 = DCSharedDataID()
        edc2_last.subscribeData(dataID2, target: self) { (data: Int) in
            data2 = data
        }
        
        rootEDC.shareData(222, to: dataID)
        rootEDC.shareData(333, to: dataID2)
        
        XCTAssertEqual(data1, 222)
        XCTAssertEqual(data2, 333)
        
        edc2_last.removeAllSubscribeData(frome: self)
        
        rootEDC.shareData(-222, to: dataID)
        rootEDC.shareData(-333, to: dataID2)
        
        XCTAssertEqual(data1, 222)
        XCTAssertEqual(data2, 333)
    }
    
    func testremoveAllSubscribeEvent() {
        let eventID = DCEventID()
        var data = 111
        rootEDC.subscribeEvent(eventID, target: self) {
            data = 222
        }
        
        edc2_last.sendEvent(eventID)
        
        XCTAssertEqual(data, 222)
        
        rootEDC.removeAllSubscribeEvent(frome: self)
        
        data = 111
        edc2_last.sendEvent(eventID)
        
        XCTAssertEqual(data, 111)
    }
}
