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
    DeviceEventEmitter
} from 'react-native';


import RNBrainwave from 'react-native-brainwave';

export default class App extends Component {

    constructor(props) {
        super(props);
        this.state = {
            connectionState: 'disconnected'
        };
    }


    render() {
        return (
            <View style={styles.container}>
                <TouchableOpacity onPress={this.connect}>
                    <Text style={styles.welcome}>
                        Tap to connect
                    </Text>
                </TouchableOpacity>
                <Text style={styles.instructions}>
                    {this.state.connectionState}
                </Text>
            </View>
        );
    }

    componentWillMount() {
        DeviceEventEmitter.addListener(RNBrainwave.CONNECTION_STATE, this.connectionStateChange.bind(this));
    }

    connectionStateChange(event) {
        var stateString = '';
        switch (event['connection_state']) {
            case RNBrainwave.CONNECTION_STATE_INIT:
                stateString = 'init';
                break;
            case RNBrainwave.CONNECTION_STATE_CONNECTING:
                stateString = 'connecting';
                break;
            case RNBrainwave.CONNECTION_STATE_CONNECTED:
                stateString = 'connected';
                break;
            case RNBrainwave.CONNECTION_STATE_WORKING:
                stateString = 'working';
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
                stateString = 'disconnected';
                break;
        }

        this.setState({
            connectionState: stateString
        });
    }

    connect() {
        RNBrainwave.connect();
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF',
    },
    welcome: {
        fontSize: 20,
        textAlign: 'center',
        margin: 10,
    },
    instructions: {
        textAlign: 'center',
        color: '#333333',
        marginBottom: 5,
    },
});

AppRegistry.registerComponent('SampleRNBrainwave', () => SampleRNBrainwave);
