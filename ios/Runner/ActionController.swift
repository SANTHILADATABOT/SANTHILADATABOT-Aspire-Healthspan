
import Foundation

extension ViewController{
    /// start scan device
    /// 开始搜索设备
    @objc func actionScanDevice(){
        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(actionRegisterDevice), object: nil)
        ///确定将要注册的设备类型，若实际注册设备类型与设置不一致，将造成注册失败
        ///(Ensure the Device Type to be Registered,If the actual registered device type does not match the set type, the registration will fail.)
        share.setClingDeviceStyle(.GE)
        //开始查找设备，成功查找到设备后，激活才能顺利进行
        share.startDiscoveryDevice();
        
        //demo给予10秒的蓝牙扫描时间，之后开始尝试连接。如没扫描到，请点击重试
        perform(#selector(actionRegisterDevice), with: nil, afterDelay: 10)
    }
    
    ///after scan, start register the device we need connect
    @objc func actionRegisterDevice() {
        if !(ClingBLEModel.sharedInstance().registerDevice("F5DE", bondUid: 1001, complete: {[weak self] in
            print("激活设备成功(device activation successful)")
            self?.reloadState(true)
        })) {
            print("device not found")
        }
    }
    /// deregister device
    /// 反激活手表
    @objc func actionDeregiestDevice(){
        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
        share.deregisterDevice()
        reloadState(false)
    }
    ///load data from device,
    ///发送获取device分钟数据命令，用于处理实时性问题
    @objc func actionSyncDeviceData(){
        ClingBLEModel.reloadDeviceData()
    }
    ///setup push types to device
    ///设置手表推送相关信息, 用户手动对设备进行设置前，先对ClingDeviceInitCfgNotification通知进行监听，接收到回调并在回调里调用downloadPhoneSettingFinished后，设置才能生效
    @objc func actionSetPushTypes(){
        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
        share.setPushInfo([CLING_WATCH_NOTIFICATION.ID_INCOMING_CALL,.ID_SOCIAL,.ID_MISSED_CALL,.ID_LOCATION])
    }
    ///set reminder to device, if send an empty array to device will remove all reminder, max reminder 32
    ///设置提醒(最多32个提醒)  空数组则清空提醒 ClingDeviceReminder
    @objc func actionSetReminder(){
        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
        let reminder = ClingDeviceReminder()
        reminder.intReminderHour = 6;
        reminder.strName = "创建提醒(Create a reminder.)";
        share.setDeviceReminderInfo([reminder])
        //执行reminder更新到设备 调用本方法，闹钟会马上设置于设备上。否则将等待statemachine唤醒后配置
        share.updateDeviceReminderDirectly()
    }
    ///setup weather max 5 days
    ///设置设备天气信息（最多设置今天到未来5天内） ClingDeviceWeather数组
    @objc func actionDeviceSetWeather(){
        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
        let weather = ClingDeviceWeather()
        weather.intWeatherTime = Int32(Date().timeIntervalSince1970);
        weather.fTempHigh = 10;
        weather.fTempLow = -2;
        weather.style = .snowy;
        share.setDeviceWeatherInfo([weather])
    }
    ///config device
    ///配置设备
    @objc func actionSetDeviceConfig(){
        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
        let cfg = ClingDeviceCfg()
        cfg.uint8Hold = 3;
        cfg.bTouchEnable = true
        cfg.bIdleAlert = true;
        share.setDeviceCfg(cfg)
    }
    ///setup device language,
    ///设置设备语言(watch之外的设备支持语言设置)
    @objc func actionSetDeviceLanguage(){
        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
        share.setDeviceLanguage(.english)
    }
    
    ///disconnect device, if change another device, you need call disconnectDevice first
    ///已经连接后,设备断开连接. 切换账号或更换设备连接行为，请先调用此方法断开当前连接。
    @objc func actionDeviceDisconnect(){
        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
        share.disconnectDevice(true)
    }
    ///检查更新设备固件
    ///check update  device firmware
    @objc func actionDeviceCheckFirmwareUpdate(){
        guard let http = http else { return }
        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
        ///获取当前设备的最新版本信息
        http.checkEnterpriseFirmwareUpdateRequest({
            print("\(String(describing: $1))")
            if let currentversion = share.getDeviceInfo()["softwareVersion"] as? String{
                ///判断设备是否需要升级
                if ClingBLEModel.compareFirmwareVersion(withTarget: $0, current: currentversion){
                    ///需要升级, has new version update
                    share.upgradeFirmware(with: nil, complete: {
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
    ///setup the people's user info to device
    @objc func actionDeviceUpdateUserProfile(){
        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
        let model = ClingPeripheralUserProfileModel()
        model.touch_virbration = PERIPHERAL_PROFILE_TOUCH_VIRBRATION_OFF;
        // 改变某一个属性，其余属性要全部重新赋值（上次的值）
        model.height_in_cm = 170;
        model.weight_in_kg = 65;
        model.stride_length_in_cm = 75;
        model.stride_length_run_in_cm = 107;
        model.stepRateForRunLength = 172;
        model.units_type = 0;
        model.nickname = "Cling";
        model.clock_orientation = PERIPHERAL_PROFILE_CLOCK_ORIENTATION_VERTICAL;
        model.sleep_alarm_day_of_week = Int32(CLING_DEVICE_REMINDER_WEEKDAY.ALL.rawValue);
        model.bed_hr = 18;
        model.bed_min = 20;
        model.wakeup_hr = 7;
        model.wakeup_min = 40;
        

        // Ensure blood pressure display is enabled for automatic measurement
        model.screen_display_option = Int32(SCREEN_DISPLAY_OPTION.defaultValue.rawValue) | Int32(SCREEN_DISPLAY_OPTION.bloodPressure.rawValue);
        model.daily_goal = 0;
        model.training_display_option = PERIPHERAL_PROFILE_TRAINING_DISPLAY_OPTION_DEFAULT_VALUE;
        model.age = 30;
        model.sex = 0;
        model.stride_length_run_indoor_in_cm = 150;
        model.hr_alarm_rate = PERIPHERAL_PROFILE_HEART_ALARM_DEFAULT_VALUE;
        model.pace_alarm_zone = PERIPHERAL_PROFILE_PACE_ALARM_DEFAULT_VALUE;
//        print("\(model.screen_display_option),\(model.sleep_alarm_day_of_week),\(model.hr_alarm_rate),\(model.pace_alarm_zone)")
        model.iTempAlarmValue = 373 // 37.3 * 10
        model.iTempLowAlarmValue = 280 // 28.8 * 10;
        model.caloryDisplayType = 1
        model.iHealthInfoLevel = 0
        model.bStepAlarm = true
        model.iSAlarmValue = 13000
        model.bCalAlarm = true
        model.iCAlarmValue = 2300
        share.updateUserProfile(model)
        print("setup user profile")
    }
    
    ///setup the people's user info to device
    @objc func actionBloodPressureCalibration(){
        guard let _ = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
        ClingBLEModel.sendBPCMessage(130, lowPressure: 80)
    }
}
