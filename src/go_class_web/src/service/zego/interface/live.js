const WebLiveInterface = function() {
  // on: [
  //     'roomUserUpdate',
  //     'roomStreamUpdate',
  //     'remoteCameraStatusUpdate',
  //     'publisherStateUpdate',
  //     'roomStateUpdate'
  // ],
  // createStream () {},           // done
  // startPublishingStream () {},  // done
  // startPlayingStream () {},     // done
  // mutePublishStreamAudio () {}, // done
  // mutePublishStreamVideo () {}, // done
  // setDebugVerbose () {},        // done
  // loginRoom () {},              // done
  // enumDevices () {},            // done
  // useVideoDevice () {},         // done
  // useAudioDevice () {},         // done
  // stopPlayingStream () {},      // done
  // stopPublishingStream () {},   // done
}

// eslint-disable-next-line
WebLiveInterface.prototype.on = function(eventName, cb) {}

const ElectronLiveInterface = function() {
  // onUserUpdate () {},
  // onStreamUpdated () {},
  // onRemoteCameraStatusUpdate () {},
  // onPublishStateUpdate () {},
  // muteAudioPublish () {},
  // muteVideoPublish () {},
  // loginRoom () {},
  // enumDevices: {
  //   getAudioDeviceList () {},
  //   getVideoDeviceList () {}
  // },
  // setVideoDevice () {},
  // setAudioDevice () {},
  // stopPlayingStream () {},
  // stopPublishing () {}
}

ElectronLiveInterface.prototype.loginRoom = function() {}

export { ElectronLiveInterface, WebLiveInterface }
