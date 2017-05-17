react-native-brainwave



## iOS Configurations
- add -all_load in Project -> Build Settings -> Other Linker Flags
- add AlgoSdk.framework to project embedded binaries Project -> General -> Embedded Binaries
- add AlgoSdk.framework from ios/ folder
- add following to info.plist

```plist
<key>UISupportedExternalAccessoryProtocols</key>
<array>
    <string>com.neurosky.thinkgear</string>
</array>
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
</array>

```