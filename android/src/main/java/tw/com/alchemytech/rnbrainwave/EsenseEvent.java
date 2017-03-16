package tw.com.alchemytech.rnbrainwave;

import com.neurosky.connection.EEGPower;

/**
 * Created by jimmy on 15/03/2017.
 */

public class EsenseEvent {

    public long timestamp = -1;
    public int poorSignal = -1;
    public int attention = -1;
    public int meditation = -1;
    public EEGPower eegPower = null;

}
