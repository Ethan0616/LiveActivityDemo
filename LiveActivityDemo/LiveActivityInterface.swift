//
//  LiveActivityInterface.swift
//  iOS16-Live-Activities
//
//  Created by Ethan on 2022/10/19.
//

import Foundation
import ActivityKit
import UIKit

public enum LiveActivityError: Error {
    case None
    case FailedToCreate
    case ExceedQuantityLimit
    case ActivityEmpty
    case SameObject
    case NotSupported
    case NotFound
    case WrongParameter
}

@available(iOS 16.1, *)
public class LiveActivityInterface<Attributes: ActivityAttributes> : ObservableObject {
    
    typealias TokenCallBack = (String) -> Void
    /// Create Live activity
    /// - Parameters:
    ///   - staticData: Attributes
    ///   - contentState: Attributes.ContentState
    ///   - nickName: nickName description
    static func start(
        staticData: Attributes,
        contentState: Attributes.ContentState,
        nickName: String = ""
    ) throws  {
        let error = internalStart(staticData: staticData, contentState: contentState, nickName: nickName)
        if error != .None { throw error }
    }
    
    
    /// Update the live activity, if the parameter is empty, update the first object
    /// - Parameters:
    ///   - contentState: Attributes.ContentState
    ///   - nickNmae: nickNmae description
    ///   - ID: ID description
    static func update(contentState:Attributes.ContentState,
                       nickNmae:String? = nil,
                       ID : String? = nil
    ) throws {
        let error = internalUpdate(contentState: contentState,nickNmae: nickNmae,ID: ID)
        if error != .None { throw error }
    }
    
    
    /// Stop live activity with nickName
    /// - Parameter nickName: nickName description
    static func stopActivity(nickName:String = "") {
        internalStopActivity(nickName: nickName)
    }
    
    
    /// Stop all liveactivites
    static func stopAllActivities() {
        internalStopAllActivities()
    }
    
    
    /// Check Authorize and has liveactivity
    /// - Returns: Authorize
    static func alreadyHaveLiveActivity() -> Bool {
        return internalAlreadyHaveLiveActivity()
    }
    
    /// Log print
    static func showAllActivity() {
        internalShowAllActivity()
    }
    
    
    /// Observer
    /// - Parameter tokenCallBack: callback
    static func addActivityObserver(tokenCallBack:@escaping TokenCallBack) {
        LiveActivityInstance.shared.tokenCallBack = tokenCallBack
    }
}

fileprivate extension LiveActivityInterface {
    static func internalStart (
        staticData: Attributes,
        contentState: Attributes.ContentState,
        nickName: String = ""
    ) -> LiveActivityError  {
        
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            // 用户未授权，需要在设置中开启相关按钮
            return LiveActivityError.NotSupported
        }
        
        guard Activity<Attributes>.activities.count < 5 else {
            // 当前超过5个，第六个LiveActivity 就失败，最多五个
            return LiveActivityError.ExceedQuantityLimit
        }
        // 同步数据，移除旧数据 (可在移除的时候，重新添加数据)
        let activityIDs = Activity<Attributes>.activities.map{$0.id}
        LiveActivityInstance.shared.synchronize(activityIDs: activityIDs)
        
        // has same object
        if LiveActivityInstance.shared.checkNickName(nickName: nickName) {
            return LiveActivityError.SameObject
        }
        
        var nActivity : Activity<Attributes>? = nil
//        print("================================当前liveActivity个数为：【\(Activity<Attributes>.activities.count)】")
        LiveActivityInstance.shared.addActivityObserver(nActivity)
        
        do {
            nActivity = try Activity<Attributes>.request(
                attributes: staticData,
                contentState: contentState,
                pushType: PushType.token)

        } catch (let error) {
            print("make sure capability pushtoken is set:\(error.localizedDescription)")
            return LiveActivityError.FailedToCreate
        }
        guard let activity = nActivity else { return LiveActivityError.ActivityEmpty }

        print("You current activity ID is: \(activity.id)")

        LiveActivityInstance.shared.addActivityModel(activity,nickName)
        return LiveActivityError.None
    }
    
    static func internalUpdate(contentState:Attributes.ContentState,
                       nickNmae:String? = nil,
                       ID : String? = nil
    ) -> LiveActivityError {
        
        guard Activity<Attributes>.activities.count > 0 else {
            return .ActivityEmpty
        }
        
        // Only one LiveActivity
        if nickNmae == nil && ID == nil {
            guard let activity = Activity<Attributes>.activities.first else {
                return .ActivityEmpty
            }
            Task {
                await activity.update(using: contentState)
            }
            return .None
        }
        
        var tempID : String
        if let nickNameStr : NSString = nickNmae as NSString?, !nickNameStr.isEqual(to: "") {
            tempID = LiveActivityInstance.shared.getID(NickName: nickNameStr as String)
        }else if let IDStr : NSString = ID as NSString?, !IDStr.isEqual(to: "") {
            tempID = LiveActivityInstance.shared.getToken(IDStr as String)
        }else {
            return .WrongParameter
        }
        let activityID = tempID
        Task {
            for activity in Activity<Attributes>.activities {
                
                if activityID == activity.id {
                    await activity.update(using: contentState )
                    return
                }
            }
        }
        return .None
    }
    
    static func internalStopActivity(nickName:String = "") {
        if nickName == "" {
            stopAllActivities()
            return
        }
        Task {
            let activityID = LiveActivityInstance.shared.getID(NickName: nickName)
            
            for activity in Activity<Attributes>.activities {
                
                if activityID == activity.id {
                    await activity.end(dismissalPolicy: .immediate)
                    LiveActivityInstance.shared.delete(activityID: activityID)
                    return
                }
            }
        }
    }
    
    static func internalStopAllActivities() {
        Task {
            for activity in Activity<Attributes>.activities{
                await activity.end(dismissalPolicy: .immediate)
//                print("details: \(activity.id) -> \(activity.attributes)")
            }
        }
    }
    
    static func internalShowAllActivity() {
        guard Activity<Attributes>.activities.count > 0  else {
//            print("nothing to print")
            return
        }
        Task {
            for activity in Activity<Attributes>.activities {
                print("details: \(activity.id) -> \(activity.attributes)")
            }
        }
    }
    
    static func internalAlreadyHaveLiveActivity() -> Bool {
        
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return false
        }
        
        guard Activity<Attributes>.activities.count > 0 else {
            return false
        }
        
        guard LiveActivityInstance.shared.models.count > 0 else {
            return false
        }
        
        return true
    }
    
    static func shared() {
        let _ = LiveActivityInstance.shared
    }
}


@available(iOS 16.1, *)
fileprivate class LiveActivityInstance : NSObject {
    
    fileprivate var tokenCallBack : LiveActivityInterface.TokenCallBack? = nil
    
    fileprivate var tokenUpdatesTask: Task<Void, Error>?

    fileprivate static let shared = LiveActivityInstance()
    
    fileprivate var models : [LiveActivityModel] = []
    
    fileprivate override init() {
        super.init()
        loadModels()
//        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name:  UIApplication.willResignActiveNotification, object: nil)

    }
    
    fileprivate func checkNickName(nickName:String) -> Bool {
        if nickName == "" { return false }
        if models.count == 0 {
            loadModels()
        }
        return  models.filter{$0.nickName == nickName}.count > 0 ? true:false
    }
    
    @objc private func applicationDidBecomeActive() {
//        print("applicationDidBecomeActive==========")
        synchronizeModels()
//        NotificationCenter.default.removeObserver(self)
    }
    
    private func filePath() -> String {
        return documentsDirectory() + "/Activities.cfg"
    }
    
    fileprivate func documentsDirectory() ->String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
    }
    
    private func loadModels() {
        do {
            let url = URL(filePath: filePath())
            let data = try Data(contentsOf: url)
            
            let classSet = NSSet(objects: NSMutableArray.self,LiveActivityModel.self)
            let localModels : [LiveActivityModel] = try NSKeyedUnarchiver.unarchivedObject(ofClasses: classSet as! Set<AnyHashable>, from: data) as? [LiveActivityModel] ?? []
            print(localModels)
            var models : [LiveActivityModel] = []
            for model  in localModels {
                models.append(model)
            }
            guard models.count > 0 else { return }
            self.models = models
        } catch (let error) {
            print(error)
        }
    
    }
    
    fileprivate func synchronize(activityIDs : [String]) {
        guard activityIDs.count > 0 else {
            if models.count > 0 {
                models = []
                do {
                    try FileManager.default.removeItem(atPath: filePath())
                } catch (let error) {
                    print(error)
                }
            }
            return
        }
        var currentModels :[LiveActivityModel] = []
        activityIDs.forEach { ID in
            currentModels.append(models.filter{$0.ID == ID}.first!)
        }
        models = currentModels
        synchronizeModels()
    }
    
    fileprivate func synchronizeModels() {

        guard  models.count > 0  else { return }

        do {
            let url = URL(filePath: filePath())
            try NSKeyedArchiver.archivedData(withRootObject: models, requiringSecureCoding: false).write(to: url)
        } catch (let error) {
            print(error)
        }

    }
    
    fileprivate func add(_ model : LiveActivityModel) throws {
        guard models.filter({$0.ID == model.ID}).first == nil else {
            throw LiveActivityError.SameObject
        }
        models.append(model)
        synchronizeModels()
    }
    
    fileprivate func delete(activityID : String) {
        models = models.filter{ $0.ID != activityID}
        synchronizeModels()
    }
    
    /// Get ID
    /// - Parameter nickName: nickName description
    /// - Returns: ID
    fileprivate func getID(NickName nickName : String ) -> String {
        return models.filter{ $0.nickName == nickName }.first?.ID ?? ""
    }
    
    
    /// Get LiveActivityToken
    /// - Parameter nickName: nickName description
    /// - Returns: LiveActivityToken
    fileprivate func getToken(NickName nickName : String ) -> String {
        return models.filter{ $0.nickName == nickName }.first?.token ?? ""
    }
    
    
    /// Get LiveActivityToken
    /// - Parameter ID: ID description
    /// - Returns: LiveActivityToken
    fileprivate func getToken(_ ID : String ) -> String {
        return models.filter{ $0.ID == ID }.first?.token ?? ""
    }
    
    fileprivate func addActivityModel<Attributes:ActivityAttributes>(_ activity : Activity<Attributes>,_ nickName : String = "") {
        let element : Data = activity.pushToken ?? Data()
        let tokenStr = element.map{ String(format: "%02.2hhx", $0)}.joined()
        let activityID = activity.id
        let model = LiveActivityModel(ID: activityID, nickName: nickName, token: tokenStr,startTime: Date.now.timestamp())
        do {
            try LiveActivityInstance.shared.add(model)
        } catch (let error) {
            print("\(error.localizedDescription)")
        }
    }
    
    
    fileprivate func addActivityObserver<Attributes:ActivityAttributes>(_ activity : Activity<Attributes>? = nil) {
//        print("添加观察者===================")
        tokenUpdatesTask?.cancel()
        tokenUpdatesTask = Task.detached  {
//            print("测试用============================进入Task")
            // 获取活动列表
            for await activity in Activity<Attributes>.activityUpdates {
//                print("测试用============================进入方法体============")
                let tokenStrSet = NSMutableSet()
                for await tokenData in activity.pushTokenUpdates {
                    let tokenStr = tokenData.map{ String(format: "%02.2hhx", $0)}.joined()
                    if !tokenStrSet.contains(tokenStr) {
                        tokenStrSet.add(tokenStr)
                        print("token:\(tokenStr)")
                        print("liveActivityID:\(activity.id)")
                        // 处理token变化
                        if let nTokenCallBack = self.tokenCallBack {
                            nTokenCallBack(tokenStr)
                        }
                    }
                }
            }
        }
    }
}
 
@objc(LiveActivityModel)
fileprivate class LiveActivityModel : NSObject,NSCoding,NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    var ID          : String = ""
    var nickName    : String = ""
    var token       : String = ""
    var startTime   : String = ""
    override init() {
        super.init()
    }
    
    init(ID: String, nickName: String, token: String, startTime: String) {
        self.ID = ID
        self.nickName = nickName
        self.token = token
        self.startTime = startTime
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.ID as NSString, forKey: "ID")
        coder.encode(self.nickName as NSString, forKey: "nickName")
        coder.encode(self.token as NSString, forKey: "token")
        coder.encode(self.startTime as NSString, forKey: "startTime")
    }
    
    required init?(coder: NSCoder) {
        super.init()
        self.ID = coder.decodeObject(forKey: "ID") as? String ?? ""
        self.nickName = coder.decodeObject(forKey: "nickName") as? String ?? ""
        self.token = coder.decodeObject(forKey: "token") as? String ?? ""
        self.startTime = coder.decodeObject(forKey: "startTime") as? String ?? ""
    }
}


fileprivate extension Date {
    
    func timestamp() -> String {
        return "\(CLongLong(round(self.timeIntervalSince1970*1000)))"
    }
    
    static func timestamp(Timestamp timestamp: String) -> Date {
        let intStamp = (Int(timestamp) ?? 0) / 1000
        let interval : TimeInterval = TimeInterval.init(intStamp)
        return Date(timeIntervalSince1970: interval)
    }
}
