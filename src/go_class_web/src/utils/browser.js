/**
 *
 * @param {参数} options
 * @param {成功回调} success
 * @param {错误回调} error
 * @returns {Promise<MediaStream>|void}
 */

export function getUserMedia(options, success, error) {
  if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
    return (
        navigator.mediaDevices
            .getUserMedia(options)
            .then(success)
            .catch(error)
    )
  }

  const getUserMedia = navigator.getUserMedia
      || navigator.webkitGetUserMedia
      || navigator.mozGetUserMedia
      || navigator.msGetUserMedia
  return getUserMedia(options, success, error)
}

export const isSafariBrowser = /Safari/.test(navigator.userAgent) && !/Chrome/.test(navigator.userAgent)

export const isFirefox = /Firefox/.test(navigator.userAgent)
