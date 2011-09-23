import flash.net.FileReference;

/**
 * @author Artyom Kolnogorov
 */
class TestApp extends MovieClip {
  private var tf:TextField;
  private var VK:APIConnection;
  private var app_width:Number;
  private var widget_mode:Boolean;
  public var sy:Number;
  public var upload_url:String;
  
  public function TestApp() {
    init();
  }
  private function init() {
    widget_mode = _root.widget == 1;
    app_width = widget_mode ? 200 : 607;
    
    tf = this.createTextField('tf', 100, 10, 50, 100, 100);
    tf.border = true;
    tf.borderColor = 0xDAE2E8;
    tf.background = true;
    tf.backgroundColor = 0xFFFFFF;
    
    tf._width = Stage.width - 20;
    tf._height = Stage.height - 51;
    tf.embedFonts = false;
    
    var format:TextFormat = new TextFormat();
    format.font = "Tahoma";
    format.color = 0x000000;
    format.size = 11;
    tf.setNewTextFormat(format);
    tf.text = "";
    log("Application initialized\n");
    
    var t = this;
    
    VK = new APIConnection('vk.asmico.ru', function(VK) {
      VK.onApplicationAdded = function() {
        t.log("Application added\n");
      };
      VK.onSettingsChanged = function(s) {
        t.log("Settings changed: " + s + "\n");
      };
      VK.onBalanceChanged = function(b) {
        t.log("Balance changed: " + b + "\n");
      };
      VK.onMerchantPaymentCancel = function() {
        t.log("Merchant payment canceled\n");
      };
      VK.onMerchantPaymentSuccess = function(m) {
        t.log("Merchant payment success: " + m + "\n");
      };
      VK.onMerchantPaymentFail = function() {
        t.log("Merchant payment failed\n");
      };
      VK.onProfilePhotoSave = function() {
        t.log("Profile photo saved\n");
      };
      VK.onProfilePhotoCancel = function() {
        t.log("Profile photo canceled\n");
      };
      VK.onWallPostSave = function() {
        t.log("Wall post saved\n");
      };
      VK.onWallPostCancel = function() {
        t.log("Wall post canceled\n");
      };
      VK.onWindowResized = function(w, h) {
        t.log("Window resized: " + w + ", " + h + "\n");
        t.tf._height = h - 16 - t.sy;
      };
      VK.onLocationChanged = function(l) {
        t.log("Location changed: " + l + "\n");
      };
      VK.onWindowBlur = function() {
        t.log("Window blur\n");
      };
      VK.onWindowFocus = function() {
        t.log("Window focus\n");
      };
      VK.onScrollTop = function(s, h) {
        t.log("onScrollTop: " + s + ", " + h + "\n");
      };
      VK.onScroll = function(s, h) {
        t.log("onScroll: " + s + ", " + h + "\n");
      };
      t.log("Connection inited.\n");
      
      VK.api('photos.getProfileUploadServer', {}, function(data) {
        t.upload_url = data.upload_url;
      });
    });
    
    var btns:Array = [
      {
        label: 'Install application',
        listener: function() {
          t.VK.callMethod('showInstallBox');
        },
        showInWidgetMode: false
      },
      {
        label: 'Settings',
        listener: function() {
          t.VK.callMethod('showSettingsBox', 0);
        },
        showInWidgetMode: false
      },
      {
        label: 'Invite friends',
        listener: function() {
          t.VK.callMethod('showInviteBox');
        },
        showInWidgetMode: false
      },
      {
        label: 'Add votes',
        listener: function() {
          t.VK.callMethod('showPaymentBox', 0);
        },
        showInWidgetMode: false
      },
      {
        label: 'Buy a good',
        listener: function() {
          t.VK.callMethod('showMerchantPaymentBox', {
            merchant_id: 11345,
            item_id_1: 'my_id_2',
            item_name_1: 'Единственный цифровой товар',
            item_description_1: 'Жалко расставаться',
            item_currency_1: 643,
            item_price_1: '777.77',
            item_quantity_1: 1,
            item_digital_1: 1
          });
        },
        showInWidgetMode: false
      },
      {
        label: 'Change photo',
        listener: function() {
          var fileRef:FileReference = new FileReference(), upload_url = t.upload_url,
              trim = function(str) {
                var array = str.split(' '), sx = 0, ex = array.length;
                while (array[sx] == '') sx++;
                while (array[ex-1] == '') ex--;
                array.splice(ex); array.splice(0, sx);
                return array.join(' ');
              }, json2obj = function(json) {
                // {"server": '1', "photos": '1', "hash": '12345abcde'}
                json = json.split('{').join('').split('}').join('');
                var _obj = {}, _data = json.split(',');
                for (var k in _data) {
                  var _d = _data[k].split(':'), _k = _d.shift(), _v = _d.join(':');
                  _k = trim(_k.split('"').join('').split("'").join(''));
                  _v = trim(_v.split('"').join('').split("'").join(''));
                  _obj[_k] = _v;
                }
                return _obj;
              };
          fileRef.addListener({
            onUploadCompleteData: function(file:FileReference, data: String) {
              t.log("Uploaded.\n");
              var r = json2obj(data);
              t.VK.api('photos.saveProfilePhoto', r,  function(data) {
                t.log("OK: photos.saveProfilePhoto: "+data.photo_src+"\n");
              }, function(data) {
                t.log("Error: photos.saveProfilePhoto: #"+data.error_code+" "+data.error_msg+"\n");
              });
            },
            onProgress: function(file:FileReference, bytesLoaded:Number, bytesTotal:Number) {
              t.log("  ... " + Math.round(bytesLoaded*100/bytesTotal) + "%\n");
            },
            onSelect: function(file:FileReference) {
              file.upload(upload_url, 'photo');
              t.log(file.name+ " start uploading ...\n");
            }
          });
          fileRef.browse([{
            description: "Images (*.jpg, *.jpeg, *.png, *.gif, *.bmp)",
            extension: "*.jpg;*.jpeg;*.png;*.gif;*.bmp"
          }]);
        },
        showInWidgetMode: false
      },
      {
        label: 'Add wall post',
        listener: function() {
          t.VK.api('wall.savePost', {
            wall_id: _root.viewer_id,
            photo_id: '-20710465_217925006',
            message: 'Пост из IFlash.'
          }, function(data) {
            t.log("OK: wall.savePost: "+data.post_hash+" "+data.photo_src+"\n");
            t.VK.callMethod('saveWallPost', data.post_hash);
          }, function(data) {
            t.log("Error: wall.savePost: #"+data.error_code+" "+data.error_msg+"\n");
          });
        },
        showInWidgetMode: true
      },
      {
        label: 'Resize app',
        listener: function() {
          t.VK.callMethod('resizeWindow', 607, 777);
          t.tf._height = 777 - 16 - t.sy;
        },
        showInWidgetMode: true
      },
      {
        label: 'Scroll window',
        listener: function() {
          t.VK.callMethod('scrollWindow', 180, 200);
        },
        showInWidgetMode: true
      },
      {
        label: 'Change title',
        listener: function() {
          t.VK.callMethod('setTitle', 'IFlash is good!');
        },
        showInWidgetMode: true
      },
      {
        label: 'Change location',
        listener: function() {
          t.VK.callMethod('setLocation', 'iflash');
        },
        showInWidgetMode: true
      },
      {
        label: 'parent.scrollTop = ?',
        listener: function() {
          t.VK.callMethod('scrollTop');
        },
        showInWidgetMode: false
      },
      {
        label: 'API.getServerTime()',
        listener: function() {
          t.VK.api('getServerTime', {}, function(data) {
            t.log("OK: getServerTime: "+data+"\n");
          }, function(data) {
            t.log("Error: getServerTime: #"+data.error_code+" "+data.error_msg+"\n");
          });
        },
        showInWidgetMode: true
      },
      {
        label: 'API.getProfiles( viewer_id )',
        listener: function() {
          t.VK.api('getProfiles', {uids: _root.viewer_id}, function(data) {
            t.log("OK: getProfiles: "+data[0].first_name+" "+data[0].last_name+"\n");
          }, function(data) {
            t.log("Error: getProfiles: #"+data.error_code+" "+data.error_msg+"\n");
          });
        },
        showInWidgetMode: true
      },
      {
        label: 'API.wall.post',
        listener: function() {
          t.VK.api('wall.post', {
            message: 'Я умею постить на стену. IFlash.'
          }, function(data) {
            t.log("OK: wall.post: post_id: "+data.post_id+"\n");
          }, function(data) {
            t.log("Error: wall.post: #"+data.error_code+" "+data.error_msg+"\n");
          });
        },
        showInWidgetMode: false
      },
      {
        label: 'API.wall.post( photo )',
        listener: function() {
          t.VK.api('wall.post', {
            message: 'Я умею постить на стену фото. IFlash.',
            attachment: 'photo-20710465_217925006'
          }, function(data) {
            t.log("OK: wall.post: post_id: "+data.post_id+"\n");
          }, function(data) {
            t.log("Error: wall.post: #"+data.error_code+" "+data.error_msg+"\n");
          });
        },
        showInWidgetMode: false
      },
      {
        label: 'API.wall.post( audio )',
        listener: function() {
          t.VK.api('wall.post', {
            message: 'Я умею постить на стену музыку. IFlash.',
            attachment: 'audio1661530_73182523'
          }, function(data) {
            t.log("OK: wall.post: post_id: "+data.post_id+"\n");
          }, function(data) {
            t.log("Error: wall.post: #"+data.error_code+" "+data.error_msg+"\n");
          });
        },
        showInWidgetMode: false
      },
      {
        label: 'API.wall.post( video )',
        listener: function() {
          t.VK.api('wall.post', {
            message: 'Я умею постить на стену видео. IFlash.',
            attachment: 'video1661530_158881807'
          }, function(data) {
            t.log("OK: wall.post: post_id: "+data.post_id+"\n");
          }, function(data) {
            t.log("Error: wall.post: #"+data.error_code+" "+data.error_msg+"\n");
          });
        },
        showInWidgetMode: false
      },
      {
        label: 'http://vk.com/kolar',
        listener: function() {
          t.VK.navigateToURL('http://vk.com/kolar');
        },
        showInWidgetMode: true
      },
      {
        label: 'API.wall.post( photo + audio + video )',
        listener: function() {
          t.VK.api('wall.post', {
            message: 'Я умею постить на стену несколько элементов. IFlash.',
            attachments: 'photo-20710465_217925006,audio1661530_73182523,video1661530_158881807'
          }, function(data) {
            t.log("OK: wall.post: post_id: "+data.post_id+"\n");
          }, function(data) {
            t.log("Error: wall.post: #"+data.error_code+" "+data.error_msg+"\n");
          });
        },
        showInWidgetMode: false
      },
      {
        label: 'Subscribe to scroll',
        listener: function() {
          t.VK.callMethod('scrollSubscribe', true);
        },
        showInWidgetMode: true
      }
    ];
    
    var sx = 15;
    sy = 15;
    for (var i=0; i<btns.length; i++) {
      if (widget_mode && !btns[i].showInWidgetMode) {
        continue;
      }
      var btn = this.attachMovie('VKButton', 'btn'+i, i);
      btn.label = btns[i].label;
      if (sx + btn._width > app_width - 10) {
        sx = 15; sy += 30;
      }
      btn._x = sx;
      btn._y = sy;
      btn.onPress = btns[i].listener;
      sx += Math.round(btn._width) + 12;
    }
    
    tf._x = 15;
    tf._y = sy += 35;
    tf._width = app_width - 30;
    tf._height = Stage.height - 16 - sy;
    
    Stage.align = "TL";
    Stage.scaleMode = "noScale";
  }
  public function log(msg) {
    tf.text += msg;
    tf.scroll = tf.maxscroll;
  }
}
