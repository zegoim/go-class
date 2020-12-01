const WebLiveInterface = {
  on: [
      'roomUserUpdate',
      'roomStreamUpdate',
      'remoteCameraStatusUpdate',
      'publisherStateUpdate',
      'roomStateUpdate',
  ],
  createStream () {},           // done
  startPublishingStream () {},  // done
  startPlayingStream () {},     // done
  mutePublishStreamAudio () {}, // done
  mutePublishStreamVideo () {}, // done
  setDebugVerbose () {},        // done
  loginRoom () {},              // done
  enumDevices () {},            // done
  useVideoDevice () {},         // done
  useAudioDevice () {},         // done
  stopPlayingStream () {},      // done
  stopPublishingStream () {},   // done
}

const ElectronLiveInterface = {
  onUserUpdate () {},
  onStreamUpdated () {},
  onRemoteCameraStatusUpdate () {},
  onPublishStateUpdate () {},
  muteAudioPublish () {},
  muteVideoPublish () {},
  loginRoom () {},
  enumDevices: {
    getAudioDeviceList () {},
    getVideoDeviceList () {}
  },
  setVideoDevice () {},
  setAudioDevice () {},
  stopPlayingStream () {},
  stopPublishing () {}
}


export {
  ElectronLiveInterface,
  WebLiveInterface,
}
