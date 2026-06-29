////
////  PersonalActions.swift
////  ClingDemo
////
////  Created by zhusanbao on 2024/8/21.
////
//
//import Foundation
//
//extension ViewController{
//    @objc func actionLoginClingAccount() {
//        guard let http = http else { return }
//        let login = LoginRequestModel()
//        login.strUsername = "17602186682"
//        login.strPassword = "zz111111"
//        login.strType     = "login"
//        
//        http.login(withRequest: login, success: {[weak self] in
//            guard let `self` = self else { return }
//            self.loginSuccess($0)
//            self.getClingServerSportBubble()
//            self.getClingServerDaytotal()
//            self.getClingServerHealthInfo()
//            self.getClingServerHealthEvalution()
//        }, failure: {
//            print("login failed: \(String(describing: $0))")
//        })
//    }
//    ///set userinfo from server
//    ///设置用户信息
//    @objc func actionSetUserInfo(){
//        guard let http = http else { return }
//        let userinfo = ClingUserInfo();
//        userinfo.strNickname = "nickname";
//        userinfo.strProvince = "Shanghai";
//        userinfo.strSignature = "signature";
//        http.setUserInfoRequest(userinfo, success: {
//            print("设置用户资料成功(User profile set successfully.):\(String(describing: $0))")
//        }, failure: {
//            print("设置用户资料失败(User profile set failed.):\($0 ?? "")")
//        })
//    }
//    
//    ///get userinfo from server
//    ///获取用户信息
//    @objc func actionGetUserInfo(){
//        guard let http = http else { return }
//        http.getUserInfoRequest({
//            print("获取用户信息成功(User information retrieval successful.):\(String(describing: $0))")
//        }, failure: {
//            print("获取用户信息失败(User information retrieval failed.):\($0 ?? "")")
//        })
//    }
//    /// get minute data, callback with [ClingMinuteData] response
//    ///获取分钟数据接口，成功返回ClingMinuteData数组
//    @objc func actionGetDataFromServer(){
//        guard let http = http else { return }
//        let minute = MinuteDataRequestModel();
//        let ts = Int(Date().timeIntervalSince1970);
//        minute.strStartTime = "\(ts - 3600)";
//        minute.strEndTime = "\(ts)";
//        http.minuteData(withRequest: minute, success: {
//            print("获取分钟数据成功(Minute data retrieval successful.):\(String(describing: $0))")
//        }, failure: {
//            print("获取分钟数据失败(Minute data retrieval failed.):\($0 ?? "")")
//        })
//    }
//    /// logout
//    /// 注销接口
//    @objc func actionLogout(){
//        guard let http = http else { return }
//        http.logoutRequest({
//            print("注销登录成功(Logout successful.):\(String(describing: $0))")
//        }, failure: {
//            print("注销登录失败(Logout failed.):\($0 ?? "")")
//        })
//    }
//}
//
/////data from Cling server，that account login from cling account
//extension ViewController{
//    /// get sport bubble data from cling server
//    func getClingServerSportBubble() {
//        guard let http = http else { return }
//        let now = Int32(Date().timeIntervalSince1970)
//        http.getSportBubbleRequest(now-4320, endtime: now, success: {
//            print("获取服务器运动bubble结果(Obtained server motion bubble result.):\(String(describing: $0))")
//        }, failure: {
//            print("获取运动bubble失败结果(Obtained server motion bubble failed.):\(String(describing: $0))")
//        })
//    }
//    
//    /// get daytotal data from cling server
//    func getClingServerDaytotal() {
//        guard let http = http else { return }
//        let now = Int32(Date().timeIntervalSince1970)
//        http.getDaytotalRequest(now - 86400, endtime: now, success: {
//            print("获取服务器天数据结果(Obtained server daily data result.):\(String(describing: $0))")
//        }, failure: {
//            print("获取天数据失败结果(Obtained server daily data result failed.):\(String(describing: $0))")
//        })
//    }
//    /// get health info from cling server
//    func getClingServerHealthInfo() {
//        guard let http = http else { return }
//        http.getHealthIndexesRequest(1, success: {
//            print("获取健康指数结果(Obtained health index result.):\(String(describing: $0))")
//        }, failure: {
//            print("获取健康指数结果(Obtained health index result failed.):\(String(describing: $0))")
//        })
//    }
//    /// get heath evalution
//    func getClingServerHealthEvalution() {
//        guard let http = http else { return }
//        http.getHealthEvalutionScoreRequest({
//            print("获取健康评估分数结果(Obtained health assessment score result.):\($0)")
//        }, failure: {
//            print("获取健康评估分数结果(Obtained health assessment score result failed.):\(String(describing: $0))")
//        })
//    }
//    
//    //生成运动bubble
//    func generateBubbleData(_ data: [ClingMinuteData]) {
//        let list = ClingUtilsModel.sharedInstance().generateSportBubble(data)
//        if(list?.isEmpty == false){
//            guard let http = http else { return }
//            http.uploadSportsRequest(list, success: {
//                print("上传运动bubble结果(Uploaded motion bubble result.):\(String(describing: $0))")
//            }, failure: {
//                print("上传运动bubble失败结果(Uploaded motion bubble failed.):\($0 ?? "")")
//            })
//        }
//    }
//    func loginSuccess(_ result: [AnyHashable : Any]?) {
//        reloadState((result?["isbind"] as? Bool) ?? false)
//    }
//}
