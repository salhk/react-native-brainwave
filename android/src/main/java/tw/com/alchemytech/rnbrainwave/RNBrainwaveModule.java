package tw.com.alchemytech.rnbrainwave;


import android.bluetooth.BluetoothAdapter;
import android.content.Context;
import android.support.annotation.Nullable;
import android.util.Log;
import android.widget.Button;
import android.widget.Toast;


import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.neurosky.AlgoSdk.NskAlgoDataType;
import com.neurosky.AlgoSdk.NskAlgoSdk;
import com.neurosky.AlgoSdk.NskAlgoSignalQuality;
import com.neurosky.AlgoSdk.NskAlgoState;
import com.neurosky.AlgoSdk.NskAlgoType;
import com.neurosky.connection.ConnectionStates;
import com.neurosky.connection.DataType.MindDataType;
import com.neurosky.connection.TgStreamHandler;
import com.neurosky.connection.TgStreamReader;

import java.util.HashMap;
import java.util.Map;

public class RNBrainwaveModule extends ReactContextBaseJavaModule {

    final String TAG = "RNBrainwave";
    // graph plot variables
    private final static int X_RANGE = 50;

    // COMM SDK handles
    private TgStreamReader tgStreamReader;
    private BluetoothAdapter mBluetoothAdapter;

    // internal variables
    private boolean bInited = false;
    private boolean bRunning = false;
    private NskAlgoType currentSelectedAlgo;
    private int apInterval = 1;
    private int meInterval = 1;
    private int me2Interval = 30;
    private int fInterval = 1;
    private int f2Interval = 30;

    // canned data variables
    private short raw_data[] = {0};
    private int raw_data_index = 0;
    private int me_index = 0;
    private int ap_index = 0;
    private int f_index = 0;
    private int raw_data_sec_len = 112;
    private NskAlgoSdk nskAlgoSdk;
    private ReactContext context;

    private static final String CONNECTION_STATE = "CONNECTION_STATE";
    private static final String CONNECTION_ERROR = "CONNECTION_ERROR";
    private static final String SIGNAL_QUALITY = "SIGNAL_QUALITY";
    private static final String ATTENTION_ALGO_INDEX = "ATTENTION_ALGO_INDEX";
    private static final String MEDITATION_ALGO_INDEX = "MEDITATION_ALGO_INDEX";
    private static final String APPRECIATION_ALGO_INDEX = "APPRECIATION_ALGO_INDEX";
    private static final String MENTAL_EFFORT_ALGO_INDEX = "MENTAL_EFFORT_ALGO_INDEX";
    private static final String MENTAL_EFFORT2_ALGO_INDEX = "MENTAL_EFFORT2_ALGO_INDEX";
    private static final String FAMILIARITY_ALGO_INDEX = "FAMILIARITY_ALGO_INDEX";
    private static final String FAMILIARITY2_ALGO_INDEX = "FAMILIARITY2_ALGO_INDEX";

    private static final String CONNECTION_STATE_INIT = "CONNECTION_STATE_INIT";
    private static final String CONNECTION_STATE_CONNECTING = "CONNECTION_STATE_CONNECTING";
    private static final String CONNECTION_STATE_CONNECTED = "CONNECTION_STATE_CONNECTED";
    private static final String CONNECTION_STATE_WORKING = "CONNECTION_STATE_WORKING";
    private static final String CONNECTION_STATE_GET_DATA_TIMEOUT = "CONNECTION_STATE_GET_DATA_TIMEOUT";
    private static final String CONNECTION_STATE_STOPPED = "CONNECTION_STATE_STOPPED";
    private static final String CONNECTION_STATE_DISCONNECTED = "CONNECTION_STATE_DISCONNECTED";
    private static final String CONNECTION_STATE_COMPLETE = "CONNECTION_STATE_COMPLETE";
    private static final String CONNECTION_STATE_RECORDING_START = "CONNECTION_STATE_RECORDING_START";
    private static final String CONNECTION_STATE_RECORDING_END = "CONNECTION_STATE_RECORDING_END";
    private static final String CONNECTION_STATE_ERROR = "CONNECTION_STATE_ERROR";
    private static final String CONNECTION_STATE_FAILED = "CONNECTION_STATE_FAILED";


    public RNBrainwaveModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.context = reactContext;

        nskAlgoSdk = new NskAlgoSdk();

        nskAlgoSdk.setOnStateChangeListener(new NskAlgoSdk.OnStateChangeListener() {
            @Override
            public void onStateChange(int state, int reason) {
                String stateStr = "";
                String reasonStr = "";
                for (NskAlgoState s : NskAlgoState.values()) {
                    if (s.value == state) {
                        stateStr = s.toString();
                    }
                }
                for (NskAlgoState r : NskAlgoState.values()) {
                    if (r.value == reason) {
                        reasonStr = r.toString();
                    }
                }
                Log.d(TAG, "NskAlgoSdkStateChangeListener: state: " + stateStr + ", reason: " + reasonStr);
                final String finalStateStr = stateStr + " | " + reasonStr;
                final int finalState = state;
                if (finalState == NskAlgoState.NSK_ALGO_STATE_RUNNING.value || finalState == NskAlgoState.NSK_ALGO_STATE_COLLECTING_BASELINE_DATA.value) {
                    bRunning = true;
                } else if (finalState == NskAlgoState.NSK_ALGO_STATE_STOP.value) {
                    bRunning = false;
                    raw_data = null;
                    raw_data_index = 0;

                    if (tgStreamReader != null && tgStreamReader.isBTConnected()) {

                        // Prepare for connecting
                        tgStreamReader.stop();
                        tgStreamReader.close();
                    }

                    me_index = 0;
                    ap_index = 0;
                    f_index = 0;

                    System.gc();
                } else if (finalState == NskAlgoState.NSK_ALGO_STATE_PAUSE.value) {
                    bRunning = false;
                } else if (finalState == NskAlgoState.NSK_ALGO_STATE_ANALYSING_BULK_DATA.value) {
                    bRunning = true;
                } else if (finalState == NskAlgoState.NSK_ALGO_STATE_INITED.value || finalState == NskAlgoState.NSK_ALGO_STATE_UNINTIED.value) {
                    bRunning = false;
                }
            }
        });

        nskAlgoSdk.setOnSignalQualityListener(new NskAlgoSdk.OnSignalQualityListener() {
            @Override
            public void onSignalQuality(final int level) {
                WritableMap event = Arguments.createMap();
                event.putInt("level", level);
                sendEvent(context, SIGNAL_QUALITY, event);
            }
        });

        nskAlgoSdk.setOnAPAlgoIndexListener(new NskAlgoSdk.OnAPAlgoIndexListener() {
            @Override
            public void onAPAlgoIndex(float value) {
                Log.d(TAG, "NskAlgoAPAlgoIndexListener: AP: " + value);
                final float fValue = value;
                WritableMap event = Arguments.createMap();
                event.putDouble("value", value);
                sendEvent(context, APPRECIATION_ALGO_INDEX, event);
            }
        });

        nskAlgoSdk.setOnMEAlgoIndexListener(new NskAlgoSdk.OnMEAlgoIndexListener() {
            @Override
            public void onMEAlgoIndex(final float abs_me, final float diff_me, float max_me, float min_me) {
                Log.d(TAG, "NskAlgoMEAlgoIndexListener: ME: abs:" + abs_me + ", diff:" + diff_me + "[" + min_me + ":" + max_me + "]");
                WritableMap event = Arguments.createMap();
                event.putDouble("abs_me", abs_me);
                event.putDouble("diff_me", diff_me);
                event.putDouble("max_me", max_me);
                event.putDouble("min_me", min_me);
                sendEvent(context, MENTAL_EFFORT_ALGO_INDEX, event);
                me_index++;
            }
        });

        nskAlgoSdk.setOnME2AlgoIndexListener(new NskAlgoSdk.OnME2AlgoIndexListener() {
            @Override
            public void onME2AlgoIndex(float total_me, float me_rate, float changing_rate) {
                Log.d(TAG, "NskAlgoME2AlgoIndexListener: ME2: total:" + total_me + ", rate:" + me_rate + ", chg rate:" + changing_rate);
                WritableMap event = Arguments.createMap();
                event.putDouble("total_me", total_me);
                event.putDouble("me_rate", me_rate);
                event.putDouble("changing_rate", changing_rate);
                sendEvent(context, MENTAL_EFFORT2_ALGO_INDEX, event);

            }
        });

        nskAlgoSdk.setOnFAlgoIndexListener(new NskAlgoSdk.OnFAlgoIndexListener() {
            @Override
            public void onFAlgoIndex(final float abs_f, final float diff_f, float max_f, float min_f) {
                Log.d(TAG, "NskAlgoFAlgoIndexListener: F: abs:" + abs_f + ", diff:" + diff_f + "[" + min_f + ":" + max_f + "]");
                WritableMap event = Arguments.createMap();
                event.putDouble("abs_f", abs_f);
                event.putDouble("diff_f", diff_f);
                event.putDouble("max_f", max_f);
                event.putDouble("min_f", min_f);
                sendEvent(context, FAMILIARITY_ALGO_INDEX, event);
                f_index++;
            }
        });

        nskAlgoSdk.setOnF2AlgoIndexListener(new NskAlgoSdk.OnF2AlgoIndexListener() {
            @Override
            public void onF2AlgoIndex(final int progress_level, final float f_degree) {
                Log.d(TAG, "NskAlgoAPAlgoIndexListener: F2: Level: " + progress_level + " Degree: " + f_degree);
                WritableMap event = Arguments.createMap();
                event.putInt("progress_level", progress_level);
                event.putDouble("f_degree", f_degree);
                sendEvent(context, FAMILIARITY2_ALGO_INDEX, event);
            }
        });

        nskAlgoSdk.setOnAttAlgoIndexListener(new NskAlgoSdk.OnAttAlgoIndexListener() {
            @Override
            public void onAttAlgoIndex(int value) {
                Log.d(TAG, "NskAlgoAttAlgoIndexListener: Attention:" + value);
                WritableMap event = Arguments.createMap();
                event.putInt("value", value);
                sendEvent(context, ATTENTION_ALGO_INDEX, event);
            }
        });

        nskAlgoSdk.setOnMedAlgoIndexListener(new NskAlgoSdk.OnMedAlgoIndexListener() {
            @Override
            public void onMedAlgoIndex(int value) {
                Log.d(TAG, "NskAlgoAttAlgoIndexListener: Meditation:" + value);
                WritableMap event = Arguments.createMap();
                event.putInt("value", value);
                sendEvent(context, MEDITATION_ALGO_INDEX, event);
            }
        });

    }

    @ReactMethod
    public void connect() {
        try {
            // (1) Make sure that the device supports Bluetooth and Bluetooth is on
            mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
            if (mBluetoothAdapter == null || !mBluetoothAdapter.isEnabled()) {
                sendEvent(context, CONNECTION_STATE_FAILED, null);
            }
            // Example of constructor public TgStreamReader(BluetoothAdapter ba, TgStreamHandler tgStreamHandler)
            tgStreamReader = new TgStreamReader(mBluetoothAdapter, callback);

            raw_data = new short[512];
            raw_data_index = 0;

            if (tgStreamReader != null) {
                if (tgStreamReader.isBTConnected()) {
                    // Prepare for connecting
                    tgStreamReader.stop();
                    tgStreamReader.close();
                }
                // (4) Demo of  using connect() and start() to replace connectAndStart(),
                // please call start() when the state is changed to STATE_CONNECTED
                tgStreamReader.connect();
            }

            setAlgos();

        } catch (Exception e) {
            sendEvent(context, CONNECTION_ERROR, null);

            return;
        }
    }

    private void setAlgos() {
        int algoTypes = 0;

        algoTypes += NskAlgoType.NSK_ALGO_TYPE_AP.value;

        algoTypes += NskAlgoType.NSK_ALGO_TYPE_ME.value;

        algoTypes += NskAlgoType.NSK_ALGO_TYPE_ME2.value;

        algoTypes += NskAlgoType.NSK_ALGO_TYPE_F.value;

        algoTypes += NskAlgoType.NSK_ALGO_TYPE_F2.value;

        algoTypes += NskAlgoType.NSK_ALGO_TYPE_MED.value;

        algoTypes += NskAlgoType.NSK_ALGO_TYPE_ATT.value;

        if (bInited) {
            nskAlgoSdk.NskAlgoUninit();
            bInited = false;
        }
        int ret = nskAlgoSdk.NskAlgoInit(algoTypes, context.getFilesDir().getAbsolutePath());
        if (ret == 0) {
            bInited = true;
        }
    }

    private TgStreamHandler callback = new TgStreamHandler() {

        @Override
        public void onStatesChanged(int connection_state) {
            // TODO Auto-generated method stub
            Log.d(TAG, "connection_state change to: " + connection_state);
            WritableMap event = Arguments.createMap();
            event.putInt("connection_state", connection_state);
            sendEvent(context, CONNECTION_STATE, event);
            switch (connection_state) {
                case ConnectionStates.STATE_CONNECTING:
                    // Do something when connecting
                    break;
                case ConnectionStates.STATE_CONNECTED:
                    // Do something when connected
                    tgStreamReader.start();

                    //showToast("Connected", Toast.LENGTH_SHORT);
                    break;
                case ConnectionStates.STATE_WORKING:
                    // Do something when working

                    //(9) demo of recording raw data , stop() will call stopRecordRawData,
                    //or you can add a button to control it.
                    //You can change the save path by calling setRecordStreamFilePath(String filePath) before startRecordRawData
                    //tgStreamReader.startRecordRawData();

                    break;
                case ConnectionStates.STATE_GET_DATA_TIME_OUT:
                    // Do something when getting data timeout

                    //(9) demo of recording raw data, exception handling
                    //tgStreamReader.stopRecordRawData();

                    //showToast("Get data time out!", Toast.LENGTH_SHORT);

                    if (tgStreamReader != null && tgStreamReader.isBTConnected()) {
                        tgStreamReader.stop();
                        tgStreamReader.close();
                    }

                    break;
                case ConnectionStates.STATE_STOPPED:
                    // Do something when stopped
                    // We have to call tgStreamReader.stop() and tgStreamReader.close() much more than
                    // tgStreamReader.connectAndstart(), because we have to prepare for that.

                    break;
                case ConnectionStates.STATE_DISCONNECTED:
                    nskAlgoSdk.NskAlgoStop();
                    break;
                case ConnectionStates.STATE_ERROR:
                    // Do something when you get error message
                    break;
                case ConnectionStates.STATE_FAILED:
                    // Do something when you get failed message
                    // It always happens when open the BluetoothSocket error or timeout
                    // Maybe the device is not working normal.
                    // Maybe you have to try again
                    break;
            }
        }

        @Override
        public void onRecordFail(int flag) {
            // You can handle the record error message here
            Log.e(TAG, "onRecordFail: " + flag);

        }

        @Override
        public void onChecksumFail(byte[] payload, int length, int checksum) {
            // You can handle the bad packets here.
        }

        @Override
        public void onDataReceived(int datatype, int data, Object obj) {
            // You can handle the received data here
            // You can feed the raw data to algo sdk here if necessary.
            //Log.i(TAG,"onDataReceived");
            switch (datatype) {
                case MindDataType.CODE_ATTENTION:
                    short attValue[] = {(short) data};
                    nskAlgoSdk.NskAlgoDataStream(NskAlgoDataType.NSK_ALGO_DATA_TYPE_ATT.value, attValue, 1);
                    break;
                case MindDataType.CODE_MEDITATION:
                    short medValue[] = {(short) data};
                    nskAlgoSdk.NskAlgoDataStream(NskAlgoDataType.NSK_ALGO_DATA_TYPE_MED.value, medValue, 1);
                    break;
                case MindDataType.CODE_POOR_SIGNAL:
                    short pqValue[] = {(short) data};
                    nskAlgoSdk.NskAlgoDataStream(NskAlgoDataType.NSK_ALGO_DATA_TYPE_PQ.value, pqValue, 1);

                    break;
                case MindDataType.CODE_RAW:
                    if (bRunning == false) {
                        nskAlgoSdk.NskAlgoStart(false);
                        bRunning = true;
                    }
                    raw_data[raw_data_index++] = (short) data;
                    if (raw_data_index == 512) {
                        nskAlgoSdk.NskAlgoDataStream(NskAlgoDataType.NSK_ALGO_DATA_TYPE_EEG.value, raw_data, raw_data_index);
                        raw_data_index = 0;
                    }
                    break;
                default:
                    break;
            }
        }

    };

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put(CONNECTION_STATE, CONNECTION_STATE);
        constants.put(CONNECTION_ERROR, CONNECTION_ERROR);
        constants.put(SIGNAL_QUALITY, SIGNAL_QUALITY);
        constants.put(ATTENTION_ALGO_INDEX, ATTENTION_ALGO_INDEX);
        constants.put(MEDITATION_ALGO_INDEX, MEDITATION_ALGO_INDEX);
        constants.put(APPRECIATION_ALGO_INDEX, APPRECIATION_ALGO_INDEX);
        constants.put(MENTAL_EFFORT_ALGO_INDEX, MENTAL_EFFORT_ALGO_INDEX);
        constants.put(MENTAL_EFFORT2_ALGO_INDEX, MENTAL_EFFORT2_ALGO_INDEX);
        constants.put(FAMILIARITY_ALGO_INDEX, FAMILIARITY_ALGO_INDEX);
        constants.put(FAMILIARITY2_ALGO_INDEX, FAMILIARITY2_ALGO_INDEX);

        constants.put(CONNECTION_STATE_INIT, ConnectionStates.STATE_INIT);
        constants.put(CONNECTION_STATE_CONNECTING, ConnectionStates.STATE_CONNECTING);
        constants.put(CONNECTION_STATE_CONNECTED, ConnectionStates.STATE_CONNECTED);
        constants.put(CONNECTION_STATE_WORKING, ConnectionStates.STATE_WORKING);
        constants.put(CONNECTION_STATE_GET_DATA_TIMEOUT, ConnectionStates.STATE_GET_DATA_TIME_OUT);
        constants.put(CONNECTION_STATE_STOPPED, ConnectionStates.STATE_STOPPED);
        constants.put(CONNECTION_STATE_DISCONNECTED, ConnectionStates.STATE_DISCONNECTED);
        constants.put(CONNECTION_STATE_COMPLETE, ConnectionStates.STATE_COMPLETE);
        constants.put(CONNECTION_STATE_RECORDING_START, ConnectionStates.STATE_RECORDING_START);
        constants.put(CONNECTION_STATE_RECORDING_END, ConnectionStates.STATE_RECORDING_END);
        constants.put(CONNECTION_STATE_ERROR, ConnectionStates.STATE_ERROR);
        constants.put(CONNECTION_STATE_FAILED, ConnectionStates.STATE_FAILED);
        return constants;
    }


    @Override
    public String getName() {
        return "RNBrainwave";
    }

    private void sendEvent(ReactContext reactContext, String eventName, @Nullable WritableMap params) {
        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, params);
    }


}