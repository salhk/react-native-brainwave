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
    Alert
} from 'react-native';

import { RNBrainwave } from 'react-native-brainwave';

export default class App extends Component {
    render() {
        return (
            <View style={styles.container}>
                <TouchableOpacity onPress={this.connect}>
                    <Text style={styles.welcome}>
                        Tap to connect
                    </Text>
                </TouchableOpacity>
                <Text style={styles.instructions}>

                </Text>
            </View>
        );
    }

    connect() {
        //Alert.alert('brainwave', RNBrainwave.getConstants());
        //RNBrainwave.connect();
        RNBrainwave.show("asdf", 3);
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
