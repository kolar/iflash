(function (window, document, VK) {
  var readyBound = false,
      bindReady = function() {
        if (readyBound) return;
        readyBound = true;
        if (document.addEventListener) {
          document.addEventListener('DOMContentLoaded', function() {
            document.removeEventListener('DOMContentLoaded', arguments.callee, false);
            ready();
          }, false );
        } else if (document.attachEvent) {
          document.attachEvent('onreadystatechange', function() {
            if (document.readyState === 'complete') {
              document.detachEvent('onreadystatechange', arguments.callee);
              ready();
            }
          });
        }
        if (window.addEventListener) {
          window.addEventListener('load', ready, false);
        } else if (window.attachEvent) {
          window.attachEvent('onload', ready);
        } else {
          window.onload = ready;
        }
      },
      isReady = false,
      readyList = [],
      ready = function() {
        if (!isReady) {
          isReady = true;
          if (readyList) {
            var fn_temp = null;
            while (fn_temp = readyList.shift()) {
              fn_temp.call(document);
            }
            readyList = null;
          }
        }
      };
  function onDOMReady(fn) {
    bindReady();
    if (isReady) {
      fn.call(document);
    } else {
      readyList.push(fn);
    }
  };
  window.onDOMReady = onDOMReady;
  
  function extend() {
    var args = Array.prototype.slice.call(arguments), obj = args.shift();
    if (!args.length) return obj;
    for (var i=0, l=args.length; i<l; i++) {
      for (var key in args[i]) {
        obj[key] = args[i][key];
      }
    }
    return obj;
  }
  
  function ge(id) { return document.getElementById(id); }
  
  function getFlashVersion() {
    var version = 0, axon = 'ShockwaveFlash.ShockwaveFlash',
        wrapType = 'embed', wrapParam = 'type="application/x-shockwave-flash" ',
        escapeAttr = function(v) { return v.toString().replace('&', '&amp;').replace('"', '&quot;'); };
    if (navigator.plugins && navigator.mimeTypes.length) {
      var x = navigator.plugins['Shockwave Flash'];
      if (x && x.description) {
        var ver = x.description.replace(/([a-zA-Z]|\s)+/, '').replace(/(\s+r|\s+b[0-9]+)/, '.').split('.');
        version = ver[0] || 0;
      }
    } else {
      var _ua = navigator.userAgent.toLowerCase();
      if (_ua.indexOf('Windows CE') >= 0) {
        var axo = true, ver = 6;
        while (axo) {
          try {
            axo = new ActiveXObject(axon + '.' + ++ver);
            version = ver;
          } catch(e) {}
        }
      } else {
        try {
          var axo = new ActiveXObject(axon + '.7');
          version = axo.GetVariable('$version').split(' ')[1].split(',')[0] || 0;
        } catch (e) {}
      }
      wrapType = 'object';
      wrapParam = 'classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" ';
    }
    var wrapper = (wrapType == 'embed') ? function(opts, params) {
      params = extend({
        id: opts.id,
        name: opts.id,
        width: opts.width,
        height: opts.height,
        src: version >= opts.version ? opts.url : opts.express
      }, params);
      var paramsStr = [];
      for (var i in params) {
        var p = params[i];
        if (p !== undefined && p !== null) {
          paramsStr.push(i + '="' + escapeAttr(p) + '" ');
        }
      }
      return '<embed ' + wrapParam + paramsStr.join('') + '/>';
    } : function(opts, params) {
      params.movie = version >= opts.version ? opts.url : opts.express;
      var attr = {
        id: opts.id,
        width: opts.width,
        height: opts.height
      };
      var attrStr = [];
      for (var i in attr) {
        var p = attr[i];
        if (p !== undefined && p !== null) {
          attrStr.push(i + '="' + escapeAttr(p) + '" ');
        }
      }
      var paramsStr = [];
      for (var i in params) {
        var p = params[i];
        if (p !== undefined && p !== null) {
          paramsStr.push('<param name="' + i + '" value="' + escapeAttr(p) + '" />');
        }
      }
      return '<object ' + wrapParam + attrStr.join('') +'>' + paramsStr.join('') + '</object>';
    };
    if (version < 7) version = 0;
    version = parseInt(version) || 0;
    return {version: version, wrapper: wrapper};
  }
  
  function IFlash() {
    var CLB_PREFIX = '__iflash__',
        URL_KEY = 'flash_url',
        app = null,
        container = null,
        querystring = '',
        flashvars = {},
        defaultOptions = {
          url: null,
          width: 607,
          height: 500,
          wmode: 'opaque'
        },
        options = {},
        width = null,
        height = null,
        dw = function() {
          return width ? document.body.offsetWidth - width : 0;
        },
        dh = function() {
          return height ? document.body.offsetHeight - height : 0;
        },
        isVKInited = false,
        isFlashReady = false,
        vkCallbacks = [],
        beforeInitCallbacks = [],
        flash = getFlashVersion();
    
    function renderFlash(_cont, _opts, _params) {
      if (!_opts.url || !_opts.id) return null;
      _opts = extend({version: 9, width: 1, height: 1}, _opts);
      _params = extend({quality: 'high'}, _params);
      if (flash.version < _opts.version) return null;
      ge(_cont).innerHTML = flash.wrapper(_opts, _params);
      return ge(_opts.id) || null;
    }
    
    function addFlashCallback(_method, _callback) {
      window[CLB_PREFIX + _method] = _callback;
    }
    
    function addVKCallback(_event, _callback) {
      vkCallbacks[_event] = _callback;
      VK.addCallback(_event, function() {
        var args = Array.prototype.slice.call(arguments);
        args.unshift(_event);
        vkCallback.apply(window, args);
      });
    }
    
    function vkCallback() {
      var args = Array.prototype.slice.call(arguments),
          event = args.shift(),
          callback = vkCallbacks[event];
      if (callback) {
        if (isFlashReady) {
          callback.apply(window, args);
        } else {
          beforeInitCallbacks.push(function(){ callback.apply(window, args); });
        }
      }
    }
    
    function flashInit() {
      app.init();
      if (beforeInitCallbacks.length > 0) {
        var callback = null;
        while (callback = beforeInitCallbacks.shift()) {
          callback();
        }
        beforeInitCallbacks = [];
      }
      if (container) {
        VK.callMethod('resizeWindow', width + dw(), height + dh());
      }
    }
    
    function onVKInit() {
      addVKCallback('onApplicationAdded', function() { app.onApplicationAdded(); });
      addVKCallback('onSettingsChanged', function(s) { app.onSettingsChanged(s); });
      addVKCallback('onBalanceChanged', function(b) { app.onBalanceChanged(b); });
      addVKCallback('onMerchantPaymentCancel', function() { app.onMerchantPaymentCancel(); });
      addVKCallback('onMerchantPaymentSuccess', function(m) { app.onMerchantPaymentSuccess(m); });
      addVKCallback('onMerchantPaymentFail', function() { app.onMerchantPaymentFail(); });
      addVKCallback('onProfilePhotoSave', function() { app.onProfilePhotoSave(); });
      addVKCallback('onProfilePhotoCancel', function() { app.onProfilePhotoCancel(); });
      addVKCallback('onWallPostSave', function() { app.onWallPostSave(); });
      addVKCallback('onWallPostCancel', function() { app.onWallPostCancel(); });
      addVKCallback('onWindowResized', function(w, h) { resizeFlash(w - dw(), h - dh()); });
      addVKCallback('onLocationChanged', function(l) { app.onLocationChanged(l); });
      addVKCallback('onWindowFocus', function() { toggleFlash(true); app.onWindowFocus(); });
      addVKCallback('onWindowBlur', function() { toggleFlash(false); app.onWindowBlur(); });
      addVKCallback('onScrollTop', function(t, h) { app.onScrollTop(t, h); });
      addVKCallback('onScroll', function(t, h) { app.onScroll(t, h); });
      addVKCallback('onToggleFlash', function(f) { toggleFlash(f); });
      isVKInited = true;
      if (isFlashReady) {
        flashInit();
      }
    }
    
    function init(_cont, _width, _height, _options) {
      if (typeof arguments[0] === 'object') {
        // IFlash.init(_options);
        _options = _cont; _cont = null;
      } else if (typeof _height === 'undefined') {
        // IFlash.init([_cont, _options]);
        _options = _width || {};
      } else {
        // IFlash.init(_cont, _width, _height[, _options]);
        _options = extend({width: _width, height: _height}, _options || {});
      }
      var url = initFlashvars();
      options = extend(defaultOptions, _options, url ? {url: url} : {});
      if (!options.url) return;
      initCallbacks();
      
      onDOMReady(function() {
        initStyles();
        var w = '100%', h = '100%', el = null, wm = options.wmode;
        if (_cont) {
          container = ge(_cont);
          if (!container) return;
          w = options.width; h = options.height; el = _cont;
        } else {
          var body = document.body;
          body.parentNode.style.width = w;
          body.parentNode.style.height = h;
          body.style.width = w;
          body.style.height = h;
          body.style.margin = '0';
          body.style.padding = '0';
          el = body.id = 'body';
        }
        app = renderFlash(el, {
          url: options.url,
          id: 'flash_app',
          width: w,
          height: h,
          version: 9,
          'class': (wm != 'opaque' && wm != 'transparent') ? 'need2hide' : null
        }, {
          allowfullscreen: 'true',
          allownetworking: 'all',
          allowscriptaccess: 'always',
          wmode: wm,
          flashvars: querystring
        });
        if (_cont) {
          resizeFlash(w, h, true);
        }
      });
    }
    
    function initCallbacks() {
      VK.init(onVKInit);
      
      addFlashCallback('ready', function() {
        isFlashReady = true;
        if (isVKInited) {
          flashInit();
        }
      });
      addFlashCallback('callMethod', function() {
        var args = Array.prototype.slice.call(arguments);
        if (args[0] == 'resizeWindow') {
          var w = args[1], h = args[2], force = !args[3],
              _dw = dw(), _dh = dh();
          resizeFlash(w, h, force);
          args[1] = width + _dw;
          args[2] = height + _dh;
        }
        VK.callMethod.apply(window, args);
      });
      addFlashCallback('api', function(_method, _params, _req) {
        VK.api(_method, _params, function(_data) {
          app.apiCallback(_data, _req);
        });
      });
      addFlashCallback('navigateToURL', function(_url) {
        window.top.location.href = _url;
      });
      addFlashCallback('debug', function(_msg) {
        console && console.log && console.log(_msg);
      });
    }
    
    function initStyles() {
      var head = document.getElementsByTagName('head')[0],
          style = document.createElement('style'),
          css = 'embed, object { position: relative; left: 0; }'
              + '.flash_hidden embed.need2hide, .flash_hidden object.need2hide { left: -5000px; }';
      style.type = 'text/css';
      if (style.styleSheet) {
        style.styleSheet.cssText = css;
      } else {
        style.innerHTML = css;
      }
      head.appendChild(style);
    }
    
    function initFlashvars() {
      var _querystring = location.search.substr(1),
          keyvalue = _querystring.split('&'), qs = [];
      for (var i=0, l=keyvalue.length; i<l; i++) {
        var kv_arr = keyvalue[i].split('='),
            key = decodeURIComponent(kv_arr[0] || null),
            value = decodeURIComponent(kv_arr[1] || '');
        if (key) {
          flashvars[key] = value;
        }
        if (key != URL_KEY) {
          qs.push(keyvalue[i]);
        }
      }
      querystring = qs.join('&');
      var url = flashvars[URL_KEY] || null;
      if (url) {
        delete flashvars[URL_KEY];
      }
      return url ? 'http://' + url : null;
    }
    
    function resizeFlash(_w, _h, _noEvent) {
      var _width = Math.max(100, Math.min(827, _w)),
          _height = Math.max(100, Math.min(1000000, _h));
      width = _width; height = _height;
      if (!app || !container) return;
      app.style.width = container.style.width = _width + 'px';
      app.style.height = container.style.height = _height + 'px';
      if (!_noEvent) {
        app.onWindowResized(_width, _height);
      }
    }
    
    function toggleFlash(_show) {
      document.body.className = _show ? '' : 'flash_hidden';
    }
    
    return {
      flashvars: flashvars,
      renderFlash: renderFlash,
      init: init,
      resizeFlash: resizeFlash,
      toggleFlash: toggleFlash
    };
  }
  window.IFlash = IFlash();
})(window, document, VK);