
/**
 * DSB Helper Functions
 *
 * ctime: 2015-04-27 /TR
 * mtime: 2016-01-04 /TR
 */

/* global debugging via console */
var debug = 0;
function log() {
  if (window.console && console.log && debug)
    console.log('[dsb] ' + Array.prototype.join.call(arguments,' '));
}

/**
 * dsb_scaler(id) - einen Bereich via scaling zoomen
 *
 * /TR 2015-05-01
 */
function dsb_scaler(id, percent) {
  var obj = document.getElementById(id);
  if (obj == null) return;

  var x = window.innerWidth / obj.clientWidth;
  var y = window.innerHeight / obj.clientHeight;
  var r = Math.min(x, y) * (percent / 100);
  // log("x="+x+" y="+y+" r="+r+" percent="+percent);

  /* scale it */
  var s="-ms-zoom:"+r+"; transform: scale("+r+"); transform-origin: 0 0;";
  s += ""
  if (typeof obj.setAttribute === "function") obj.setAttribute('style', s);
  else if (typeof obj.style.setAttribute === "object") obj.style.setAttribute('cssText', s);

  return;
}
/**************************************************************************/

/**
 * dsb_checkreload(datei)
 * - sobald sich die remote datei ändert, reload...
 * - sobald sich am client die auflösung ändert, reload...
 *
 * /TR 2015-12-25
 */
function dsb_checkreload(url, timeout) {
  var cW = window.innerWidth;
  var cH = window.innerHeight;
  var first = 1;
  var dataOld;

  setInterval(function() {
    $.ajax({url: url, success: check_site, cache: false});
  }, timeout * 1000);

  function check_site(data, status) {
    if (status !== "success") return;

    if (first) {
      first = 0;
      dataOld = data;
    }

    if (cW != window.innerWidth || cH != window.innerHeight || data != dataOld) {
      // log("reload...")
      location.reload();
    }
  }
}
/**************************************************************************/

/**
 * fx_before()
 *
 * - übernimmt das zentrieren (vertikal und horizontal)
 * /TR 2015-12-24
 */
function fx_before(curr, next, opts, forwardFlag) {
  var alt = next.alt.split(",");

  var obj = document.getElementById("slideshow");
  if (obj == null) return;
  obj.style.top = alt[0] + "px";
  obj.style.left = alt[1] + "px";

  if (alt[2]) {
    var video = document.getElementById(alt[2]);
    $('#slideshow').cycle('pause');
    // log("playing video = " + video.id);
    video.currentTime = 0;
    video.play();

    // log("setTimeout() = " + video.duration * 1000);
    setTimeout(SlideNext, video.duration * 1000 + 500);
  }

  function SlideNext() {
    // log("SlideShow goes on...");
    video.pause();
    $('#slideshow').cycle('resume', true);
  }
}

/**
 * dsb_slideshow(fxSlideShow, percent)
 *
 * fxSlideShow: function, which is started whan all files got cached
 * percent: all files are centered and scaled to this percentage to sscreen
 *
 * /TR 2015-12-24
 */
function dsb_slideshow(fxSlideShow, percent) {

  // total: alle bilder und videos zusammen
  var images = $('img');
  var videos = $('video');
  total = images.length + videos.length;

  // resize images to fit into the frame
  function imageLoaded() {
    var img = $(this)[0];

    // log("IF loaded: " + img.src);
    // log("IF nImage: " + img.naturalWidth + " x " + img.naturalHeight);
    var x = $(window).width() / img.naturalWidth;
    var y = $(window).height() / img.naturalHeight;
    var w = Math.min(x, y) * img.naturalWidth * percent / 100;
    img.width = parseInt(w);

    // danach zentrieren, via left und top vom id = #content (fx_before)
    var top = ($(window).height() - img.clientHeight) / 2;
    var left = ($(window).width() - img.clientWidth) / 2;
    img.alt = parseInt(top) + "," + parseInt(left);

    total--;
    if (total == 0) fxSlideShow();
    // log("IF Ende: " + img.width + " x " + img.height);
  }

  // resize videos to fit into the frame
  function videoLoaded() {
    var video = $(this)[0];

    // log("VF loaded: " + video.src);
    // log("VF duration: " + video.duration);
    // log("VF vSize: " + video.videoWidth + " x " + video.videoHeight);
    var x = $(window).width() / video.videoWidth;
    var y = $(window).height() / video.videoHeight;
    h = Math.min(x, y) * video.videoHeight * percent / 100;
    w = Math.min(x, y) * video.videoWidth * percent / 100;
    video.width = parseInt(w);

    // danach zentrieren, via left und top vom id = #content (fx_before)
    var top = ($(window).height() - h) / 2;
    var left = ($(window).width() - w) / 2;
    // alt tag bekommt:
    // 1) top
    // 2) left
    // 3) video id
    video.alt = parseInt(top) + "," + parseInt(left) + "," + video.id;

    total--;
    if (total == 0) fxSlideShow();
    // log("VF Ende: " + video.width + " x " + video.height);
  }

  $('img').each(function() {
    if (this.complete) {
      imageLoaded.call(this);
    } else {
      $(this).one('load', imageLoaded);
    }
  });

  $('video').bind('progress', function() {
    videoLoaded.call(this);
  });
}