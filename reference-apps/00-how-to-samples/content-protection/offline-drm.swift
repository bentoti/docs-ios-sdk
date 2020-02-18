// 
// 1 - Download
// 
// The snippet below downloads a Fairplay HLS asset.

//example source
public static var sourceToBeCached: SourceDescription {
    let src = "https://source.m3u8"
    let merchant = "merchant"
    let userId = "userId"
    let sessionId = "sessionId"
    let streamType = "application/x-mpegurl"
    let drmConfig = DRMTodayDRMConfiguration(
                        licenseAcquisitionURL: "https://lic.staging.drmtoday.com/license-server-fairplay/",
                        certificateURL: "https://lic.staging.drmtoday.com/license-server-fairplay/cert/",
                        userId: userId,
                        sessionId: sessionId,
                        merchant: merchant
                    )
    return SourceDescription(source: TypedSource(src: src, type: streamType, drm: drmConfig))
} 
 
//example cache call
var cachingTask: CachingTask?
 
func cacheSource(SourceDescription source, Date expirationDate) {
            cachingTask = THEOplayer.cache.createTask(source: source, parameters: CachingParameters(expirationDate: expirationDate))
            if cachingTask != nil {
                _ = cachingTask!.addEventListener(type: CachingTaskEventTypes.STATE_CHANGE) { event in
                    print("Received state change on caching task \(self.cachingTask!.source.sources[0].src) Status: \(self.cachingTask!.status)")
                }
                _ = cachingTask!.addEventListener(type: CachingTaskEventTypes.PROGRESS) { event in
                    print("Received progress on caching task \(self.cachingTask!.source.sources[0].src) Cached: ")
                    for timeRange in self.cachingTask!.cached {
                        print(timeRange.start, timeRange.end)
                    }
                }
                cachingTask.start()
            }
}


//
// 2 - Playback
// 
// To playback cached material:

func playSourceFromCache(SourceDescription source) {
    theoplayer.source = source
    theoplayer.play();
}

// 
// 3 - Pause and restart
//
// A caching task can be paused and restarted through the task object itself.

let typedSource = TypedSource(src: "https://cdn.theoplayer.com/video/elephants-dream/playlist.m3u8", type: "application/x-mpegurl")
let sourceDescription = SourceDescription(source : typedSource)
         
let cachingTask = THEOplayer.cache.createTask(source: sourceDescription, parameters: nil)
         
// starting a caching task
cachingTask?.start()
         
// pausing a caching task
cachingTask?.pause()
         
// resuming a caching task
cachingTask?.start()


//
// 4 - Check size and progression
//
// After creating a caching task, it is possible to check an estimate for the total size of the caching task on disk, and the current progression in bytes (stored).

let typedSource = TypedSource(src: "https://cdn.theoplayer.com/video/elephants-dream/playlist.m3u8", type: "application/x-mpegurl")
let sourceDescription = SourceDescription(source : typedSource)

let cachingTask = THEOplayer.cache.createTask(source: sourceDescription, parameters: nil)

// starting a caching task
cachingTask?.start()

if let cachingTask = cachingTask {
    // Listen for state change events
    _ = cachingTask.addEventListener(type: CachingTaskEventTypes.STATE_CHANGE, listener: { event in
        print(cachingTask.status)
    })
    // Listen for progress events
    _ = cachingTask.addEventListener(type: CachingTaskEventTypes.PROGRESS, listener: { event in
        // percentage cached
        print(cachingTask.percentageCached)
        // total bytes cached
        print(cachingTask.bytesCached)
        // the amount of seconds cached
        print(cachingTask.secondsCached)
        // the range that is cached
        for timeRange in cachingTask.cached {
            print(timeRange.start, timeRange.end)
        }
    })
}


//
// 5 - Listing and restarting caching tasks
// 
// To be completed


//
// 6 - Delete
//
// The snippet below deletes all cached assets

func cleanCache() {
    for cachingTask in THEOplayer.cache.tasks {
        print("Will remove caching task \(cachingTask.source.sources[0].src)")
        cachingTask.remove()
    }
}


//
// 7 - Renew a DRM license
//
// Renew a DRM license with specific DRM configuration

func renewLicense() {
    let newDrmConfig = DRMTodayDRMConfiguration(
                            licenseAcquisitionURL: "https://lic.staging.drmtoday.com/license-server-fairplay/",
                            certificateURL: "https://lic.staging.drmtoday.com/license-server-fairplay/cert/",
                            userId: userId,
                            sessionId: sessionId,
                            merchant: merchant
                        )
 
    cachingTask.license.renew(newDrmConfig) // or we can renew it with the old drmConfig too: cachingTask.license.renew()
}

// 
// 8 - Handle redirected manifest
// 

// cache source
 
      let url = URL(string: "MASTER_MANIFEST_URL_THAT_GETS_REDIRECTED")

      let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in

          Streams.SAVED_REDIRECTED_URL = (response?.url)!
          cachingTaskSource.sources[0].src = Streams.SAVED_REDIRECTED_URL!
          self.cachingTask = THEOplayer.cache.createTask(source: cachingTaskSource, parameters: CachingParameters(expirationDate: Date.distantFuture, bandwidth: cachingTaskBandwidth))
          if self.cachingTask != nil {
              _ = self.cachingTask!.addEventListener(type: CachingTaskEventTypes.STATE_CHANGE) { event in
                  if let cachingTask = self.cachingTask {
                      print("Received state change on caching task \(cachingTask.source.sources[0].src) Status: \(cachingTask.status)")
                  }
              }
              _ = self.cachingTask!.addEventListener(type: CachingTaskEventTypes.PROGRESS) { event in
                  print("Received progress on caching task \(self.cachingTask!.source.sources[0].src) Cached: ")
                  for timeRange in self.cachingTask!.cached {
                      print(timeRange.start, timeRange.end)
                  }
              }
              print("Did create caching task \(self.cachingTask!.source.sources[0].src)")
          }  
      }
      task.resume()
 
// playback of cached source
 
      var source = cachingTaskSource
      source.sources[0].src = Streams.SAVED_REDIRECTED_URL!
      theoplayer.source = source
      theoplayer.play()
