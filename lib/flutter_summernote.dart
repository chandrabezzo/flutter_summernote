library flutter_summernote;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:webview_flutter/webview_flutter.dart';

/*
* Created by: Chandra Abdul Fattah on 13 July 2020
* Inspired from: https://github.com/xrb21/flutter-html-editor
* link:
* */

class FlutterSummernote extends StatefulWidget {
  final String? value;
  final double? height;
  final BoxDecoration? decoration;
  final String widthImage;
  final String? hint;
  final String? customToolbar;
  final String? customPopover;
  final bool hasAttachment;
  final bool showBottomToolbar;
  final Function(String)? returnContent;

  const FlutterSummernote({
    Key? key,
    this.value,
    this.height,
    this.decoration,
    this.widthImage = '100%',
    this.hint,
    this.customToolbar,
    this.customPopover,
    this.hasAttachment = false,
    this.showBottomToolbar = true,
    this.returnContent,
  }) : super(key: key);

  @override
  FlutterSummernoteState createState() => FlutterSummernoteState();
}

class FlutterSummernoteState extends State<FlutterSummernote> {
  String text = '';
  late String _page;
  final Key _mapKey = UniqueKey();
  final _imagePicker = ImagePicker();
  late bool _hasAttachment;

  late final WebViewController? _webViewController;

  void handleRequest(HttpRequest request) {
    try {
      if (request.method == 'GET' &&
          request.uri.queryParameters['query'] == 'getRawTeXHTML') {
      } else {}
    } catch (e) {
      debugPrint('Exception in handleRequest: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    _page = _initPage(widget.customToolbar, widget.customPopover);
    _hasAttachment = widget.hasAttachment;

    _webViewController = WebViewController();

    _webViewController!.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webViewController!.addJavaScriptChannel('GetTextSummernote',
        onMessageReceived: (JavaScriptMessage message) {
      String isi = message.message;
      if (isi.isEmpty ||
          isi == '<p></p>' ||
          isi == '<p><br></p>' ||
          isi == '<p><br/></p>') {
        isi = '';
      }
      setState(() {
        text = isi;
      });
      if (widget.returnContent != null) {
        widget.returnContent!(text);
      }
    });

    _webViewController!
        .setNavigationDelegate(NavigationDelegate(onPageFinished: (String url) {
      if (widget.hint != null) {
        setHint(widget.hint);
      } else {
        setHint('');
      }

      setFullContainer();
      if (widget.value != null) {
        setText(widget.value!);
      }
    }));

    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(_page));
    _webViewController!
        .loadRequest(Uri.parse('data:text/html;base64,$contentBase64'));
  }

  @override
  void dispose() {
    if (_webViewController != null) {
      _webViewController = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? MediaQuery.of(context).size.height,
      decoration: widget.decoration ??
          BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            border: Border.all(color: const Color(0xffececec), width: 1),
          ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: WebViewWidget(key: _mapKey, controller: _webViewController!),
          ),
          Visibility(
            visible: widget.showBottomToolbar,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(children: _generateBottomToolbar(context)),
            ),
          )
        ],
      ),
    );
  }

  /// Method [_generateBottomToolbar] to render bottom toolbar that declared
  /// by user
  List<Widget> _generateBottomToolbar(BuildContext context) {
    var toolbar = [
      Expanded(
        child: GestureDetector(
          onTap: () async {
            String data = await getText();
            Clipboard.setData(ClipboardData(text: data));
          },
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[Icon(Icons.content_copy), Text('Copy')]),
        ),
      ),
      Expanded(
        child: GestureDetector(
          onTap: () async {
            ClipboardData data = await (Clipboard.getData(Clipboard.kTextPlain)
                as FutureOr<ClipboardData>);

            String txtIsi = data.text!
                .replaceAll("'", '\\"')
                .replaceAll('"', '\\"')
                .replaceAll('[', '\\[')
                .replaceAll(']', '\\]')
                .replaceAll('\n', '<br/>')
                .replaceAll('\n\n', '<br/>')
                .replaceAll('\r', ' ')
                .replaceAll('\r\n', ' ');
            String txt = "\$('.note-editable').append( '$txtIsi');";
            _webViewController!.runJavaScript(txt);
          },
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.content_paste),
                Text('Paste'),
              ]),
        ),
      )
    ];

    if (_hasAttachment) {
      //add attachment widget
      toolbar.insert(
          0,
          Expanded(
            child: GestureDetector(
              onTap: () => _attach(context),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Icon(Icons.attach_file),
                    Text('Attach')
                  ]),
            ),
          ));
    }

    return toolbar;
  }

  /// Call [getText] to get current value from summernote form
  Future<String> getText() async {
    await _webViewController?.runJavaScript(
      'setTimeout(function(){GetTextSummernote.postMessage(document.'
      'getElementsByClassName(\'note-editable\')[0].innerHTML)}, 0);',
    );
    return text;
  }

  /// Call [setText] to set current value in summernote form
  Future<void> setText(String v) async {
    String txtIsi = v
        .replaceAll("'", '\\"')
        .replaceAll('"', '\\"')
        .replaceAll('[', '\\[')
        .replaceAll(']', '\\]')
        .replaceAll('\n', '<br/>')
        .replaceAll('\n\n', '<br/>')
        .replaceAll('\r', ' ')
        .replaceAll('\r\n', ' ');
    String txt =
        'document.getElementsByClassName(\'note-editable\')[0].innerHTML'
        ' = \'$txtIsi\';';
    _webViewController!.runJavaScript(txt);
  }

  /// [setFullContainer] to set full summernote form
  void setFullContainer() {
    _webViewController!
        .runJavaScript('\$("#summernote").summernote("fullscreen.toggle");');
  }

  /// [setFocus] to focus summernote form
  void setFocus() {
    _webViewController!.runJavaScript("\$('#summernote').summernote('focus');");
  }

  /// [setEmpty] called to reset summmernote form
  void setEmpty() {
    _webViewController!.runJavaScript("\$('#summernote').summernote('reset');");
  }

  /// [setHint] to give placeholder
  void setHint(String? text) {
    String hint = '\$(".note-placeholder").html("$text");';
    _webViewController!.runJavaScript('setTimeout(function(){$hint}, 0);');
  }

  /// [widgetIcon] to simplify create a button icon with text
  Widget widgetIcon(IconData icon, String title, {Function? onTap}) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: Colors.black38,
            size: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
            ),
          )
        ],
      ),
    );
  }

  /// [_initPage] to initial summernote form
  String _initPage(String? customToolbar, String? customPopover) {
    String toolbar;
    if (customToolbar == null) {
      toolbar = _defaultToolbar;
    } else {
      toolbar = customToolbar;
    }
    String popover;
    if (customPopover == null) {
      popover = _defaultPopover;
    } else {
      popover = customPopover;
    }

    return '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Summernote</title>
    <script src="https://code.jquery.com/jquery-3.5.1.min.js" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>

    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>

    <link href="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-bs4.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-bs4.min.js"></script>
    </head>
    <body>
    <div id="summernote" contenteditable="true"></div>
    <script type="text/javascript">
      \$("#summernote").summernote({
        placeholder: 'Your text here...',
        tabsize: 2,
        toolbar: $toolbar,
        popover: {$popover}
      });
    </script>
    </body>
    </html>
    ''';
  }

  final String _defaultPopover = """
    image: [
      ['image', ['resizeFull', 'resizeHalf', 'resizeQuarter', 'resizeNone']],
      ['float', ['floatLeft', 'floatRight', 'floatNone']],
      ['remove', ['removeMedia']]
    ],
    link: [
      ['link', ['linkDialogShow', 'unlink']]
    ],
    table: [
      ['add', ['addRowDown', 'addRowUp', 'addColLeft', 'addColRight']],
      ['delete', ['deleteRow', 'deleteCol', 'deleteTable']],
    ],
    air: [
      ['color', ['color']],
      ['font', ['bold', 'underline', 'clear']],
      ['para', ['ul', 'paragraph']],
      ['table', ['table']],
      ['insert', ['link', 'picture']]
    ]
""";

  final String _defaultToolbar = """
    [
      ['style', ['bold', 'italic', 'underline', 'clear']],
      ['font', ['strikethrough', 'superscript', 'subscript']],
      ['font', ['fontsize', 'fontname']],
      ['color', ['forecolor', 'backcolor']],
      ['para', ['ul', 'ol', 'paragraph']],
      ['height', ['height']],
      ['view', ['fullscreen']]
    ]
  """;

  /// [_attach] to create attached button
  void _attach(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              subtitle: const Text('Attach image from camera'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _getImage(true);
                if (image != null) _addImage(image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              subtitle: const Text('Attach image from gallery'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _getImage(false);
                if (image != null) _addImage(image);
              },
            ),
          ]);
        });
  }

  /// [_getImage] to get image from summernote
  Future<XFile?> _getImage(bool fromCamera) async {
    final picked = await _imagePicker.pickImage(
        source: (fromCamera) ? ImageSource.camera : ImageSource.gallery);
    if (picked != null) {
      return XFile(picked.path);
    } else {
      return null;
    }
  }

  /// [_addImage] to add image in summernote form
  void _addImage(XFile image) async {
    String filename = basename(image.path);
    List<int> imageBytes = await image.readAsBytes();
    String base64Image =
        '<img width="${widget.widthImage}" src="data:image/png;base64, '
        '${base64Encode(imageBytes)}" data-filename="$filename">';

    String txt = "\$('.note-editable').append( '$base64Image');";
    _webViewController!.runJavaScript(txt);
  }
}
