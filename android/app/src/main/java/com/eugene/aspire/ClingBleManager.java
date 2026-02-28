





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

        Log.i(TAG, "🔍 Starting scan...");

        ClingSdk.stopScan();
        ClingSdk.setUserId(USER_ID);
        ClingSdk.setClingDeviceType(ClingSdk.CLING_DEVICE_TYPE_TRONL);

        ClingSdk.startScan(60 * 1000,
                new OnBleListener.OnScanDeviceListener() {

                    @Override
                    public void onBleScanUpdated(Object o) {

                        if (o == null) return;

                        ArrayList<BluetoothDeviceInfo> devices =
                                (ArrayList<BluetoothDeviceInfo>) o;

                        List<Map<String, Object>> result = new ArrayList<>();

                        for (BluetoothDeviceInfo d : devices) {

                            BluetoothDevice device = d.getmBleDevice();
                            if (device == null) continue;

                            String mac = device.getAddress();
                            String name = device.getName();

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

        Log.e(TAG, "==============================");
        Log.e(TAG, "🔗 CONNECT CALLED with name → " + name);

        ClingSdk.stopScan();
        ClingSdk.setUserId(USER_ID);

        BluetoothDevice device = deviceMap.get(name);

        if (device == null) {
            Log.e(TAG, "❌ Device not found in deviceMap");
            return;
        }

        String clingId = ClingSdk.getBondClingDeviceName();
        Log.e(TAG, "📌 Bonded clingId → " + clingId);

        if (clingId != null && !clingId.isEmpty()) {

            Log.e(TAG, "⚡ Bond exists → forcing reconnect");

            //ClingSdk.disconnectDevice(false);

            new Handler(Looper.getMainLooper()).postDelayed(() -> {

                Log.e(TAG, "🚀 Calling connectDeviceByClingid()");
                ClingSdk.connectDeviceByClingid(USER_ID, clingId);

            }, 800);

            return;
        }

        Log.e(TAG, "🆕 No bonded device → calling registerDevice()");

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
                        Log.e(TAG, "❌ Register failed: " + code + " " + msg);
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

        //ClingSdk.disconnectDevice(true);

        ClingSdk.deregisterDevice(
                new OnBleListener.OnDeregisterDeviceListener() {


                    @Override
                    public void onDeregisterDeviceSucceed() {

                        Log.i(TAG, "Device deregistered");
//                        ClingSdk.clearDatabase();
//                        deviceMap.clear();
                    }

                    @Override
                    public void onDeregisterDeviceFailed(int code, String msg) {
                        Log.e(TAG, "Deregister failed: " + code + " " + msg);
                    }
                }
        );
    }
}