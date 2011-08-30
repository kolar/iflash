import flash.net.FileReference;

/**
 * @author Artyom Kolnogorov
 */
class TestApp extends MovieClip {
  private var tf:TextField;
  private var VK:APIConnection;
  public var sy:Number;
  public var upload_url:String;
  
  public function TestApp() {
    init();
  }
  private function init() {
    
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
    tf.text = "Application initialized\n";
    
    var t = this;
    
    VK = new APIConnection('vk.asmico.ru', function(VK) {
      VK.onApplicationAdded = function() {
        t.tf.text += "Application added\n";
      };
      VK.onSettingsChanged = function(s) {
        t.tf.text += "Settings changed: " + s + "\n";
      };
      VK.onBalanceChanged = function(b) {
        t.tf.text += "Balance changed: " + b + "\n";
      };
      VK.onMerchantPaymentCancel = function() {
        t.tf.text += "Merchant payment canceled\n";
      };
      VK.onMerchantPaymentSuccess = function(m) {
        t.tf.text += "Merchant payment success: " + m + "\n";
      };
      VK.onMerchantPaymentFail = function() {
        t.tf.text += "Merchant payment failed\n";
      };
      VK.onProfilePhotoSave = function() {
        t.tf.text += "Profile photo saved\n";
      };
      VK.onProfilePhotoCancel = function() {
        t.tf.text += "Profile photo canceled\n";
      };
      VK.onWallPostSave = function() {
        t.tf.text += "Wall post saved\n";
      };
      VK.onWallPostCancel = function() {
        t.tf.text += "Wall post canceled\n";
      };
      VK.onWindowResized = function(w, h) {
        t.tf.text += "Window resized: " + w + ", " + h + "\n";
        t.tf._height = h - 16 - t.sy;
      };
      VK.onLocationChanged = function(l) {
        t.tf.text += "Location changed: " + l + "\n";
      };
      VK.onWindowBlur = function() {
        t.tf.text += "Window blur\n";
      };
      VK.onWindowFocus = function() {
        t.tf.text += "Window focus\n";
      };
      VK.onScrollTop = function(s) {
        t.tf.text += "scrollTop = " + s + "\n";
      };
      t.tf.text += "Connection inited.\n";
      
      VK.api('photos.getProfileUploadServer', {}, function(data) {
        t.upload_url = data.upload_url;
      });
    });
    
    var btns:Array = [
      {
        label: 'Install application',
        listener: function() {
          t.VK.callMethod('showInstallBox');
        }
      },
      {
        label: 'Settings',
        listener: function() {
          t.VK.callMethod('showSettingsBox', 0);
        }
      },
      {
        label: 'Invite friends',
        listener: function() {
          t.VK.callMethod('showInviteBox');
        }
      },
      {
        label: 'Add votes',
        listener: function() {
          t.VK.callMethod('showPaymentBox', 0);
        }
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
        }
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
              t.tf.text += "Uploaded.\n";
              var r = json2obj(data);
              t.VK.api('photos.saveProfilePhoto', r,  function(data) {
                t.tf.text += "OK: photos.saveProfilePhoto: "+data.photo_src+"\n";
              }, function(data) {
                t.tf.text += "Error: photos.saveProfilePhoto: #"+data.error_code+" "+data.error_msg+"\n";
              });
            },
            onProgress: function(file:FileReference, bytesLoaded:Number, bytesTotal:Number) {
              t.tf.text += "  ... " + Math.round(bytesLoaded*100/bytesTotal) + "%\n";
            },
            onSelect: function(file:FileReference) {
              file.upload(upload_url, 'photo');
              t.tf.text += file.name+ " start uploading ...\n";
            }
          });
          fileRef.browse([{
            description: "Images (*.jpg, *.jpeg, *.png, *.gif, *.bmp)",
            extension: "*.jpg;*.jpeg;*.png;*.gif;*.bmp"
          }]);
        }
      },
      {
        label: 'Add wall post',
        listener: function() {
          t.VK.api('wall.savePost', {
            wall_id: _root.viewer_id,
            photo_id: '-20710465_217925006',
            message: 'Пост из IFlash.'
          }, function(data) {
            t.tf.text += "OK: wall.savePost: "+data.post_hash+" "+data.photo_src+"\n";
            t.VK.callMethod('saveWallPost', data.post_hash);
          }, function(data) {
            t.tf.text += "Error: wall.savePost: #"+data.error_code+" "+data.error_msg+"\n";
          });
        }
      },
      {
        label: 'Resize app',
        listener: function() {
          t.VK.callMethod('resizeWindow', 607, 777);
          t.tf._height = 777 - 16 - t.sy;
        }
      },
      {
        label: 'Scroll window',
        listener: function() {
          t.VK.callMethod('scrollWindow', 180, 200);
        }
      },
      {
        label: 'Change title',
        listener: function() {
          t.VK.callMethod('setTitle', 'IFlash is good!');
        }
      },
      {
        label: 'Change location',
        listener: function() {
          t.VK.callMethod('setLocation', 'iflash');
        }
      },
      {
        label: 'parent.scrollTop = ?',
        listener: function() {
          t.VK.callMethod('scrollTop');
        }
      },
      {
        label: 'API.getServerTime()',
        listener: function() {
          t.VK.api('getServerTime', {}, function(data) {
            t.tf.text += "OK: getServerTime: "+data+"\n";
          }, function(data) {
            t.tf.text += "Error: getServerTime: #"+data.error_code+" "+data.error_msg+"\n";
          });
        }
      },
      {
        label: 'API.getProfiles( viewer_id )',
        listener: function() {
          t.VK.api('getProfiles', {uids: _root.viewer_id}, function(data) {
            t.tf.text += "OK: getProfiles: "+data[0].first_name+" "+data[0].last_name+"\n";
          }, function(data) {
            t.tf.text += "Error: getProfiles: #"+data.error_code+" "+data.error_msg+"\n";
          });
        }
      },
      {
        label: 'API.wall.post',
        listener: function() {
          t.VK.api('wall.post', {
            message: 'Я умею постить на стену. IFlash.'
          }, function(data) {
            t.tf.text += "OK: wall.post: post_id: "+data.post_id+"\n";
          }, function(data) {
            t.tf.text += "Error: wall.post: #"+data.error_code+" "+data.error_msg+"\n";
          });
        }
      },
      {
        label: 'API.wall.post( photo )',
        listener: function() {
          t.VK.api('wall.post', {
            message: 'Я умею постить на стену фото. IFlash.',
            attachment: 'photo-20710465_217925006'
          }, function(data) {
            t.tf.text += "OK: wall.post: post_id: "+data.post_id+"\n";
          }, function(data) {
            t.tf.text += "Error: wall.post: #"+data.error_code+" "+data.error_msg+"\n";
          });
        }
      },
      {
        label: 'API.wall.post( audio )',
        listener: function() {
          t.VK.api('wall.post', {
            message: 'Я умею постить на стену музыку. IFlash.',
            attachment: 'audio1661530_73182523'
          }, function(data) {
            t.tf.text += "OK: wall.post: post_id: "+data.post_id+"\n";
          }, function(data) {
            t.tf.text += "Error: wall.post: #"+data.error_code+" "+data.error_msg+"\n";
          });
        }
      },
      {
        label: 'API.wall.post( video )',
        listener: function() {
          t.VK.api('wall.post', {
            message: 'Я умею постить на стену видео. IFlash.',
            attachment: 'video1661530_158881807'
          }, function(data) {
            t.tf.text += "OK: wall.post: post_id: "+data.post_id+"\n";
          }, function(data) {
            t.tf.text += "Error: wall.post: #"+data.error_code+" "+data.error_msg+"\n";
          });
        }
      },
      {
        label: 'http://vk.com/kolar',
        listener: function() {
          t.VK.navigateToURL('http://vk.com/kolar');
        }
      }
    ];
    
    var sx = 15;
    sy = 15;
    for (var i=0; i<btns.length; i++) {
      var btn = this.attachMovie('VKButton', 'btn'+i, i);
      btn._x = sx;
      btn._y = sy;
      btn.label = btns[i].label;
      btn.onPress = btns[i].listener;
      sx += Math.round(btn._width) + 12;
      if (sx > 500) {
        sx = 15; sy += 30;
      }
    }
    
    tf._x = 15;
    tf._y = sx==15 ? sy += 5 : sy += 35;
    tf._width = 577;
    tf._height = Stage.height - 16 - sy;
    
    Stage.align = "TL";
    Stage.scaleMode = "noScale";
  }
}
