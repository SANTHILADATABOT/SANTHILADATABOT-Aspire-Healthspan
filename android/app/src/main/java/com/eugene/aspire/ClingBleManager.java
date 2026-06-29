

package com.eugene.aspire;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.bluetooth.BluetoothDevice;

import com.hicling.clingsdk.ClingSdk;
import com.hicling.clingsdk.bleservice.BluetoothDeviceInfo;
import com.hicling.clingsdk.listener.OnBleListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;

public class ClingBleManager {

    private static final String TAG = "CLING_MANAGER";
    private static final int USER_ID = 876355;
    private static int scanCount = 0;
   // public static final int CLING_DEVICE_TYPE_ALL = 26;

    private static final Map<String, BluetoothDevice> deviceMap = new HashMap<>();
    private static final Handler mainHandler = new Handler(Looper.getMainLooper());

    private static EventChannel.EventSink scanSink;
    private static EventChannel.EventSink minuteSink;
    private static EventChannel.EventSink syncStatusSink;
    private static EventChannel.EventSink pairStatusSink;

    private static EventChannel.EventSink dailySink;

    // ================== SINK SETTERS ==================

    public static void setEventSink(EventChannel.EventSink sink) {
        scanSink = sink;
    }


    public static void setMinuteEventSink(EventChannel.EventSink sink) {
        minuteSink = sink;
    }

    public static void setSyncStatusSink(EventChannel.EventSink sink) {
        syncStatusSink = sink;
    }

    public static void setPairStatusSink(EventChannel.EventSink sink) {
        pairStatusSink = sink;
    }

    public static EventChannel.EventSink getMinuteEventSink() {
        return minuteSink;
    }

    public static EventChannel.EventSink getSyncStatusSink() {
        return syncStatusSink;
    }

    public static void setDailyEventSink(EventChannel.EventSink sink) {
        dailySink = sink;
    }

    public static EventChannel.EventSink getDailyEventSink() {
        return dailySink;
    }

    // ================== SCAN ==================

    public static void startScan() {
        scanCount++;

        Log.e(
                "VIVO_DEBUG",
                "SCAN COUNT = " + scanCount
        );

        Log.e(
                "VIVO_DEBUG",
                "START SCAN CALLED FROM THREAD="
                        + Thread.currentThread().getName()
        );

        Log.e(
                "VIVO_DEBUG",
                "TIME="
                        + System.currentTimeMillis()
        );

        Log.i(TAG, "🔍 Starting scan...");
        Log.e(
                "VIVO_DEBUG",
                "STARTING SCAN NOW"
        );
        ClingSdk.stopScan();
        ClingSdk.setUserId(USER_ID);
        //ClingSdk.setClingDeviceType(ClingSdk.CLING_DEVICE_TYPE_TRONL);
        //ClingSdk.setClingDeviceType(ClingSdk.CLING_DEVICE_TYPE_NO_FILTER);
        ClingSdk.setClingDeviceType(ClingSdk.CLING_DEVICE_TYPE_ALL);

        ClingSdk.startScan(60 * 1000,
                new OnBleListener.OnScanDeviceListener() {

                    @Override
                    public void onBleScanUpdated(Object o) {
                        Log.e(
                                "VIVO_DEBUG",
                                "onBleScanUpdated called"
                        );
                        if (o == null) return;

                        ArrayList<BluetoothDeviceInfo> devices =
                                (ArrayList<BluetoothDeviceInfo>) o;
                        for (int i = 0; i < devices.size(); i++) {
                            Log.e(
                                    "VIVO_DEBUG",
                                    "DEVICE INDEX = " + i
                            );
                        }
                        Log.e(
                                "VIVO_DEBUG",
                                "SDK returned " + devices.size() + " devices"
                        );
                        List<Map<String, Object>> result = new ArrayList<>();

                        for (BluetoothDeviceInfo d : devices) {

                            BluetoothDevice device = d.getmBleDevice();
                            if (device == null) {
                                Log.e(
                                        "VIVO_DEBUG",
                                        "BluetoothDevice is NULL"
                                );
                                continue;
                            }

                            String mac = device.getAddress();
                            String name = device.getName();

                            if (name == null) {
                                Log.e(
                                        "VIVO_DEBUG",
                                        "NAME IS NULL | MAC=" + mac +
                                                " RSSI=" + d.getmRssi()
                                );
                            } else {
                                Log.e(
                                        "VIVO_DEBUG",
                                        "NAME=" + name +
                                                " MAC=" + mac +
                                                " RSSI=" + d.getmRssi()
                                );
                            }
                            deviceMap.put(name, device);

                            Map<String, Object> map = new HashMap<>();
                            map.put("name", name);
                            map.put("mac", mac);
                            map.put("rssi", d.getmRssi());

                            result.add(map);
                        }

                        if (scanSink != null) {
                            mainHandler.post(() -> scanSink.success(result));
                        }
                    }
                });
    }

    public static void stopScan() {
        ClingSdk.stopScan();
    }

    // ================== CONNECT ==================

    public static void connect(String name) {

        Log.e(TAG, "🔗 CONNECT CALLED with name → " + name);

        ClingSdk.stopScan();
        // Disconnect from any previously bound native device before connecting to a new one
        ClingSdk.disconnectDevice(true);

        ClingSdk.setUserId(USER_ID);

        BluetoothDevice device = deviceMap.get(name);

        if (device == null) {
            Log.e(TAG, "❌ Device not found");
            return;
        }

        Log.e(TAG, "🚀 Registering device directly");

        ClingSdk.registerDevice(
                USER_ID,
                device,
                new OnBleListener.OnRegisterDeviceListener() {

                    @Override
                    public void onRegisterDeviceSucceed() {
                        Log.e(TAG, "✅ Register success");
                    }

                    @Override
                    public void onRegisterDeviceFailed(int code, String msg) {
                        Log.e(TAG, "❌ Register failed: " + msg);
                    }
                }
        );
    }
    // ================== PAIR EVENT ==================

    public static void notifyPaired(String clingId) {

        if (clingId == null || clingId.isEmpty()) return;

        Log.i(TAG, "🔥 Pair success → " + clingId);

        if (pairStatusSink != null) {
            mainHandler.post(() -> pairStatusSink.success(clingId));
        } else {
            Log.w(TAG, "PairStatusSink is NULL");
        }
    }

    // ================== DEREGISTER ==================

    public static void deregisterDevice() {

        Log.i(TAG, "🔴 DEREGISTER CALLED");

        // 1. Clear local local map
        deviceMap.clear();

        // 2. Stop any active scanning
        ClingSdk.stopScan();

        // 3. Perform SDK deregistration (while potentially still connected)
        ClingSdk.deregisterDevice(
                new OnBleListener.OnDeregisterDeviceListener() {

                    @Override
                    public void onDeregisterDeviceSucceed() {
                        Log.i(TAG, "✅ Device deregistered successfully");
                        // 4. Force permanent disconnect ONLY after deregister signals are sent
                        ClingSdk.disconnectDevice(false);
                        // 5. Clear SDK internal database to simulate uninstall amnesia
                        ClingSdk.clearDatabase();
                    }

                    @Override
                    public void onDeregisterDeviceFailed(int code, String msg) {
                        Log.e(TAG, "❌ Deregister failed: " + code + " " + msg);
                        // Even if it fails, we should probably disconnect if force unpairing
                        ClingSdk.disconnectDevice(false);
                    }
                }
        );
    }

    // ================== CLEAR NATIVE CACHE (LOGOUT) ==================

    public static void clearNativeCache() {
        Log.i(TAG, "🧹 Local Logout: Clearing native device maps to simulate uninstall amnesia");
        deviceMap.clear();
        ClingSdk.stopScan();
        ClingSdk.disconnectDevice(false);
        // Force the SDK Native database to forget GE F5DE
        ClingSdk.clearDatabase();
    }
}