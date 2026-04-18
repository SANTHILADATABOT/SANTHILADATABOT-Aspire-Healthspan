
import UIKit
//import Toast

class ViewController: UIViewController {
    ///Cling server request instance
    let http = HttpModel.sharedInstance()
    
    @IBOutlet weak var tableView: UITableView!
    
    var binded = false
    
    lazy var groups = [
                        [Actions(name: "Scan Device 1", sel: #selector(actionScanDevice), enable: { !self.binded }),
                         Actions(name: "Register Device 2", sel: #selector(actionRegisterDevice), enable: { !self.binded }),
                         Actions(name: "deRegister Device", sel: #selector(actionDeregiestDevice), enable: { self.binded }),
                         Actions(name: "Device Connect 3", sel: #selector(activeLastDevice), enable: { !self.binded }),
                         Actions(name: "Device Disconnect", sel: #selector(actionDeviceDisconnect), enable: { self.binded }),
                         ],
                       
                        [Actions(name: "Device Data Load", sel: #selector(actionSyncDeviceData), enable: { self.binded }),
                         Actions(name: "Device Push Set", sel: #selector(actionSetPushTypes), enable: { self.binded }),
                         Actions(name: "Device Reminder Set", sel: #selector(actionSetReminder), enable: { self.binded }),
                         Actions(name: "Device Weather Set", sel: #selector(actionDeviceSetWeather), enable: { self.binded }),
                         Actions(name: "Device Config", sel: #selector(actionSetDeviceConfig), enable: { self.binded }),
                         Actions(name: "Device Language", sel: #selector(actionSetDeviceLanguage), enable: { self.binded }),
                         Actions(name: "Device Firmware Update Check", sel: #selector(actionDeviceCheckFirmwareUpdate), enable: { self.binded }),
                         Actions(name: "Device Update User Profile", sel: #selector(actionDeviceUpdateUserProfile), enable: { self.binded }),
                         Actions(name: "Blood Pressure calibration", sel: #selector(actionBloodPressureCalibration), enable: { self.binded })
                           ]
                        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        registerCling()
        
        addClingObserver()
        
        reloadState(false)
        activeLastDevice()
        // Do any additional setup after loading the view.
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ViewController{
    ///register cling sdk
    func registerCling() {
        HttpModel.sharedInstance().registerClingAppid(CLING_SDK_APPID, withAppSecret: CLING_SDK_APPSECRET, enterprise: true)
        /// ublox token from https://portal.thingstream.io, https://portal.thingstream.io/app/location-services/things
//        ClingBLEModel.sharedInstance().setupUbloxToken("token")
    }
    ///add callback observers of sdkactionSetPushTypes
    func addClingObserver() {
        let nc = NotificationCenter.default;
        nc.addObserver(self, selector: #selector(bleSyncingData(_:)), name: .ClingDeviceDataSyncing, object: nil)
        
        nc.addObserver(self, selector: #selector(bleReceiveMinuteData(_:)), name: .ClingDeviceMinuteDataUpdate, object: nil)
        nc.addObserver(self, selector: #selector(bleRegisterError(_:)), name: .ClingDeviceRegisterError, object: nil)
        nc.addObserver(self, selector: #selector(bleConnectDidChange(_:)), name: .ClingServiceDidChangeStatus, object: nil)
        nc.addObserver(self, selector: #selector(bleDiscoverRefresh(_:)), name: .ClingDiscoveryDidRefresh, object: nil)
        
        nc.addObserver(self, selector: #selector(bleDownloadPhoneSettings(_:)), name: .ClingDeviceInitCfg, object: nil)
        
        nc.addObserver(self, selector: #selector(bleFirmwareUpdateProgress(_:)), name: .ClingDeviceUpgradeFirmwareProgress, object: nil)
        ///gps data
        nc.addObserver(self, selector: #selector(bleReceiveGpsData(_:)), name: .ClingDeviceGPSDataReceived, object: nil)
        ///gps summary info
        nc.addObserver(self, selector: #selector(bleReceiveGpsSummaryInfo(_:)), name: .ClingDeviceGPSDataSumInfo, object: nil)
        
        /// gps syncing progress
        nc.addObserver(self, selector: #selector(gpsSyncing(_:)), name: .ClingDeviceGPSDataSyncing, object: nil)
        
        /// cling daily total data
        nc.addObserver(self, selector: #selector(reciveDailyTotal(_:)), name: .ClingDeviceDayTotal, object: nil)
        
        /// recive SOS message (The specified device is valid)
//        nc.addObserver(self, selector: #selector(reciveSosMessage), name: .ClingDeviceSendSOS, object: nil)
        
        /// recive find phone message
        nc.addObserver(self, selector: #selector(reciveFindMessage), name: .ClingDeviceSendFinder, object: nil)
    }
}

extension ViewController{

    ///Connect last register device
    ///连接已经激活注册的设备
    @objc func activeLastDevice() {
        if let cid = UserDefaults.standard.string(forKey: "clingid") {
            connectDevice(cid)
        }
    }
}

extension ViewController{
    ///通过设备蓝牙码激活设备。使用此方法时，请确保需要激活的四位蓝牙码对应的peripheral已经被搜索到,方法内部会自动关闭蓝牙扫描，在激活过程中，获取到complete结果前，请勿调用stopDiscoveryDevice方法来寻求关闭蓝牙扫描，否则会造成内部初始化，产生无法获取到complete结果等问题
    ///connect device
    func connectDevice(_ clingid:String) {
        ///更新本地缓存中与cling device绑定的user id   已绑定cling device需要使用该方法。 如需与已绑定设备建立连接，调用该方法后，再调用tryConnectDevice方法
        ///bid 新的绑定id.  默认本地缓存的user id为registerDevice方法传入的bid,如cling device已经激活，本地缓存的bid与设备真实绑定的user id不一致，需要将设备绑定的userid传入.
        ClingBLEModel.updateBondUid(1001, clingID: clingid)
        
        ClingBLEModel.sharedInstance().tryConnectDevice()
    }
    ///检测蓝牙状态
    ///check bluetooth state
    func bleAvaliable() -> Bool{
        guard let share = ClingBLEModel.sharedInstance() else { return false }
        guard share.getPhoneBLEState() != .poweredOn else {return true}
        print("蓝牙异常，请检查蓝牙状态(Bluetooth is abnormal, please check the Bluetooth status.)");
        return false
    }
}

///notification callback
extension ViewController{
    /// device register error notification
    /// 手表与账号绑定错误通知  object中返回NSString类型的错误信息
    @objc func bleRegisterError(_ noti: Notification){
        print("激活失败(register failed)\(String(describing: noti.object))")
    }
    ///blutooth connect state change notification
    ///设备连接状态改变，已连接"1"或未连接"0"
    @objc func bleConnectDidChange(_ noti: Notification){
        let connected = ClingBLEModel.isDConnected()
        print("设备连接状态改变(service connect state changed)\(noti.object ?? -1),\(ClingBLEModel.sharedInstance().getPhoneBLEState())")
        let info = ClingBLEModel.sharedInstance().getDeviceInfo()
        if info?.isEmpty == false {
            if let cid = info?["clingID"] {
                print("clingid: \(cid)")
                UserDefaults.standard.setValue(cid, forKey: "clingid")
            }else{
                UserDefaults.standard.removeObject(forKey: "clingid")
            }
            UserDefaults.standard.synchronize()
        }
        //refresh cell state
        reloadState(connected)
    }
    /// device discovery refresh notification
    /// 发现设备  返回CBPeripheral数组
    @objc func bleDiscoverRefresh(_ noti: Notification){
        print("发现设备(Device found):\(noti.object ?? "")")
        if let result = noti.object as? [ClingDeviceDiscoveryModel] {
            result.forEach({
                print("peripheral.name: \($0.peripheral.name ?? "--")")
            })
        }
        
    }
    /// bluetooth settings setup finished
    /// 在本通知中将原所有配置写入device，当device连接或重连，需要对device重新配置，以保证原配置有效。如：天气配置、提醒配置等。  设置后，请再调用downloadPhoneSettingFinished,此方法一定要写，否则会造成后期配置设备失败的情况
    @objc func bleDownloadPhoneSettings(_ noti: Notification){
            actionSetDeviceConfig()
            actionDeviceUpdateUserProfile()
            actionSetDeviceLanguage()
        ClingBLEModel.sharedInstance().downloadPhoneSettingFinished()
    }
    /// bluetooth syncing data
    /// 正在同步数据进度通知  @{@"total":xx,@"current":xx}
    @objc func bleSyncingData(_ noti: Notification){
        print("同步中(syncing)\(noti.object ?? "")")
    }
    ///receive minute data from device
    ///设备获取到分钟数据数据  ClingMinuteData类型
    @objc func bleReceiveMinuteData(_ noti: Notification){
        
        if let mimute = noti.object as? ClingMinuteData{
            print("接收到分钟数据通知(recive minute data)=\(mimute.intTimestamp)---\(mimute.shortHeartRate)")
        }
    }
    ///firmware update callback notification
    ///升级固件进度通知  {"progress":xx}  【range 0-1】
    @objc func bleFirmwareUpdateProgress(_ noti: Notification){
        if let dic = noti.object as? [String:Any] {ClingBLEModel.reloadDeviceData()
            let progress = dic["progress"];
            print("当前升级进度(Current upgrade progress.)：\(progress ?? 0)");
        }
    }
    
    ///gps data  notification, activity data
    ///GPS数据同步通知
    @objc func bleReceiveGpsData(_ noti: Notification){
        if let dic = noti.object as? [String:Any] {
            print("recive gps data(activity data): \(dic)")
        }
    }
    ///gps sum info
    ///GPS数据总和通知
    @objc func bleReceiveGpsSummaryInfo(_ noti: Notification){
        if let dic = noti.object as? [String:Any] {
            print("recive gps sum: \(dic)")
        }
    }
    
    /// gps syncing data progress, @{@"total":xx,@"current":xx}
    @objc func gpsSyncing(_ notifacation: Notification){
        print("gps syncing\(notifacation.object ?? "")")
    }
    /// recive daily total data from device
    @objc func reciveDailyTotal(_ notifacation: Notification){
        guard let daily = notifacation.object as? ClingDailyData else { return }
        print("daily total summary data:")
#warning("Before obtaining and using blood pressure data")
//You need to call ClingBLEModel.sendBPCMessage(intHightVal, lowPressure: intLowVal) first to calibrate blood pressure
        print("Systolic Blood Pressure: \(daily.iBPHigh)")
        print("Diastolic Blood Pressure: \(daily.iBPLow)")
        
        print("total sleep seconds: \(daily.sleepTotal)")
        
        print("walk steps: \(daily.wstepTotal), run steps: \(daily.rstepTotal), total steps: \(daily.stepTotal)")
        
        print("total calories: \(daily.caloriesTotal)")
        
        print("distance: \(daily.distanceTotal)")
        
        print("heart rate: \(daily.heartRate)")
        
    }
    
    @objc func reciveSosMessage(){
        print("recive sos message")
    }
    
    /// recive find my phone message from device
    @objc func reciveFindMessage(){
        print("recive find phone message")
    }
}

extension ViewController{
    ///refresh view state
    func reloadState(_ binded: Bool) {
        self.binded = binded
        tableView.reloadData()
    }
    func caculateSleep() {
        // munuteDatas: Generally speaking, minuteDatas igetMiddleTimestamps the data from 12:00 am the previous day to 12:00 am today. You can modify the time according to your own situation.
        let minuteDatas = [] as [ClingMinuteData] //minutes data load from local or server
        // Call algorithm to generate sleep state
        // shortSleepState: 0 - Default, 1 - Awake, 2 - Light Sleep, 3 - Deep Sleep， 4:mid
        /**
         * @brief  checkSleepState（_, isHR） Identifies sleep states based on minute-level data.
         * @param minuteDatas Minute-level data for an entire day (12:00 PM to 11:59 AM of the next day).
         *                    If the data is incomplete, it covers 12:00 PM to the current time.
         * @param isHR Indicates whether the current device supports heart rate monitoring.
         *
         * @note The following properties in ClingMinuteData objects may be used for sleep state calculation:
         *       intTimestamp, shortWalkStep, shortRunStep, shortDistance, shortHeartRate, and activityData.
         *       Ensure these values are valid.
         *       If this method is not called, non-enterprise version minute data will not be saved on the server.
         */
        ClingUtilsModel.checkSleepState(minuteDatas, isHR: true)
        
        classfiedSleep()
    }
    func classfiedSleep(){
        // 分钟数据接收到可以在本地保存一份用于计算睡眠数据
        // The minute data is received and a copy can be saved locally for calculating sleep data
        
        // munuteDatas: Generally speaking, minuteDatas is the data from 12:00 am the previous day to 12:00 am today. You can modify the time according to your own situation.
        let minuteDatas = [] as [ClingMinuteData] //minutes data load from local or server
        let age = 30 as Int32
        
        // Get the sleep model array: [SleepModel]
        if let sleepModels = SleepUtil.getClassfiedSleepState(minuteDatas) as? [SleepModel]{
            sleepModels.forEach({
                print("sleep state: \($0.mnSleepState)")
            })
            // Get Sleep circles: [SleepCycle]
            if let sleepCircles = SleepUtil.getClassfiedSleepCycle(sleepModels, age: age) {
                SleepUtil.calculateSportParamsAvg(sleepCircles, minuteData: minuteDatas)
            }
        }
    }
}


extension ViewController: UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int { groups.count }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let action = groups[indexPath.section][indexPath.row]
        if action.enable() { self.perform(action.sel) }
    }
}
extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textColor = .red
        label.backgroundColor = .black.withAlphaComponent(0.2)
        if section == 0 {
            label.text = "  Device Scan, Register, Connect, Disconnect"
        }else if section == 1{
            label.text = "  Device functions, need connect first"
        }
        return label
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 44 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { groups[section].count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let action                = groups[indexPath.section][indexPath.row]
        cell.textLabel?.text      = action.name
        cell.textLabel?.textColor = action.color
        return cell
    }
}







