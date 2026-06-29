import Foundation

class Guide {
    let bleModel = ClingBLEModel.sharedInstance()
    
}

extension Guide{
    /// add Bluetooth data callback observer
    func addObservers() {
        
        print("addObservers")
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(syncing(_:)), name: .ClingDeviceDataSyncing, object: nil)
        
        nc.addObserver(self, selector: #selector(receiveMinuteData(_:)), name: .ClingDeviceMinuteDataUpdate, object: nil)
        
        nc.addObserver(self, selector: #selector(registererror(_:)), name: .ClingDeviceRegisterError, object: nil)
        
        nc.addObserver(self, selector: #selector(firmwareUpdateProgress(_:)), name: .ClingDeviceUpgradeFirmwareProgress, object: nil)
        
        nc.addObserver(self, selector: #selector(servicechange(_:)), name: .ClingServiceDidChangeStatus, object: nil)
        
        nc.addObserver(self, selector: #selector(discoverRefresh(_:)), name: .ClingDiscoveryDidRefresh, object: nil)
        
        nc.addObserver(self, selector: #selector(downloadPhoneSetting(_:)), name: .ClingDiscoveryDidRefresh, object: nil)
        
        //        nc.addObserver(self, selector: #selector(connectChange(_:)), name: NSNotification.Name.ClingServiceDidChangeStatus, object: nil)
        
        ///gps data
        nc.addObserver(self, selector: #selector(receiveGpsData(_:)), name: .ClingDeviceGPSDataReceived, object: nil)
        ///gps summary info
        nc.addObserver(self, selector: #selector(receiveGpsSummaryInfo(_:)), name: .ClingDeviceGPSDataSumInfo, object: nil)
        
        /// gps syncing progress
        nc.addObserver(self, selector: #selector(gpsSyncing(_:)), name: .ClingDeviceGPSDataSyncing, object: nil)
    }
    /// remove Bluetooth data callback observer
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension Guide{
    /// (1). scan devices
    func startScanning() {
        print("startDiscoveryDevice")
        /// setup device type(cling ge)
        bleModel?.setClingDeviceStyle(.GE)
        /// start scan
        bleModel?.startDiscoveryDevice()
    }
    /// stop scan devices
    func stopScan() {
        bleModel?.stopDiscoveryDevice()
    }
    
    /// (2). after scan, start register and connect the device we need connect
    @objc func registerDevice() {
        guard let bleModel = bleModel else { return }
        
        if !(bleModel.registerDevice("4BCE", bondUid: 1001, complete: {
            print("device activation successful")
        })) {
            print("device not found")
        }
    }
    func registerAndConnectDevice(deviceID: String) {
        registerDevice()
        connectDevice(deviceID)
    }
    /// (2?). subsequent connections to an already registered device.
    func connectDevice(_ clingid:String) {
        ///Update the user ID bound to the Cling device in the local cache. This method must be used for already bound Cling devices. To establish a connection with a bound device, call this method first, then call `tryConnectDevice`
        ///
        /// passing the new binding ID (`bid`). By default, the local cache stores the user ID as the `bid` provided in the `registerDevice` method. If the Cling device is already activated and the locally cached `bid` differs from the actual user ID bound to the device, the correct user ID must be provided.
        ClingBLEModel.updateBondUid(1001, clingID: clingid)
        
        ClingBLEModel.sharedInstance().tryConnectDevice()
    }
    
    /// (3). load data from device,
    /// Send the command to get device minute data to handle real-time data
    @objc func syncDeviceData(){
        ClingBLEModel.reloadDeviceData()
    }
    
    /// after register the device  you can deregister it
    @objc func deregiestDevice(){
        guard let bleModel = bleModel, bleAvaliable() else { return }
        bleModel.deregisterDevice()
    }
    
    /// setup push types to device
    /// To set up watch push-related information, the user must first listen for the `ClingDeviceInitCfgNotification` notification before manually configuring the device. Upon receiving the callback, call `downloadPhoneSettingFinished` within the callback for the settings to take effect.
    @objc func setPushTypes(){
        guard let bleModel = bleModel, bleAvaliable() else { return }
        bleModel.setPushInfo([CLING_WATCH_NOTIFICATION.ID_INCOMING_CALL,.ID_SOCIAL,.ID_MISSED_CALL,.ID_LOCATION])
    }
    
    /// set reminder to device, if send an empty array to device will remove all reminder, max reminder 32
    /// Set reminders (up to 32 reminders). An empty array will clear all reminders. ClingDeviceReminder
    @objc func setReminder(){
        guard let bleModel = bleModel, bleAvaliable() else { return }
        let reminder = ClingDeviceReminder()
        reminder.intReminderHour = 6;
        reminder.strName = "Create a reminder.";
        bleModel.setDeviceReminderInfo([reminder])
        /// To apply the reminder update to the device, call this method. The alarm will be set on the device immediately; otherwise, it will be configured when the state machine wakes up.
        bleModel.updateDeviceReminderDirectly()
    }
    
    /// setup weather max 5 days
    /// Set the device's weather information (up to today and the next five days) using the ClingDeviceWeather array.
    @objc func deviceSetWeather(){
        guard let bleModel = bleModel, bleAvaliable() else { return }
        let weather = ClingDeviceWeather()
        weather.intWeatherTime = Int32(Date().timeIntervalSince1970);
        weather.fTempHigh = 10;
        weather.fTempLow = -2;
        weather.style = .snowy;
        bleModel.setDeviceWeatherInfo([weather])
    }
    
    ///config device
    @objc func setDeviceConfig(){
        guard let bleModel = bleModel, bleAvaliable() else { return }
        let cfg = ClingDeviceCfg()
        cfg.uint8Hold = 3;
//        cfg.bTouchEnable = true
        cfg.bIdleAlert = true;
        bleModel.setDeviceCfg(cfg)
    }
    /// setup device language,
    @objc func setDeviceLanguage(){
        guard let bleModel = bleModel, bleAvaliable() else { return }
        bleModel.setDeviceLanguage(.english)
    }
    
    /// disconnect device, if change another device, you need call disconnectDevice first
    @objc func deviceDisconnect(){
        guard let bleModel = bleModel, bleAvaliable() else { return }
        bleModel.disconnectDevice(true)
    }
    /// check update  device firmware
    @objc func deviceCheckFirmwareUpdate(){
        guard let http = HttpModel.sharedInstance() else { return }
        guard let bleModel = bleModel, bleAvaliable() else { return }
        ///获取当前设备的最新版本信息(Get the latest version information of the current device.)
        http.checkEnterpriseFirmwareUpdateRequest({
            print("\(String(describing: $1))")
            if let currentversion = bleModel.getDeviceInfo()["softwareVersion"] as? String{
                ///判断设备是否需要升级(Determine whether the device needs an upgrade.)
                if ClingBLEModel.compareFirmwareVersion(withTarget: $0, current: currentversion){
                    ///需要升级, has new version update
                    bleModel.upgradeFirmware(with: nil, complete: {
                        ///升级检验正常(Verification passed)
                        if $0?.isEmpty == true{
                            print("Verification passed")
                        }else{
                            print("Verification failed: \(String(describing: $0))")
                        }
                    })
                }
            }
        }, failure: {
            print("check update failed: \($0 ?? "")")
        })
    }
    
    /// setup the custom user info to device
    @objc func deviceUpdateUserProfile(){
        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
        let model = ClingPeripheralUserProfileModel()
        model.touch_virbration = PERIPHERAL_PROFILE_TOUCH_VIRBRATION_ON;
        // When changing a specific attribute, all other attributes must be reassigned with their previous values.
        model.height_in_cm = 170;
        model.weight_in_kg = 65;
        model.stride_length_in_cm = 135;
        model.stride_length_run_in_cm = 122;
        model.stepRateForRunLength = 172;
        model.units_type = 0;
        model.nickname = "Cling Pace";
        model.clock_orientation = PERIPHERAL_PROFILE_CLOCK_ORIENTATION_VERTICAL;
        model.sleep_alarm_day_of_week = Int32(CLING_DEVICE_REMINDER_WEEKDAY.ALL.rawValue);
        model.bed_hr = 11;
        model.bed_min = 20;
        model.wakeup_hr = 7;
        model.wakeup_min = 40;
        
//        #define PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_DEFAULT_VALUE ( PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_STEP | PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_HEART_RATE | PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_START_RUNNING | PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_SKIN_TEMP | PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_UV )           // 0xD11  default show
        
//      model.screen_display_option = PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_DEFAULT_VALUE;
        model.screen_display_option = 0xD11;
        model.daily_goal = 5;
        model.training_display_option = PERIPHERAL_PROFILE_TRAINING_DISPLAY_OPTION_DEFAULT_VALUE;
        model.age = 30;
        model.sex = 0;
        model.stride_length_run_indoor_in_cm = 100;
        model.hr_alarm_rate = PERIPHERAL_PROFILE_HEART_ALARM_DEFAULT_VALUE;
        model.pace_alarm_zone = PERIPHERAL_PROFILE_PACE_ALARM_DEFAULT_VALUE;
        model.iTempAlarmValue = 373; // 37.3 * 10
        model.iTempLowAlarmValue = 280; // 28.8 * 10;
        share.updateUserProfile(model)
    }
    
    ///check bluetooth state
    func bleAvaliable() -> Bool{
        guard let bleModel = bleModel else { return false }
        guard bleModel.getPhoneBLEState() != .poweredOn else {return true}
        print("Bluetooth is abnormal, please check the Bluetooth status.");
        return false
    }
}

extension Guide{
    /// bluetooth syncing data progress, @{@"total":xx,@"current":xx}
    @objc func syncing(_ notifacation: Notification){
        print(#function)
        print("syncing\(notifacation.object ?? "")")
    }
    /// receive minute data from device
    @objc func receiveMinuteData(_ notifacation: Notification){
        print(#function)
        if let mimute = notifacation.object as? ClingMinuteData{
            print("recive minute data=\(mimute.intTimestamp)---\(mimute.shortHeartRate)")
        }
    }
    @objc func registererror(_ notifacation: Notification){
        print(#function)
        print("register failed \(String(describing: notifacation.object))")
    }
    /// blutooth connect state change notification
    @objc func servicechange(_ notifacation: Notification){
        print(#function)
        guard ClingBLEModel.isDConnected() else { return }
        
        guard let bleModel = bleModel else { return  }
        print("service connect state changed\(notifacation.object ?? -1),\(bleModel.getPhoneBLEState())")
        let info = bleModel.getDeviceInfo()
        if info?.isEmpty == false {
            if let cid = info?["clingID"] {
                print("clingid: \(cid)")
                UserDefaults.standard.setValue(cid, forKey: "clingid")
            }else{
                UserDefaults.standard.removeObject(forKey: "clingid")
            }
            UserDefaults.standard.synchronize()
        }
    }
    /// device discovery refresh notification
    @objc func discoverRefresh(_ notifacation: Notification){
        print(#function)
        print("Device found:\(notifacation.object ?? "")")
        if let result = notifacation.object as? [ClingDeviceDiscoveryModel] {
            result.forEach({
                print("peripheral.name: \($0.peripheral.name ?? "--")")
            })
        }
    }
//    @objc func connectChange(_ notifacation: Notification){
//        print(notifacation)
//    }
    
    /// firmware update callback notification {"progress":xx}  【range 0-1】
    @objc func firmwareUpdateProgress(_ noti: Notification){
        if let dic = noti.object as? [String:Any] {
            let progress = dic["progress"];
            print("Current upgrade progress.：\(progress ?? 0)");
        }
    }
    
    /// bluetooth settings setup finished
    /// In this notification, write all original configurations to the device. When the device connects or reconnects, it needs to be reconfigured to ensure the original settings are valid, such as weather settings, reminder settings, etc. After configuring, please call downloadPhoneSettingFinished. This method must be called; otherwise, it may result in failure to configure the device later.
    @objc func downloadPhoneSetting(_ notifacation: Notification){
        print(#function)
        print(notifacation)
        ClingBLEModel.sharedInstance().downloadPhoneSettingFinished()
    }
    
    ///gps data  notification, activity data
    @objc func receiveGpsData(_ noti: Notification){
        if let dic = noti.object as? [String:Any] {
            print("recive gps data(activity data): \(dic)")
        }
    }
    ///gps sum info
    @objc func receiveGpsSummaryInfo(_ noti: Notification){
        if let dic = noti.object as? [String:Any] {
            print("recive gps sum: \(dic)")
        }
    }
    /// gps syncing data progress, @{@"total":xx,@"current":xx}
    @objc func gpsSyncing(_ notifacation: Notification){
        print(#function)
        print("gps syncing\(notifacation.object ?? "")")
    }
}
