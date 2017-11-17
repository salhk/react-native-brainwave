/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
    AppRegistry,
    StyleSheet,
    Text,
    View,
    TouchableOpacity,
    Alert,
    DeviceEventEmitter,
    NativeEventEmitter
} from 'react-native';
import {
    VictoryChart,
    VictoryLine
} from 'victory-native';

import {
    RNBrainwave
} from 'react-native-brainwave';

const brainwaveEventEmitter = new NativeEventEmitter(RNBrainwave);

export default class App extends Component {

    constructor(props) {
        super(props);
        this.state = {
            connectionState: 'disconnected',
            connected: false,
            signalQuality: '',
            attention: [],
            meditation: [],
            esense: {}
        };
    }


    render() {
        return (
            <View style={styles.container}>
                <TouchableOpacity onPress={this.connect}>
                    <Text style={styles.button}>
                        Tap to connect
                    </Text>
                </TouchableOpacity>
                <TouchableOpacity onPress={this.disconnect}>
                    <Text style={styles.button}>
                        Disconnect
                    </Text>
                </TouchableOpacity>
                <Text>
                    {this.state.connectionState}
                </Text>
                <Text>
                    {this.state.signalQuality}
                </Text>
                <VictoryChart
                    scale={{ x: "linear", y: "linear" }}
                >
                    {this.renderAttentionChart()}
                    {this.renderMeditationChart()}
                </VictoryChart>
                <Text>
                    delta:{this.state.esense.delta}
                </Text>
                <Text>
                    theta:{this.state.esense.theta}
                </Text>
                <Text>
                    lowAlpha:{this.state.esense.lowAlpha}
                </Text>
                <Text>
                    highAlpha:{this.state.esense.highAlpha}
                </Text>
                <Text>
                    lowBeta:{this.state.esense.lowBeta}
                </Text>
                <Text>
                    highBeta:{this.state.esense.highBeta}
                </Text>
                <Text>
                    lowGamma:{this.state.esense.lowGamma}
                </Text>
                <Text>
                    midGamma:{this.state.esense.midGamma}
                </Text>
            </View>
        );
    }

    componentWillMount() {
        //DeviceEventEmitter.addListener(RNBrainwave.CONNECTION_STATE, this.connectionStateChange.bind(this));
        //DeviceEventEmitter.addListener(RNBrainwave.SIGNAL_QUALITY, this.signalQualityChange.bind(this));
        //DeviceEventEmitter.addListener(RNBrainwave.ATTENTION_ALGO_INDEX, this.attentionIndexHandler.bind(this));
        //DeviceEventEmitter.addListener(RNBrainwave.MEDITATION_ALGO_INDEX, this.meditationIndexHandler.bind(this));
        //DeviceEventEmitter.addListener(RNBrainwave.ESENSE_EVENT, this.esenseEventHandler.bind(this));

        this.subscriptionConnectionState = brainwaveEventEmitter.addListener(RNBrainwave.CONNECTION_STATE, this.connectionStateChange.bind(this));
        this.subscriptionSignalQuality = brainwaveEventEmitter.addListener(RNBrainwave.SIGNAL_QUALITY, this.signalQualityChange.bind(this));
        //this.subscriptionFamiliarity = brainwaveEventEmitter.addListener(RNBrainwave.FAMILIARITY_ALGO_INDEX, this.familiarityIndexHandler.bind(this));
        this.subscriptionEsense = brainwaveEventEmitter.addListener(RNBrainwave.ESENSE_EVENT, this.esenseEventHandler.bind(this));
        this.subscriptionRawData = brainwaveEventEmitter.addListener(RNBrainwave.RAW_DATA, this.rawDataHandler.bind(this));

        RNBrainwave.setDefaultAlgos();
    }

    componentWillUnmount() {
        this.subscriptionConnectionState.remove();
        this.subscriptionSignalQuality.remove();
        //this.subscriptionFamiliarity.remove();
        this.subscriptionEsense.remove();
        this.subscriptionRawData.remove();
    }

    renderAttentionChart() {
        if (this.state.attention.length > 0) {
            return (
                <VictoryLine
                    data={this.state.attention}
                    x="time"
                    y="value"
                    style={{
                        data: { stroke: "#ff7171", opacity: 0.7 },
                    }}
                />
            )
        }
        else {
            return null;
        }
    }

    renderMeditationChart() {
        if (this.state.meditation.length > 0) {
            return (
                <VictoryLine
                    data={this.state.meditation}
                    x="time"
                    y="value"
                    style={{
                        data: { stroke: "#4972f2", opacity: 0.7 },
                    }}
                />
            )
        }
        else {
            return null;
        }
    }

    connect() {
        RNBrainwave.connect();
    }

    disconnect() {
        RNBrainwave.disconnect();
    }

    connectionStateChange(event) {
        var stateString = '';
        var connected = false;
        switch (event['connection_state']) {
            case RNBrainwave.CONNECTION_STATE_INIT:
                stateString = 'init';
                break;
            case RNBrainwave.CONNECTION_STATE_CONNECTING:
                stateString = 'connecting';
                break;
            case RNBrainwave.CONNECTION_STATE_CONNECTED:
                stateString = 'connected';
                connected = true;
                break;
            case RNBrainwave.CONNECTION_STATE_WORKING:
                stateString = 'working';
                connected = true;
                break;
            case RNBrainwave.CONNECTION_STATE_GET_DATA_TIMEOUT:
                stateString = 'timeout';
                break;
            case RNBrainwave.CONNECTION_STATE_STOPPED:
                stateString = 'stopped';
                break;
            case RNBrainwave.CONNECTION_STATE_DISCONNECTED:
                stateString = 'disconnected';
                break;
            case RNBrainwave.CONNECTION_STATE_ERROR:
                stateString = 'connection error';
                break;
            case RNBrainwave.CONNECTION_STATE_FAILED:
                stateString = 'failed to connect';
                break;
            default:
                stateString = event['connection_state'].toString();
                break;
        }

        this.setState({
            connectionState: stateString,
            connected: connected
        });
    }

    signalQualityChange(event) {
        var signalQuality = event['level'];
        var str = '';
        switch (signalQuality) {
            case 0:
                str = 'good';
                break;
            case 1:
                str = 'medium';
                break;
            case 2:
                str = 'poor';
                break;
            case 3:
                str = 'Not detected';
                break;
        }

        this.setState({
            signalQuality: str
        });
    }

    attentionIndexHandler(event) {
        var value = event['value'];
        var index = 0;
        var arr = this.state.attention;
        if (this.state.attention.length > 0) {
            index = arr[arr.length - 1].time + 1;
        }
        arr.push({
            time: index,
            value: value
        });
        if (arr.length > 20) {
            arr.shift();
        }
        this.setState({
            attention: arr
        });
    }

    meditationIndexHandler(event) {
        var value = event['value'];
        var index = 0;
        var arr = this.state.meditation;
        if (this.state.meditation.length > 0) {
            index = arr[arr.length - 1].time + 1;
        }
        arr.push({
            time: index,
            value: value
        });
        if (arr.length > 20) {
            arr.shift();
        }
        this.setState({
            meditation: arr
        });
    }

    esenseEventHandler(event) {
        var ts = event['ts'];
        var attention = event['attention'];
        var meditation = event['meditation'];
        var arrAtt = this.state.attention;
        var arrMed = this.state.meditation;
        arrAtt.push({
            time: ts,
            value: attention
        });
        if (arrAtt.length > 20) {
            arrAtt.shift();
        }
        arrMed.push({
            time: ts,
            value: meditation
        });
        if (arrMed.length > 20) {
            arrMed.shift();
        }
        this.setState({
            attention: arrAtt,
            meditation: arrMed,
            esense: event
        });
    }

    rawDataHandler(event) {
        //console.log(event['data']);
    }


}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: 'white',
    },
    button: {
        fontSize: 20,
        textAlign: 'center',
        margin: 10,
    },
    chart: {
        width: 200,
        height: 200,
    }
});

AppRegistry.registerComponent('SampleRNBrainwave', () => SampleRNBrainwave);
