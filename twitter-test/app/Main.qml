import QtQuick 2.9
import QtQuick.Window 2.2
import Morph.Web 0.1
import QtWebEngine 1.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.UnityWebApps 0.1 as UnityWebApps
import Ubuntu.Content 1.1
import QtMultimedia 5.8
import QtSystemInfo 5.0
//import "components"
//import "actions" as Actions
import "."

MainView {
  id: root
  objectName: "mainView"
  theme.name: "Ubuntu.Components.Themes.Ambiance"

  focus: true

  anchors {
      fill: parent
  }

  applicationName: "twitter-web.ste-kal"
  anchorToKeyboard: true
  automaticOrientation: true
  property bool blockOpenExternalUrls: false
  property bool runningLocalApplication: false
  property bool openExternalUrlInOverlay: false
  property bool popupBlockerEnabled: true
  property bool fullscreen: false

  Page {
    id: page
    header: Rectangle {
        color: "#000000"
        width: parent.width
        height: units.dp(.5)
        z: 1
    }

    anchors {
        fill: parent
        bottom: parent.bottom
    }

    WebEngineView {
      id: webview

      property var currentWebview: webview

      settings.fullScreenSupportEnabled: false
      property string myTabletUrl: "https://twitter.com"
      property string myMobileUrl: "https://m.twitter.com"

      property string myUrl: (Screen.devicePixelRatio == 1.625) ? myTabletUrl : myMobileUrl

      property string test: writeToLog("DEBUG","my URL:", myUrl);
      property string test2: writeToLog("DEBUG","PixelRatio:", Screen.devicePixelRatio);

      function writeToLog(mylevel,mytext, mymessage){
        console.log("["+mylevel+"]  "+mytext+" "+mymessage)
        return(true);
      }

      WebEngineProfile {
        id: webContext

        property alias userAgent: webContext.httpUserAgent
        property alias dataPath: webContext.persistentStoragePath

        dataPath: dataLocation

        property string myTabletUA: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/67.0.3396.99 Chrome/67.0.3396.99 Safari/537.36"
        property string myMobileUA: "Mozilla/5.0 (Linux; Android 8.0.0; Pixel Build/OPR3.170623.007) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.98 Mobile Safari/537.36"

        property string myUA: (Screen.devicePixelRatio == 1.625) ? myTabletUA : myMobileUA

        property string test3: webview.writeToLog("DEBUG","my UA:", myUA);

        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        userAgent: myUA
      }

      anchors {
        fill: parent
        right: parent.right
        bottom: parent.bottom
        margins: units.gu(0)
        bottomMargin: units.gu(6)
      }
          //zoomFactor: 2.5
      url: myUrl

      onFileDialogRequested: function(request) {
        console.log("[DEBUG]  File Dialog Requested: "+request)
        switch (request.mode) {
          case FileDialogRequest.FileModeOpen:
            request.accepted = true;
            var fileDialogSingle = PopupUtils.open(Qt.resolvedUrl("ContentPickerDialog.qml"));
            fileDialogSingle.allowMultipleFiles = false;
            fileDialogSingle.accept.connect(request.dialogAccept);
            fileDialogSingle.reject.connect(request.dialogReject);
            break;

          case FileDialogRequest.FileModeOpenMultiple:
            request.accepted = true;
            var fileDialogMultiple = PopupUtils.open(Qt.resolvedUrl("ContentPickerDialog.qml"));
            fileDialogMultiple.allowMultipleFiles = true;
            fileDialogMultiple.accept.connect(request.dialogAccept);
            fileDialogMultiple.reject.connect(request.dialogReject);
            break;

          case FilealogRequest.FileModeUploadFolder:
          case FileDialogRequest.FileModeSave:
            request.accepted = false;
            break;
        }
      }

      onNewViewRequested: function(request) {
        Qt.openUrlExternally(request.requestedUrl);
      }

      Loader {
        id: contentHandlerLoader
        property string test4: console.log("[DEBUG] contentHandlerLoader")
        source: "ContentHandler.qml"
        asynchronous: true
      }

      // Loader {
      //     id: downloadLoader
      //     source: "Downloader.qml"
      //     asynchronous: true
      // }

      Loader {
        id: filePickerLoader
        property string test5: console.log("[DEBUG] filePickerLoader")
        source: "ContentPickerDialog.qml"
        asynchronous: true
      }

      Loader {
        id: downloadDialogLoader
        property string test6: console.log("[DEBUG] downloadDialogLoader")
        source: "ContentDownloadDialog.qml"
        asynchronous: true
      }
    }


  }
}
