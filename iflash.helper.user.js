// ==UserScript==
// @name          IFlash Helper
// @version       0.01
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
  function before(el, before_el) {
    return before_el.parentNode.insertBefore(el, before_el);
  }
  function log(msg) {
    console && console.log && console.log('IFlashHelper: ' + msg);
  }

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

  function onEditappOpen() {
    log('onEditappOpen');
    if (ge('app_iframe_url').value.indexOf('flash_url=') != -1) {
      var ifo = ge('apps_edit_iframe_options'),
          tr = geByTag1(ifo, 'tr'), iflash_tr = tr.cloneNode(true),
          tds = geByTag(iflash_tr, 'td'),
          td_label = tds[0], td_content = tds[1];
      before(iflash_tr, tr);
      td_label.innerHTML = 'SWF <b>IFlash</b>:';
      td_content.className = 'apps_edit_t';
      td_content.innerHTML = '<a onclick="AppsEdit.addSWF();">Загрузить приложение</a>';
      
      var swfs_count = geByClassName('apps_edit_swf_rows', 'apps_edit_swf_row', 'table').length,
          onLoad = function(href) {
            log('onSWFLoad');
            var old_url = ge('app_iframe_url').value,
                s = old_url.indexOf('flash_url='),
                e = old_url.indexOf('&', s),
                new_url = old_url.substr(0, s) + 'flash_url=' + href.substr(7) + (e == -1 ? '' : old_url.substr(e));
            ge('app_iframe_url').value = new_url;
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