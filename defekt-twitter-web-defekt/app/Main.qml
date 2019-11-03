import QtQuick 2.9
import Ubuntu.Components 1.3
import QtQuick.Window 2.2
import Morph.Web 0.1
import QtWebEngine 1.7
import Qt.labs.settings 1.0
import QtSystemInfo 5.5
import Ubuntu.Content 1.3
//import "ContentPickerDialog.qml"

MainView {
  id:window
  //
  // ScreenSaver {
  //   id: screenSaver
  //   screenSaverEnabled: !(Qt.application.active)
  // }

  objectName: "mainView"
  theme.name: "Ubuntu.Components.Themes.SuruDark"
  backgroundColor: "transparent"
  applicationName: "twitter-web.ste-kal"

  property string myTabletUrl: "http://twitter.com"
  property string myMobileUrl: "http://m.twitter.com"
  property string myTabletUA: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/67.0.3396.99 Chrome/67.0.3396.99 Safari/537.36"
  property string myMobileUA: "Mozilla/5.0 (Linux; Android 8.0.0; Pixel Build/OPR3.170623.007) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.98 Mobile Safari/537.36"

  property string myUrl: (Screen.devicePixelRatio == 1.625) ? myTabletUrl : myMobileUrl
  //property string myUrl: "http://www.tagesanzeiger.ch"
  property string myUA: (Screen.devicePixelRatio == 1.625) ? myTabletUA : myMobileUA
  //"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/67.0.3396.99 Chrome/67.0.3396.99 Safari/537.36"
  Arguments {
    id: args

    Argument {
      name: 'url'
      help: i18n.tr('Incoming Call from URL')
      required: false
      valueNames: ['URL']
    }
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
    settings.pluginsEnabled: true

    property var currentWebview: webview

    onFullScreenRequested: function(request) {
      mainview.fullScreenRequested(request.toggleOn);
      nav.visible = !nav.visible
      request.accept();
    }
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
      centerIn: parent.verticalCenter
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
  }

  Connections {
    target: UriHandler
    onOpened: {
      console.log('Open from UriHandler')

      if (uris.length > 0) {
        console.log('Incoming call from UriHandler ' + uris[0]);
        showIncomingCall(uris[0]);
      }
    }
  }

  Connections {
    target: ContentHub
    onImportRequested: {
      var filePath = String(transfer.items[0].url).replace('file://', '')
      print("Should import file", filePath)
      var fileName = filePath.split("/").pop();
      var popup = PopupUtils.open(installQuestion, root, {fileName: fileName});
      popup.accepted.connect(function() {
        contentHubInstallInProgress = true;
        PlatformIntegration.clickInstaller.installPackage(filePath)
      })
    }
  }

	property var activeTransfer

	property var url
	property var handler
	property var contentType
  contentType: ContentType.Pictures
  handler: ContentHandler.Source
  signal cancel()
  signal imported(string fileUrl)

  ContentPeerPicker {
    anchors { fill: parent; topMargin: picker.header.height }
    visible: parent.visible
    showTitle: false
    contentType: picker.contentType //ContentType.Pictures
    handler: picker.handler //ContentHandler.Source

    onPeerSelected: {
      peer.selectionType = ContentTransfer.Single
      picker.activeTransfer = peer.request()
      picker.activeTransfer.stateChanged.connect(function() {
        if (picker.activeTransfer.state === ContentTransfer.InProgress) {
          console.log("In progress");
          picker.activeTransfer.items = picker.activeTransfer.items[0].url = url;
          picker.activeTransfer.state = ContentTransfer.Charged;
        }
        if (picker.activeTransfer.state === ContentTransfer.Charged) {
          console.log("Charged");
          picker.imported(picker.activeTransfer.items[0].url)
          console.log(picker.activeTransfer.items[0].url)
          picker.activeTransfer = null
        }
      })
    }


    onCancelPressed: {
        pageStack.pop()
    }
  }



}
