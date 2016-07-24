//
//  ViewController.swift
//  jsonToModel
//
//  Created by Tyler.Yin on 16/7/24.
//  Copyright © 2016年 ayong. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var baseClassTextField: NSTextField!
    @IBOutlet weak var NRDTextfield: NSTextField!
    
    deinit {
        self.textView = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //user
//        textView.string = "{\n        \"allow_all_comment\" : true,\n        \"avatar_large\" : \"http:\\/\\/tva2.sinaimg.cn\\/crop.0.0.664.664.180\\/9c083f03jw8f2ubbdbvhwj20ig0ig3zh.jpg\",\n        \"profile_image_url\" : \"http:\\/\\/tva2.sinaimg.cn\\/crop.0.0.664.664.50\\/9c083f03jw8f2ubbdbvhwj20ig0ig3zh.jpg\",\n        \"class\" : 1,\n        \"id\" : 2617786115,\n        \"created_at\" : \"Wed Feb 15 13:48:20 +0800 2012\",\n        \"allow_all_act_msg\" : false,\n        \"remark\" : \"\",\n        \"verified_trade\" : \"\",\n        \"mbtype\" : 0,\n        \"verified_reason\" : \"\",\n        \"location\" : \"海南 其他\",\n        \"geo_enabled\" : true,\n        \"idstr\" : \"2617786115\",\n        \"description\" : \"\",\n        \"url\" : \"\",\n        \"followers_count\" : 90,\n        \"follow_me\" : false,\n        \"bi_followers_count\" : 11,\n        \"lang\" : \"zh-cn\",\n        \"verified_source_url\" : \"\",\n        \"credit_score\" : 80,\n        \"block_word\" : 0,\n        \"statuses_count\" : 4,\n        \"following\" : false,\n        \"verified_type\" : -1,\n        \"avatar_hd\" : \"http:\\/\\/tva2.sinaimg.cn\\/crop.0.0.664.664.1024\\/9c083f03jw8f2ubbdbvhwj20ig0ig3zh.jpg\",\n        \"cover_image_phone\" : \"http:\\/\\/ww4.sinaimg.cn\\/crop.0.0.640.640.640\\/a1d3feabjw1ecat3p2p2qj20hs0hsmz4.jpg\",\n        \"star\" : 0,\n        \"name\" : \"xxxxmming\",\n        \"domain\" : \"\",\n        \"city\" : \"90\",\n        \"block_app\" : 0,\n        \"online_status\" : 0,\n        \"urank\" : 20,\n        \"verified_reason_url\" : \"\",\n        \"screen_name\" : \"xxxxmming\",\n        \"province\" : \"46\",\n        \"verified_source\" : \"\",\n        \"weihao\" : \"\",\n        \"gender\" : \"f\",\n        \"pagefriends_count\" : 5,\n        \"favourites_count\" : 31,\n        \"mbrank\" : 0,\n        \"profile_url\" : \"u\\/2617786115\",\n        \"user_ability\" : 0,\n        \"ptype\" : 0,\n        \"friends_count\" : 79,\n        \"verified\" : false\n      }"
        
        
        textView.string = "{\n\"name\":\"ayong\",\n\"height\":175.5,\n\"age\":28,\n\"rights\":\n\t{\n\t\t\"deleteable\":true,\n\t\t\"updateable\":false\n\t}\n}"
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func saveToModel(sender: NSButton) {
        let directoryPath = self.get_fullpath()
        if textView.string?.characters.count>0 {
            if let data = textView.string?.dataUsingEncoding(NSUTF8StringEncoding) {
                do {
                    let obj = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
                    //print(obj)
                    if obj is Dictionary<String,AnyObject> {
                        var baseClassName = "BaseClass"
                        if baseClassTextField.stringValue.characters.count > 0 {
                            baseClassName = baseClassTextField.stringValue
                        }
                        self.modelFromDic(obj as! Dictionary<String,AnyObject>, baseClassName: baseClassName, prefix: NRDTextfield.stringValue, directoryPath: directoryPath)
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
            
            
        }
    }
    
    func get_fullpath() -> String {
        let panel = NSOpenPanel()
//        let fileTypes = ["txt","doc","h","m"]
        
        panel.message = "select a file"
        panel.prompt = "OK"
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        
//        panel.allowedFileTypes = fileTypes
        var path_all = "";
        let result = panel.runModal()
        if (result == NSFileHandlingPanelOKButton)
        {
            path_all = (panel.URL?.path)!
        }
        return path_all
    }
    
    
    
    func modelFromDic(obj:Dictionary<String,AnyObject>, baseClassName:String, prefix:String?, directoryPath: String) -> Void {
        
        if directoryPath.characters.count==0 {
            return
        }
        
        var className: String! = ""
        if prefix != nil {
            className = "\(prefix!)\(baseClassName)"
        }
        
        //最后的结果
        var result = ""
        let fm = NSDateFormatter.init()
        fm.dateFormat = "yy/M/d"
        let date = fm.stringFromDate(NSDate())
        fm.dateFormat = "yyyy"
        let year = fm.stringFromDate(NSDate())
        //文件信息
        let fileInfo = "//\n//  \(className).swift\n//\n//  Created by ayong  on \(date)\n//  Copyright (c) \(year) __MyCompanyName__. All rights reserved.\n//"
        //解析的所有键名声明
        var constKey = "\n\n"
        
        //class包含的所有代码
        var classCode = "class \(className): CustomStringConvertible {\n\n"
        var initPropertyCode = "    init(dic:Dictionary<String,AnyObject>?) {\n        if dic != nil {\n"//实例初始化方法代码
        
        //方便调试打印，创建辅助方法dictionaryRepresentation
        var dictionaryRepresentationCode = "    func dictionaryRepresentation() -> Dictionary<String, AnyObject> {\n        var mutableDict = Dictionary<String, AnyObject>()\n"
        
        for (key,value) in obj {
            //有些关键字不能用
            var keyName = key
            if keyName == "id" || keyName == "var" || keyName == "let" || keyName == "class" || keyName == "is" || keyName == "for"  || keyName == "do" || keyName == "while" || keyName == "return" || keyName == "in" || keyName == "as" {
                keyName = "\(keyName)Property"
            }
            //去掉下划线并且下划线后第一个字母大写
            let array = keyName.componentsSeparatedByString("_")
            if array.count>1 {
                keyName = array[0]
                var index = 0
                for elem in array {
                    if index>0 {
                        keyName.appendContentsOf(elem.capitalizedString)
                    }
                    index += 1;
                }
            }
            
            
            var isAnotherModel = false
            
            //属性类型
            var type:String!
            if value is String {
                type = "String"
            }else if value is Double {
                type = "Double"
            }else if value is Float {
                type = "Float"
            }else if value is Int {
                type = "Int"
            }else if value is UInt {
                type = "UInt"
            }else if value is Bool {
                type = "Bool"
            }else if value is Dictionary<String,AnyObject> {//another model
                type = keyName.capitalizedString
                if prefix != nil {
                    type = "\(prefix!)\(type)"
                }
                isAnotherModel = true
            }else {
                type = value.className
            }
            classCode.appendContentsOf("    var \(keyName): \(type)?\n")
            
            //解析时候的键名（常量）
            let aConstKey = "k\(className)\(keyName.capitalizedString)"
            constKey.appendContentsOf("let \(aConstKey) = \"\(key)\"\n")
            
            //实例初始化
            if isAnotherModel {
                initPropertyCode.appendContentsOf("            \(keyName) = \(type).modelObjectWithDictionary(dic![\(aConstKey)] as? Dictionary<String,AnyObject>)\n")
                self.modelFromDic(value as! Dictionary<String,AnyObject>, baseClassName: keyName.capitalizedString, prefix: prefix, directoryPath: directoryPath)
                dictionaryRepresentationCode.appendContentsOf("        mutableDict[\(aConstKey)] = \(keyName)?.dictionaryRepresentation()\n")
            }else{
                initPropertyCode.appendContentsOf("            \(keyName) = dic![\(aConstKey)] as? \(type)\n")
                dictionaryRepresentationCode.appendContentsOf("        mutableDict[\(aConstKey)] = \(keyName)\n")
            }
        }
        //initPropertyCode最后追加"}"
        initPropertyCode.appendContentsOf("        }\n    }\n")
        
        //类方法（解析方法）
        classCode.appendContentsOf("\n\n    class func modelObjectWithDictionary(dic:Dictionary<String,AnyObject>?) -> \(className) {\n        return \(className).init(dic:dic)\n    }\n\n")
        //追加实例初始化方法
        classCode.appendContentsOf(initPropertyCode)
        
        //实现CustomStringConvertible协议方法description，方便调试打印
        classCode.appendContentsOf("    var description: String {\n        return \"\\(self.dictionaryRepresentation())\"\n    }\n")
        //dictionaryRepresentationCode
        dictionaryRepresentationCode.appendContentsOf("        return mutableDict\n    }\n")
        classCode.appendContentsOf(dictionaryRepresentationCode)
        
        //classCode最后追加"}"
        classCode.appendContentsOf("\n}\n\n")
        
        result.appendContentsOf(fileInfo)
        result.appendContentsOf(constKey)
        result.appendContentsOf("\n\n")
        result.appendContentsOf(classCode)
        
        //保存文件
        do {
            try result.writeToFile("\(directoryPath)/\(className).swift", atomically: true, encoding: NSUTF8StringEncoding)
        } catch let err as NSError {
            print(err)
        }
    }
    
    
}


/**************************************************************/

let kAYUserHeight = "height"
let kAYUserAge = "age"
let kAYUserRights = "rights"
let kAYUserName = "name"


class AYUser: CustomStringConvertible {
    
    var height: Double?
    var age: Double?
    var rights: AYRights?
    var name: String?
    
    
    class func modelObjectWithDictionary(dic:Dictionary<String,AnyObject>?) -> AYUser {
        return AYUser.init(dic:dic)
    }
    
    init(dic:Dictionary<String,AnyObject>?) {
        if dic != nil {
            height = dic![kAYUserHeight] as? Double
            age = dic![kAYUserAge] as? Double
            rights = AYRights.modelObjectWithDictionary(dic![kAYUserRights] as? Dictionary<String,AnyObject>)
            name = dic![kAYUserName] as? String
        }
    }
    var description: String {
        return "\(self.dictionaryRepresentation())"
    }
    func dictionaryRepresentation() -> Dictionary<String, AnyObject> {
        var mutableDict = Dictionary<String, AnyObject>()
        mutableDict[kAYUserHeight] = height
        mutableDict[kAYUserAge] = age
        mutableDict[kAYUserRights] = rights?.dictionaryRepresentation()
        mutableDict[kAYUserName] = name
        return mutableDict
    }
    
}

let kAYRightsUpdateable = "updateable"
let kAYRightsDeleteable = "deleteable"


class AYRights: CustomStringConvertible {
    
    var updateable: Double?
    var deleteable: Double?
    
    
    class func modelObjectWithDictionary(dic:Dictionary<String,AnyObject>?) -> AYRights {
        return AYRights.init(dic:dic)
    }
    
    init(dic:Dictionary<String,AnyObject>?) {
        if dic != nil {
            updateable = dic![kAYRightsUpdateable] as? Double
            deleteable = dic![kAYRightsDeleteable] as? Double
        }
    }
    var description: String {
        return "\(self.dictionaryRepresentation())"
    }
    func dictionaryRepresentation() -> Dictionary<String, AnyObject> {
        var mutableDict = Dictionary<String, AnyObject>()
        mutableDict[kAYRightsUpdateable] = updateable
        mutableDict[kAYRightsDeleteable] = deleteable
        return mutableDict
    }
    
}



