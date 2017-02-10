package tw.com.alchemytech.rnbrainwave;


import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;

public class RNBrainwaveModule extends ReactContextBaseJavaModule {

    public RNBrainwaveModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "RNBrainwave";
    }
}