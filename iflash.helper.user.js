// ==UserScript==
// @name          IFlash Helper
// @version       0.02
// @description   Упрощает загрузку приложения при использовании IFlash
// @homepage      https://github.com/kolar/iflash
// @author        Артём Колногоров
// @include       http://vkontakte.ru/*
// @include       http://vk.com/*
// ==/UserScript==

(function() {
  // utils
  function ge(id) {
    return document.getElementById(id);
  }
  function geByClassName(id, className, tag) {
    var el = typeof id === 'string' ? ge(id) : id, result = [];
    if (document.getElementsByClassName) {
      var elems = el.getElementsByClassName(className);
      if (tag) {
        tag = tag.toUpperCase();
        for (var i=0, l=elems.length; i<l; i++) {
          if (elems[i].tagName == tag) {
            result.push(elems[i]);
          }
        }
      } else {
        result = elems;
      }
    } else {
      var elems = el.getElementsByTagName(tag || '*');
      for (var i=0, l=elems.length; i<l; i++) {
        if (elems[i].className == className) {
          result.push(elems[i]);
        }
      }
    }
    return result;
  }
  function geByTag(id, tag) {
    var el = typeof id === 'string' ? ge(id) : id;
    return el.getElementsByTagName(tag);
  }
  function geByTag1(id, tag) {
    return geByTag(id, tag)[0] || null;
  }
  function ce(tag, props) {
    var el = document.createElement(tag);
    for (var k in props) {
      el[k] = props[k];
    }
    return el;
  }
  function re(el) {
    el.parentNode && el.parentNode.removeChild(el);
  }
  function before(el, before_el) {
    return before_el.parentNode.insertBefore(el, before_el);
  }
  function log(msg) {
    console && console.log && console.log('IFlashHelper: ' + msg);
  }
  ajax = {
    reqTimeout: null,
    TIMEOUT: 5000,
    urlEncodeData: function(data) {
      var query = [];
      if (data instanceof Object)
      {
        for (var k in data)
          query.push(encodeURIComponent(k) + "=" + encodeURIComponent(data[k]));
        return query.join('&');
      }
      else
        return encodeURIComponent(data);
    },
    send: function(_url, _data, _callback, _method) {
      var t = this;
      t.req = null;
      if (window.XMLHttpRequest)
      {
        try { t.req = new XMLHttpRequest(); }
        catch (e) {}
      }
      else if (window.ActiveXObject)
      {
        try { t.req = new ActiveXObject('Msxml2.XMLHTTP'); }
        catch (e)
        {
          try { t.req = new ActiveXObject('Microsoft.XMLHTTP'); }
          catch (e) {}
        }
      }
      if (t.req)
      {
        var m = (_method=="get") ? "get" : "post";
        t.req.open(m, _url, true);
        if (m=="post") t.req.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
        t.req.onreadystatechange = function()
        {
          // Если "Готово"
          if (t.req.readyState == 4)
          {
            clearTimeout(t.reqTimeout);
            ok = (t.req.status == 200);
            _callback && _callback(ok, ok ? t.req.responseText : t.req.statusText);
          }
        }
        var d = (m=="post") ? t.urlEncodeData(_data) : null;
        t.req.send(d);
        t.reqTimeout = setTimeout(t.req, "abort", t.TIMEOUT);
      }
    }
  };

  // helper functions
  var editapp = false;
  function editappCheck() {
    var is_now_editapp = ge('app_edit') && ge('apps_edit_iframe_options') || false;
    if (is_now_editapp !== editapp) {
      editapp = is_now_editapp;
      if (is_now_editapp) {
        onEditappOpen && onEditappOpen();
      } else {
        onEditappClose && onEditappClose();
      }
    }
    setTimeout(editappCheck, 200);
  }
  editappCheck();

  function deleteSWF(app_id, swf_id, hash, obj) {
    ajax.send('editapp', {act: 'a_delete_swf', aid: app_id, swf_id: swf_id, hash: hash}, function() {
      re(obj);
      var rows = geByClassName('apps_edit_swf_rows', 'apps_edit_swf_row', 'table');
      if (rows.length == 1) {
        re(rows[0]);
      }
    });
  }

  function onEditappOpen() {
    log('onEditappOpen');
    var flash_url_re = /([?&]flash_url)=?([^&]*)/i,
        delete_swf_re = /AppsEdit\.deleteSWF\(([0-9]+), ?['"]([0-9a-f]+)['"],/i;
    if (ge('app_iframe_url').value.search(flash_url_re) != -1) {
      var ifo = ge('apps_edit_iframe_options'),
          tr = geByTag1(ifo, 'tr'), iflash_tr = tr.cloneNode(true),
          tds = geByTag(iflash_tr, 'td'),
          td_label = tds[0], td_content = tds[1];
      before(iflash_tr, tr);
      td_label.innerHTML = 'SWF <b>IFlash</b>:';
      td_content.className = 'apps_edit_t';
      td_content.innerHTML = '<a onclick="AppsEdit.addSWF();">Загрузить приложение</a>';
      
      var swfs_count = geByClassName('apps_edit_swf_rows', 'apps_edit_swf_row', 'table').length,
          onLoad = function(new_flash_url) {
            if (!ge('apps_edit_iframe_options').offsetHeight) return;
            log('onSWFLoad');
            var old_url = ge('app_iframe_url').value,
                m = old_url.match(flash_url_re),
                old_flash_url = 'http://' + (m[2] || ''),
                new_url = old_url.replace(flash_url_re, '$1=' + new_flash_url.substr(7));
            ge('app_iframe_url').value = new_url;
            
            var rows = geByClassName('apps_edit_swf_rows', 'apps_edit_swf_row', 'table');
            for (var i=rows.length; i; ) {
              var row = rows[--i],
                  a = geByTag1(row, 'a'),
                  o1 = old_flash_url.split('vk.com').join('vkontakte.ru'),
                  o2 = old_flash_url.split('vkontakte.ru').join('vk.com');
              if (a && (a.href == o1 || a.href == o2)) {
                var tds = geByTag(row, 'td'),
                    last_td = tds[tds.length - 1],
                    last_td_html = last_td.innerHTML,
                    m = last_td_html.match(delete_swf_re),
                    swf_id = +m[1] || 0,
                    hash = m[2] || '',
                    app_id = +ge('app_id').value || 0;
                deleteSWF(app_id, swf_id, hash, row);
                break;
              }
            }
            
            ge('app_save_btn').click();
          },
          onLoadCheck = function() {
            try {
              var new_swfs = geByClassName('apps_edit_swf_rows', 'apps_edit_swf_row', 'table')
                  new_swfs_count = new_swfs.length;
              if (new_swfs_count > swfs_count) {
                var last_table = new_swfs[new_swfs_count - 1],
                    last_swf_a = geByTag1(last_table, 'a'),
                    last_href = last_swf_a.href;
                onLoad(last_href);
              }
              swfs_count = new_swfs_count;
            } catch(e) {}
            if (editapp) setTimeout(onLoadCheck, 100);
          };
      onLoadCheck();
    }
  }

  function onEditappClose() {
    log('onEditappClose');
  }
})();