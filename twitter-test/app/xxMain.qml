import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtQuick.Window 2.2
import Morph.Web 0.1
import "UCSComponents"
import "."
import QtWebEngine 1.7
import Qt.labs.settings 1.0
import QtSystemInfo 5.5
import QtMultimedia 5.8
import Ubuntu.UnityWebApps 0.1 as UnityWebApps
import Ubuntu.Content 1.3

MainView {
  id:window
  //
  // ScreenSaver {
  //   id: screenSaver
  //   screenSaverEnabled: !(Qt.application.active)
  // }

  objectName: "mainView"
  theme.name: "Ubuntu.Components.Themes.Ambiance"
  backgroundColor: "transparent"
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


  property string myTabletUrl: "https://twitter.com"
  property string myMobileUrl: "https://twitter.com"
  property string myTabletUA: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/67.0.3396.99 Chrome/67.0.3396.99 Safari/537.36"
  property string myMobileUA: "Mozilla/5.0 (Linux; Android 8.0.0; Pixel Build/OPR3.170623.007) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.98 Mobile Safari/537.36"

  property string myUrl: (Screen.devicePixelRatio == 1.625) ? myTabletUrl : myMobileUrl
  property string myUA: (Screen.devicePixelRatio == 1.625) ? myTabletUA : myMobileUA

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
      anchors {
        fill: parent
      }
      //settings.localStorageEnabled: true
      //settings.allowFileAccessFromFileUrls: true
      //settings.allowUniversalAccessFromFileUrls: true
      //settings.appCacheEnabled: true
      settings.javascriptCanAccessClipboard: true
      settings.fullScreenSupportEnabled: false
      property var currentWebview: webview
      settings.pluginsEnabled: true

      property string test: writeToLog("DEBUG","my URL:", myUrl);
      property string test2: writeToLog("DEBUG","PixelRatio:", Screen.devicePixelRatio);
      function writeToLog(mylevel,mytext, mymessage){
        console.log("["+mylevel+"]  "+mytext+" "+mymessage)
        return(true);
      }

      profile:  WebEngineProfile {
        id: webContext
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        property alias dataPath: webContext.persistentStoragePath
        dataPath: dataLocation
        httpUserAgent: myUA
      }

      anchors {
        fill:parent
        right: parent.right
        bottom: parent.bottom
        margins: units.gu(0)
        bottomMargin: units.gu(6)
      }


      url: myUrl
      userScripts: [
        WebEngineScript {
          injectionPoint: WebEngineScript.DocumentCreation
          worldId: WebEngineScript.MainWorld
          name: "QWebChannel"
          sourceUrl: "ubuntutheme.js"
        }
      ]

      onJavaScriptDialogRequested: function(request) {
        switch (request.type) {
          case JavaScriptDialogRequest.DialogTypeAlert:
            request.accepted = true;
            console.log("[DEBUG]  AlertDialog ");
            var alertDialog = PopupUtils.open(Qt.resolvedUrl("AlertDialog.qml"));
            alertDialog.message = request.message;
            alertDialog.accept.connect(request.dialogAccept);
          break;

          case JavaScriptDialogRequest.DialogTypeConfirm:
            request.accepted = true;
            console.log("[DEBUG]  ConfirmDialog ");
            var confirmDialog = PopupUtils.open(Qt.resolvedUrl("ConfirmDialog.qml"));
            confirmDialog.message = request.message;
            confirmDialog.accept.connect(request.dialogAccept);
            confirmDialog.reject.connect(request.dialogReject);
          break;

          case JavaScriptDialogRequest.DialogTypePrompt:
            request.accepted = true;
            console.log("[DEBUG]  PromptDialog ");
            var promptDialog = PopupUtils.open(Qt.resolvedUrl("PromptDialog.qml"));
            promptDialog.message = request.message;
            promptDialog.defaultValue = request.defaultText;
            promptDialog.accept.connect(request.dialogAccept);
            promptDialog.reject.connect(request.dialogReject);
          break;

          case 3:
            request.accepted = true;
            console.log("[DEBUG]  BeforeUnloadDialog ");
            var beforeUnloadDialog = PopupUtils.open(Qt.resolvedUrl("BeforeUnloadDialog.qml"));
            beforeUnloadDialog.message = request.message;
            beforeUnloadDialog.accept.connect(request.dialogAccept);
            beforeUnloadDialog.reject.connect(request.dialogReject);
          break;
        }

      }

      onFileDialogRequested: function(request) {

        switch (request.mode) {
          case FileDialogRequest.FileModeOpen:
            request.accepted = true;
            console.log("[DEBUG]  CP Single ");
            var fileDialogSingle = PopupUtils.open(Qt.resolvedUrl("ContentPickerDialog.qml"));
            fileDialogSingle.allowMultipleFiles = false;
            fileDialogSingle.accept.connect(request.dialogAccept);
            fileDialogSingle.reject.connect(request.dialogReject);
          break;

          case FileDialogRequest.FileModeOpenMultiple:
            request.accepted = true;
            console.log("[DEBUG]  CP Multiple ");
            var fileDialogMultiple = PopupUtils.open(Qt.resolvedUrl("ContentPickerDialog.qml"));
            fileDialogMultiple.allowMultipleFiles = true;
            fileDialogMultiple.accept.connect(request.dialogAccept);
            fileDialogMultiple.reject.connect(request.dialogReject);
          break;

          case FilealogRequest.FileModeUploadFolder:
          case FileDialogRequest.FileModeSave:
            request.accepted = false;
            console.log("[DEBUG]  CP false ");
          break;
        }

      }
      Loader {
          id: contentHandlerLoader
          source: "ContentHandler.qml"
          asynchronous: true
      }

      Loader {
          id: downloadLoader
          source: "Downloader.qml"
          asynchronous: true
      }

      Loader {
          id: filePickerLoader
          source: "ContentPickerDialog.qml"
          asynchronous: true
      }

      Loader {
          id: downloadDialogLoader
          source: "ContentDownloadDialog.qml"
          asynchronous: true
      }


    }
  }
  // Component {
  //      id: pickerComponent
  //      PickerDialog {}
  // }
}
