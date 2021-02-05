# Flutter Summernote

Text Editor in Flutter for Android and iOS to help free write WYSIWYG HTML code based on Summernote 0.8.18 javascript wrapper.

![demo example](https://github.com/chandrabezzo/flutter_summernote/blob/master/screenshoot/home.png) ![demo example](https://github.com/chandrabezzo/flutter_summernote/blob/master/screenshoot/attach.png)

# NOTICE
> This package dependent to the [Official WebView Plugin](https://pub.dev/packages/webview_flutter). In this package can't add image, video, or another file using editor toolbar.
> To handle attach image this package give you another solution using image [Image Picker](https://pub.dev/packages/image_picker) at bottom of editor.
> This package can't use enableinteractiveSelection from TextField, to handle that this package give you another solution using copy paste at bottom of editor.
> Thank you for all your support.

## Setup

add ```flutter_summernote: ^latest``` as deppendecy to pubspec.yaml

### iOS

Add the following keys to your Info.plist file, located in <project root>/ios/Runner/Info.plist:

```
    <key>io.flutter.embedded_views_preview</key>
    <true/>

    <key>NSCameraUsageDescription</key>
    <string>Used to demonstrate image picker plugin</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>Used to capture audio for image picker plugin</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Used to demonstrate image picker plugin</string>

    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
         <true/>
    </dict>
```

### Usage

1. import flutter html editor
```
    import 'package:flutter_summernote/flutter_summernote.dart';
```

2. Create Global key from HTML Editor State
```
    GlobalKey<FlutterSummernoteState> _keyEditor = GlobalKey();
```

3. Add HTML Editor to widget
```
    FlutterSummernote(
        hint: "Your text here...",
        key: _keyEditor
    ),
    FlutterSummernote(
        hint: "Your text here...",
        key: _keyEditor,
        customToolbar: """
            [
                ['style', ['bold', 'italic', 'underline', 'clear']],
                ['font', ['strikethrough', 'superscript', 'subscript']]
            ]"""
    )
```

4. Get text from Html Editor
```
    final _etEditor = await keyEditor.currentState.getText();
```


### Avalaible option parameters

Parameter | Type | Default | Description
------------ | ------------- | ------------- | -------------
**key** | GlobalKey<HtmlEditorState> | **required** | for get method & reset
**value** | String | empty | initiate text content for text editor
**height** | double | 380 | height of text editor
**decoration** | BoxDecoration | empty | Decoration editor
**widthImage** | String | 100% | width of image picker
**hint** | String | empty | Placeholder hint text
**customToolbar** | String | empty | Add all available [Toolbar](https://summernote.org/deep-dive/#custom-toolbar-popover). Don't use insert (video & picture), please use **hasAttachment** option.
**customPopover** | String | empty | Add all available [Popover](https://summernote.org/deep-dive/#custom-toolbar-popover) (the same paragraph as for toolbar, but below)
**hasAttachment** | Boolean | false | Use this option if you want to show or hide attachment button
**showBottomToolbar** | Boolean | false | Use this option if you want to show or hide bottom toolbar
**returnContent** | Function | null | Use this callback to return text content on `await keyEditor.currentState.getText()` function call.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
