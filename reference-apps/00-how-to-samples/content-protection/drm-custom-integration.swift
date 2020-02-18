// let headers = [["<KEY>": "<VALUE>"]]
let drmConfiguration = FairPlayDRMConfiguration(
    licenseAcquisitionURL: "<LICENSE_KEY_URL_FAIRPLAY>",
    certificateURL: "<CERTIFICATE_URL>"
     // , headers: headers, licenseType: <LICENSE_TYPE>
)
let typedSource = TypedSource(src: "<HLS_STREAM_URL>", type: "application/x-mpegurl", drm: drmConfiguration)
let sourceDescription = SourceDescription(source: typedSource)
theoplayer.source = sourceDescription
