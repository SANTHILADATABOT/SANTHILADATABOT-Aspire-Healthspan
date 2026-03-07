package com.eugene.aspire;

import androidx.annotation.NonNull;

import android.os.Bundle;
import android.util.Log;
import android.os.Handler;
import android.os.Looper;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import com.hicling.clingsdk.ClingSdk;
import com.hicling.clingsdk.listener.OnBleListener;
import com.hicling.clingsdk.listener.OnNetworkListener;
import com.hicling.clingsdk.model.DayTotalDataModel;
import android.content.Context;
import android.content.IntentFilter;
import android.os.Build;
import java.util.Date; // <-- Add this
import java.text.SimpleDateFormat; // <-- Add this
import java.util.TimeZone; // <-- Add this
import com.hicling.clingsdk.model.MinuteData;
import com.hicling.clingsdk.model.DeviceConfiguration;
import com.hicling.clingsdk.devicemodel.PERIPHERAL_DEVICE_INFO_CONTEXT;
import android.bluetooth.BluetoothDevice;
import java.lang.reflect.Method;
import com.hicling.clingsdk.bleservice.BluetoothDeviceInfo;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.pm.PackageManager;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;
import android.Manifest;

public class MainActivity extends FlutterActivity {
    private static final String TAG = "ClingSDK";
    private static final String METHOD_CHANNEL = "cling/methods";
    private static final String SCAN_CHANNEL = "cling/scan";
    private static final String MINUTE_CHANNEL = "cling/minute_data";
    //private static final String DAILY_CHANNEL = "cling/daily_total";
    private static final String DAILY_CHANNEL = "cling/daily_total";
    private static final String SYNC_STATUS_CHANNEL = "cling/sync_status";
    private static final int USER_ID = 876355;
    //private MethodChannel dailyMethodChannel;
    private boolean mbDeviceConnected = false;
    public static MethodChannel methodChannel;
    //public static boolean isSdkReady = false;
    private String pendingClingId = null;
    private boolean isTransportConnected = false;
    private final OnBleListener.OnDeviceConnectedListener deviceListener =
            new OnBleListener.OnDeviceConnectedListener() {
                @Override
                public void onDeviceConnected() {

                    Log.i(TAG, "✅ BLE transport connected");
                    mbDeviceConnected = true;

                    new Handler(Looper.getMainLooper()).postDelayed(() -> {

                        Log.i(TAG, "🔐 Secure channel ready, notifying Flutter");

                        ClingSdk.setPeripheralLanguage(
                                ClingSdk.CLING_DEVICE_LANGUAGE_TYPE_EN
                        );

                        // 🔥 NOW notify Flutter
                        ClingBleManager.notifyPaired(
                                ClingSdk.getBondClingDeviceName()
                        );

                    }, 1500); // 1.5 sec is safer
                }
                @Override
                public void onDeviceDisconnected() {
                    Log.i(TAG, "❌Device Disconnected");
                    mbDeviceConnected = false;
                }
                @Override
                public void onDeviceInfoReceived(Object o) {
                    PERIPHERAL_DEVICE_INFO_CONTEXT info =
                            (PERIPHERAL_DEVICE_INFO_CONTEXT) o;
                    String clingId = info.clingId;
                    Log.i(TAG, "🔥DeviceInfo received → clingId=" + clingId);
                    if (clingId != null && !clingId.isEmpty()) {
                        // ✅ SAVE CLING ID LOCALLY
                        getSharedPreferences("CLING_PREF", MODE_PRIVATE)
                                .edit()
                                .putString("CLING_ID", clingId)
                                .apply();
                        Log.i(TAG, "💾 ClingId saved in SharedPreferences="+clingId);
                        new Handler(Looper.getMainLooper()).postDelayed(() -> {
                            ClingSdk.connectDeviceByClingid(USER_ID, clingId);
                        }, 1200);
                    }
                }
            };
    // ---------------- BLE DATA LISTENER ----------------
    private void safeRegisterReceiver(IntentFilter filter) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(
                    null,
                    filter,
                    Context.RECEIVER_NOT_EXPORTED
            );
        } else {
            registerReceiver(null, filter);
        }
    }
    private final OnBleListener.OnBleDataListener bleDataListener =
            new OnBleListener.OnBleDataListener() {
                @Override
                public void onDataSyncingMinuteData(Object o) {
                    if (!(o instanceof MinuteData)) return;
                    MinuteData data = (MinuteData) o;
                    long intTimestamp = data.getMinuteTimeStamp();
                    Date date = new Date(intTimestamp * 1000L);
                    SimpleDateFormat sdf =
                            new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.US);
                    sdf.setTimeZone(TimeZone.getTimeZone("Asia/Kolkata"));
                    String formattedIST = sdf.format(date);
                    int wSteps = data.getwSteps();
                    int rSteps = data.getrSteps();
                    int sleepSecond = data.getSleepSecond();
                    int sleepState = data.getSleepState();
                    int heartRate = data.getHeartRate();
                    int isWear = data.getIsWear();
                    int spo2 = data.getSpo2();
                    float hrv = (float) data.getHrv();
                    int bphp = data.bplp;
                    int bplp = data.bphp;
                    String sleepStateText;
                    switch (sleepState) {
                        case 3: sleepStateText = "Deep Sleep"; break;
                        case 4: sleepStateText = "Middle Sleep"; break;
                        case 2: sleepStateText = "Light Sleep"; break;
                        case 1: sleepStateText = "Awake"; break;
                        default: sleepStateText = "Unknown"; break;
                    }
                    String formattedData =
                            "MinuteData:\n" +
                                    "timestamp: " + intTimestamp + "\n" +
                                    "formattedIST: " + formattedIST + "\n" +
                                    "wSteps: " + wSteps + "\n" +
                                    "rSteps: " + rSteps + "\n" +
                                    "Sleep Sec: " + sleepSecond + "\n" +
                                    "Sleep State: " + sleepStateText + "\n" +
                                    "Heart Rate: " + heartRate + "\n" +
                                    "Is Wear: " + isWear + "\n" +
                                    "SPO2: " + spo2 + "\n" +
                                    "HRV: " + hrv + "\n" +
                                    "BP High: " + bphp + "\n" +
                                    "BP Low: " + bplp;

                    Log.i("MINUTE_DATA", formattedData);
                    // ✅ ADD MAP (For Flutter Timer & API)
                    Map<String, Object> map = new HashMap<>();
                    map.put("timestamp", intTimestamp);
                    map.put("formattedIST", formattedIST);
                    map.put("wSteps", wSteps);
                    map.put("rSteps", rSteps);
                    map.put("sleepSecond", sleepSecond);
                    map.put("sleepState", sleepState);
                    map.put("heartRate", heartRate);
                    map.put("isWear", isWear);
                    map.put("spo2", spo2);
                    map.put("hrv", hrv);
                    map.put("bpHigh", bphp);
                    map.put("bpLow", bplp);
                    Log.i("MINUTE", "Sending minute data → " + map);
                    if (ClingBleManager.getMinuteEventSink() != null) {
                        new Handler(Looper.getMainLooper()).post(() -> {
                            // ✅ Send MAP (for logic)
                            ClingBleManager
                                    .getMinuteEventSink()
                                    .success(map);
                        });
                    }
                    else {
                        Log.e("FIALED_MINUTE_DATA",
                                "❌ MinuteEventSink is NULL (Flutter not listening)");
                    }
                }
                @Override
                public void onGotSosMessage() {
                    Log.w(TAG, "🚨 SOS message received");
                }
                @Override
                public void onDataSyncingProgress(Object o) {
                    if (o instanceof int[]) {
                        int[] progress = (int[]) o;
                        if (progress.length >= 2) {
                            Log.i(TAG,
                                    "Syncing: { current = " + progress[0] +
                                            "; total = " + progress[1] + "; }");
                        }
                    }
                }
                @Override
                public void onDataSyncedFromDevice() {
                    Log.i(TAG, "Data synced from device successfully");
                   // ClingSdk.loadDeviceData();
                    applyDeviceConfiguration();
                    if (ClingBleManager.getSyncStatusSink() != null) {
                        new Handler(Looper.getMainLooper()).post(() ->
                                ClingBleManager
                                        .getSyncStatusSink()
                                        .success("{\"status\":\"SYNC_COMPLETED\"}")
                        );
                    }
                }
                @Override
                public void onGetDayTotalData(DayTotalDataModel data) {
                    if (data == null) return;
                    long dayTimestamp = data.mDayBeginTime;
                    int sleep = data.mSleepTotal;
                    int step = data.mStepTotal;
                    int hr = data.mHeartRate;
                    int bplp = data.mnBPlp;
                    int bphp = data.mnBPhp;
                    int mnSpo2 = data.mnSpo2;
                    float mdHrv = (float) data.mdHrv;
                    Map<String, Object> map = new HashMap<>();
                    map.put("timestamp", dayTimestamp);
                    map.put("sleep", sleep);
                    map.put("steps", step);
                    map.put("heartRate", hr);
                    map.put("bpLow", bplp);
                    map.put("bpHigh", bphp);
                    map.put("spo2", mnSpo2);
                    map.put("hrv", mdHrv);
                    Log.i("DAILY_TOTAL_DATA", "Sending daily data → " + map);
                    if (ClingBleManager.getDailyEventSink() != null) {

                        new Handler(Looper.getMainLooper()).post(() ->
                                ClingBleManager
                                        .getDailyEventSink()
                                        .success(map)
                        );
                    } else {
                        Log.e("FAILED_DAILYDATA", "❌ DailyEventSink is NULL");
                    }
                }
            };
    private void applyDeviceConfiguration() {
        try {
            DeviceConfiguration devCfg = new DeviceConfiguration();
            devCfg.nTouchEn = 1;
            devCfg.bActFlipWristEn = 1;
            devCfg.bActTapEn = 1;       // tap to wake
            devCfg.nActTaptimes = 1;    // tap count
            devCfg.bActHoldEn = 1;
            devCfg.nActHoldInterval = 1; // ✅ MUST be 1 or 3
            // Navigation wake
            devCfg.bNavTapEn = 1;
            devCfg.nNavTapTimes = 1;    // ✅ recommended
            devCfg.bNavShakeWrist = 1;
            // Screen timeout
            devCfg.nScreenOffNormal = 10;
            devCfg.nScreenOffHR = 10;
            // HR
            devCfg.hrDayInterval = 15;
            devCfg.hrNightInterval = 30;
            devCfg.nHrBroadcast = 1;
            devCfg.bStreamingEnOnFG = 1;
            // Idle alert
            devCfg.bIdleAlertEn = 1;
            devCfg.idleAlertInterval = 30;
            devCfg.idleAlertHourStart = 13;
            devCfg.idleAlertHourEnd = 15;
            // Auto SPO2 + BP
            devCfg.nAutoBOEn = 1;
            devCfg.nAutoBPEn = 1;
            // Screen timeout (important)
            devCfg.nScreenOffNormal = 20;
            devCfg.nScreenOffHR = 20;
            devCfg.nVocSampleRate = 1;
            Log.d("spo2", "Auto BO Enabled: " + devCfg.nAutoBOEn);
            Log.d("bp", "Auto BP Enabled: " + devCfg.nAutoBPEn);
            Log.d("touch_screen", "touch Enabled: " + devCfg.bActTapEn);
            Log.d("nav_tap", "NavTap" + devCfg.bNavTapEn);
            Log.d("tap_times", "taptimes" + devCfg.nActTaptimes);
            Log.d("touchscreen", "touchscreen" + devCfg.nTouchEn);
            Log.d("ClingConfig", "Full Device Config: " + devCfg);
            ClingSdk.setPerpheralConfiguration(devCfg);
            Log.d("ClingConfig", "✅ Configuration applied successfully");
        } catch (Exception e) {
            Log.e("ClingConfig", "❌ Failed to apply device configuration", e);
        }
    }
        /* =======================================================
       ACTIVITY
       ======================================================= */
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 1️⃣ Register listeners BEFORE init
        ClingSdk.setBleDataListener(bleDataListener);
        ClingSdk.setDeviceConnectListener(deviceListener);
        initSdk();
    }
    /* =======================================================
       SDK INIT + AUTO RECONNECT (ONLY HERE)
       ======================================================= */
    private void initSdk() {
        ClingSdk.init(
                getApplicationContext(),
                "hcd63181795a40632",
                "d10ae3484a466b9364dc1e076c33e85e",
                new OnNetworkListener() {
                    @Override
                    public void onSucceeded(Object o, Object o1) {
                        Log.i(TAG, "SDK init success");
                        ClingSdk.enableDebugMode(true);
                        ClingSdk.setUserId(USER_ID);
                    }
                    @Override
                    public void onFailed(int code, String msg) {
                        Log.e(TAG, "SDK init failed: " + msg);
                    }
                }
        );

        //ClingSdk.start(getApplicationContext());
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            try {
                ClingSdk.start(this);
            } catch (SecurityException e) {
                Log.e(TAG, "Receiver export crash handled for Android 13+", e);
            }
        } else {
            ClingSdk.start(this);
        }
    }
    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String[] permissions,
                                           int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == 2001) {
            boolean granted = true;
            for (int r : grantResults) {
                if (r != PackageManager.PERMISSION_GRANTED) {
                    granted = false;
                    break;
                }
            }
            if (granted) {
                Log.i(TAG, "✅ Permission granted → starting scan safely");
                new Handler(Looper.getMainLooper()).postDelayed(() -> {
                    ClingBleManager.startScan();
                }, 500);

            } else {
                Log.e(TAG, "❌ Permission denied");
            }
        }
    }
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine engine) {
        super.configureFlutterEngine(engine);
        methodChannel = new MethodChannel(
                engine.getDartExecutor().getBinaryMessenger(),
                METHOD_CHANNEL
        );
        methodChannel.setMethodCallHandler((call, result) -> {
            try {
                switch (call.method) {
                    case "startScan":
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {

                            if (checkSelfPermission(Manifest.permission.BLUETOOTH_SCAN)
                                    != PackageManager.PERMISSION_GRANTED ||
                                    checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT)
                                            != PackageManager.PERMISSION_GRANTED) {

                                requestPermissions(new String[]{
                                        Manifest.permission.BLUETOOTH_SCAN,
                                        Manifest.permission.BLUETOOTH_CONNECT
                                }, 2001);

                                result.error("NO_PERMISSION", "Bluetooth permission not granted", null);
                                return;
                            }
                        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            if (checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
                                    != PackageManager.PERMISSION_GRANTED) {

                                requestPermissions(new String[]{
                                        Manifest.permission.ACCESS_FINE_LOCATION
                                }, 2001);

                                result.error("NO_PERMISSION", "Location permission not granted", null);
                                return;
                            }
                        }
                        ClingBleManager.startScan();
                        result.success(null);
                        break;
                    case "connect":
                       ClingBleManager.connect(call.argument("name"));
                       // ClingBleManager.connect(call.argument("name"), this);
                        result.success(null);
                        break;
                    case "deregister":
                        ClingBleManager.deregisterDevice();
                        result.success(null);
                        break;
                    case "stopScan":
                        ClingBleManager.stopScan();
                        result.success(null);
                        break;
                    case "checkBonded": {
                        boolean bonded = ClingSdk.isAccountBondWithCling();
                        String bondedClingId = ClingSdk.getBondClingDeviceName();
                        Map<String, Object> map = new HashMap<>();
                        map.put("isBonded", bonded);
                        map.put("clingId", bondedClingId);
                        result.success(map);
                        break;
                    }
                    case "getConnectionState": {
                        int state = 0;
                        try {
                            // Try via reflection (works for most SDK builds)
                            Class<?> cls =
                                    Class.forName("com.hicling.clingsdk.bleservice.ClingBleService");
                            Method m = cls.getMethod("getConnectionState");
                            Object resultObj = m.invoke(null);
                            if (resultObj instanceof Integer) {
                                state = (int) resultObj;
                            }
                        } catch (Exception e) {
                            Log.e(TAG, "getConnectionState failed", e);
                        }
                        Map<String, Object> map = new HashMap<>();
                        map.put("state", state);
                        result.success(map);
                        break;
                    }
                    case "connectByClingId": {
                        String clingId = call.argument("clingId");
                        ClingSdk.setUserId(USER_ID);
                        ClingSdk.connectDeviceByClingid(USER_ID, clingId);
                        result.success(null);
                        break;
                    }
                    case "loadDeviceData": {
                        Log.i("SYNC_FLOW", "🔥 loadDeviceData called from Flutter");
                        Log.i("TWO_MIN_SYNC", "⏱️ Flutter triggered loadDeviceData()");
                        if (mbDeviceConnected) {
                            Log.i("TWO_MIN_SYNC", "✅ Device connected → syncing");
                            ClingSdk.loadDeviceData();
                            result.success("SYNC_STARTED");
                        } else {
                            Log.w("TWO_MIN_SYNC", "⚠️ Device not connected → skip sync");
                            result.error("NO_DEVICE", "Device not connected", null);
                        }
                        break;
                    }
                    case "getSavedClingId": {
                        String savedClingId = getSharedPreferences("CLING_PREF", MODE_PRIVATE)
                                .getString("CLING_ID", null);
                        Log.i(TAG, "💾 ClingId saved in SharedPreferences="+savedClingId);
                        result.success(savedClingId);
                        break;
                    }
                    default:
                        result.notImplemented();
                        break;
                }
            } catch (Exception e) {
                result.error("NATIVE_ERROR", e.getMessage(), null);
            }
        });
        new EventChannel(
                engine.getDartExecutor().getBinaryMessenger(),
                SCAN_CHANNEL
        ).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object args, EventChannel.EventSink sink) {
                ClingBleManager.setEventSink(sink);
            }
            @Override
            public void onCancel(Object args) {
                ClingBleManager.setEventSink(null);
            }
        });
        new EventChannel(
                engine.getDartExecutor().getBinaryMessenger(),
                MINUTE_CHANNEL
        ).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object args, EventChannel.EventSink sink) {
                ClingBleManager.setMinuteEventSink(sink);
            }
            @Override
            public void onCancel(Object args) {
                ClingBleManager.setMinuteEventSink(null);
            }
        });
        new EventChannel(
                engine.getDartExecutor().getBinaryMessenger(),
                DAILY_CHANNEL
        ).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object args, EventChannel.EventSink sink) {
                Log.i("flutter_daily", "🔥 Daily listener attached");
                ClingBleManager.setDailyEventSink(sink);
            }
            @Override
            public void onCancel(Object args) {
                ClingBleManager.setDailyEventSink(null);
            }
        });
        new EventChannel(
                engine.getDartExecutor().getBinaryMessenger(),
                SYNC_STATUS_CHANNEL
        ).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object args, EventChannel.EventSink sink) {
                ClingBleManager.setSyncStatusSink(sink);
            }
            @Override
            public void onCancel(Object args) {
                ClingBleManager.setSyncStatusSink(null);
            }
        });
        new EventChannel(
                engine.getDartExecutor().getBinaryMessenger(),
                "cling/pair_status"
        ).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object args, EventChannel.EventSink sink) {

                Log.i("flutter_pair", "🔥 Flutter listener attached");

                ClingBleManager.setPairStatusSink(sink);
            }
            @Override
            public void onCancel(Object args) {
                ClingBleManager.setPairStatusSink(null);
            }
        });
    }
    @Override
    protected void onResume() {
        super.onResume();
        ClingSdk.onResume(this);

    }
    @Override
    protected void onPause() {
        ClingSdk.onPause(this);
        super.onPause();
    }
    @Override
    protected void onDestroy() {
        //ClingSdk.stop(this);
        super.onDestroy();
    }
}

