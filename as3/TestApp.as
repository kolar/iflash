package {
  import flash.display.Sprite;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.net.FileReference;
  import flash.net.FileFilter;
  import flash.net.URLRequest;

  import flash.text.*;
  import flash.events.*;

  import vk.APIConnection;
  import vk.events.CustomEvent;
  import vk.events.IFlashEvent;
  import vk.ui.VKButton;

  /**
   * @author Artyom Kolnogorov
   */
  public class TestApp extends Sprite {
    private var tf:TextField;
    private var VK:APIConnection;
    private var app_width:int;
    private var widget_mode:Boolean;
    public var sy:int;
    public var upload_url:String;
    
    public function TestApp() {
      if (!stage) {
        addEventListener(Event.ADDED_TO_STAGE, init);
      } else {
        init();
      }
    }
    
    private function initListeners(e:IFlashEvent):void {
      var VK = e.VK;
      VK.addEventListener('onApplicationAdded', function(e:CustomEvent):void {
        log("Application added\n");
      });
      VK.addEventListener('onSettingsChanged', function(e:CustomEvent):void {
        log("Settings changed: "+e.params[0]+"\n");
      });
      VK.addEventListener('onBalanceChanged', function(e:CustomEvent):void {
        log("Balance changed: "+e.params[0]+"\n");
      });
      VK.addEventListener('onProfilePhotoSave', function(e:CustomEvent):void {
        log("Profile photo saved\n");
      });
      VK.addEventListener('onProfilePhotoCancel', function(e:CustomEvent):void {
        log("Profile photo canceled\n");
      });
      VK.addEventListener('onWallPostSave', function(e:CustomEvent):void {
        log("Wall post saved\n");
      });
      VK.addEventListener('onWallPostCancel', function(e:CustomEvent):void {
        log("Wall post canceled\n");
      });
      VK.addEventListener('onWindowResized', function(e:CustomEvent):void {
        log("Window resized: "+e.params[0]+", "+e.params[1]+"\n");
        tf.height = e.params[1] - 16 - sy;
      });
      VK.addEventListener('onLocationChanged', function(e:CustomEvent):void {
        log("Location changed: "+e.params[0]+"\n");
      });
      VK.addEventListener('onWindowBlur', function(e:CustomEvent):void {
        log("Window blur\n");
      });
      VK.addEventListener('onWindowFocus', function(e:CustomEvent):void {
        log("Window focus\n");
      });
      VK.addEventListener('onScrollTop', function(e:CustomEvent):void {
        log("onScrollTop: "+e.params[0]+", "+e.params[1]+"\n");
      });
      VK.addEventListener('onScroll', function(e:CustomEvent):void {
        log("onScroll: "+e.params[0]+", "+e.params[1]+"\n");
      });
      VK.addEventListener('onOrderCancel', function(e:CustomEvent):void {
        log("Order canceled\n");
      });
      VK.addEventListener('onOrderSuccess', function(e:CustomEvent):void {
        log("Order success: "+e.params[0]+"\n");
      });
      VK.addEventListener('onOrderFail', function(e:CustomEvent):void {
        log("Order failed: "+e.params[0]+"\n");
      });
      log("Connection inited.\n");
      
      VK.api('photos.getProfileUploadServer', {}, function(data) {
        upload_url = data.upload_url;
      });
    }
    
    private function init(e:Event = null): void {
      if (e) {
        removeEventListener(e.type, init);
      }
      
      var flashVars:Object = stage.loaderInfo.parameters as Object;
      widget_mode = flashVars.widget == 1;
      app_width = widget_mode ? 200 : 607;
      
      tf = new TextField();
      tf.border = true;
      tf.borderColor = 0xDAE2E8;
      tf.background = true;
      tf.backgroundColor = 0xFFFFFF;
      tf.embedFonts = false;
      
      var format:TextFormat = new TextFormat();
      format.font = "Tahoma";
      format.color = 0x000000;
      format.size = 11;
      tf.defaultTextFormat = format;
      addChild(tf);
      log("Application initialized\n");
      
      VK = new APIConnection('vk.asmico.ru', initListeners);
      
      var btns:Array = [
        {
          label: 'Install application',
          listener: function(e:Event):void {
            VK.callMethod('showInstallBox');
          },
          showInWidgetMode: false
        },
        {
          label: 'Settings',
          listener: function(e:Event):void {
            VK.callMethod('showSettingsBox', 0);
          },
          showInWidgetMode: false
        },
        {
          label: 'Invite friends',
          listener: function(e:Event):void {
            VK.callMethod('showInviteBox');
          },
          showInWidgetMode: false
        },
        {
          label: 'Add votes',
          listener: function(e:Event):void {
            VK.callMethod('showPaymentBox', 0);
          },
          showInWidgetMode: false
        },
        {
          label: 'Order box',
          listener: function(e:Event):void {
            VK.callMethod('showOrderBox', {
              type: 'item',
              item: 'sample_item'
            });
          },
          showInWidgetMode: false
        },
        {
          label: 'Change photo',
          listener: function(e:Event):void {
            var fileRef:FileReference = new FileReference(),
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
            fileRef.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, function(e:DataEvent) {
              log("Uploaded.\n");
              var r = json2obj(e.data);
              VK.api('photos.saveProfilePhoto', r,  function(data) {
                log("OK: photos.saveProfilePhoto: "+data.photo_src+"\n");
              }, function(data) {
                log("Error: photos.saveProfilePhoto: #"+data.error_code+" "+data.error_msg+"\n");
              });
            });
            fileRef.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent) {
              log("  ... " + Math.round(e.bytesLoaded*100/e.bytesTotal) + "%\n");
            });
            fileRef.addEventListener(Event.SELECT, function(e:Event) {
              var file:FileReference = FileReference(e.target);
              file.upload(new URLRequest(upload_url), 'photo');
              log(file.name+ " start uploading ...\n");
            });
            fileRef.browse([new FileFilter(
              "Images (*.jpg, *.jpeg, *.png, *.gif, *.bmp)",
              "*.jpg;*.jpeg;*.png;*.gif;*.bmp"
            )]);
          },
          showInWidgetMode: false
        },
        {
          label: 'Add wall post',
          listener: function(e:Event):void {
            VK.api('wall.savePost', {
              wall_id: flashVars.viewer_id,
              photo_id: '-20710465_217925006',
              message: 'Пост из IFlash.'
            }, function(data) {
              log("OK: wall.savePost: "+data.post_hash+" "+data.photo_src+"\n");
              VK.callMethod('saveWallPost', data.post_hash);
            }, function(data) {
              log("Error: wall.savePost: #"+data.error_code+" "+data.error_msg+"\n");
            });
          },
          showInWidgetMode: true
        },
        {
          label: 'Resize app',
          listener: function(e:Event):void {
            VK.callMethod('resizeWindow', 607, 777);
            tf.height = 777 - 16 - sy;
          },
          showInWidgetMode: true
        },
        {
          label: 'Scroll window',
          listener: function(e:Event):void {
            VK.callMethod('scrollWindow', 180, 200);
          },
          showInWidgetMode: true
        },
        {
          label: 'Change title',
          listener: function(e:Event):void {
            VK.callMethod('setTitle', 'IFlash is good!');
          },
          showInWidgetMode: true
        },
        {
          label: 'Change location',
          listener: function(e:Event):void {
            VK.callMethod('setLocation', 'iflash');
          },
          showInWidgetMode: true
        },
        {
          label: 'parent.scrollTop = ?',
          listener: function(e:Event):void {
            VK.callMethod('scrollTop');
          },
          showInWidgetMode: false
        },
        {
          label: 'API.getServerTime',
          listener: function(e:Event):void {
            VK.api('getServerTime', {}, function(data) {
              log("OK: getServerTime: "+data+"\n");
            }, function(data) {
              log("Error: getServerTime: #"+data.error_code+" "+data.error_msg+"\n");
            });
          },
          showInWidgetMode: true
        },
        {
          label: 'API.getProfiles(viewer_id)',
          listener: function(e:Event):void {
            VK.api('getProfiles', {'uids': flashVars.viewer_id}, function(data) {
              log("OK: getProfiles: "+data[0].first_name+" "+data[0].last_name+"\n");
            }, function(data) {
              log("Error: getProfiles: #"+data.error_code+" "+data.error_msg+"\n");
            });
          },
          showInWidgetMode: true
        },
        {
          label: 'API.wall.post',
          listener: function() {
            VK.api('wall.post', {
              message: 'Я умею постить на стену. IFlash.'
            }, function(data) {
              log("OK: wall.post: post_id: "+data.post_id+"\n");
            }, function(data) {
              log("Error: wall.post: #"+data.error_code+" "+data.error_msg+"\n");
            });
          },
          showInWidgetMode: false
        },
        {
          label: 'API.wall.post( photo )',
          listener: function() {
            VK.api('wall.post', {
              message: 'Я умею постить на стену фото. IFlash.',
              attachment: 'photo-20710465_217925006'
            }, function(data) {
              log("OK: wall.post: post_id: "+data.post_id+"\n");
            }, function(data) {
              log("Error: wall.post: #"+data.error_code+" "+data.error_msg+"\n");
            });
          },
          showInWidgetMode: false
        },
        {
          label: 'API.wall.post( audio )',
          listener: function() {
            VK.api('wall.post', {
              message: 'Я умею постить на стену музыку. IFlash.',
              attachment: 'audio1661530_73182523'
            }, function(data) {
              log("OK: wall.post: post_id: "+data.post_id+"\n");
            }, function(data) {
              log("Error: wall.post: #"+data.error_code+" "+data.error_msg+"\n");
            });
          },
          showInWidgetMode: false
        },
        {
          label: 'API.wall.post( video )',
          listener: function() {
            VK.api('wall.post', {
              message: 'Я умею постить на стену видео. IFlash.',
              attachment: 'video1661530_158881807'
            }, function(data) {
              log("OK: wall.post: post_id: "+data.post_id+"\n");
            }, function(data) {
              log("Error: wall.post: #"+data.error_code+" "+data.error_msg+"\n");
            });
          },
          showInWidgetMode: false
        },
        {
          label: 'http://vk.com/kolar',
          listener: function() {
            VK.navigateToURL('http://vk.com/kolar');
          },
          showInWidgetMode: true
        },
        {
          label: 'API.wall.post( photo + audio + video )',
          listener: function() {
            VK.api('wall.post', {
              message: 'Я умею постить на стену несколько элементов. IFlash.',
              attachments: 'photo-20710465_217925006,audio1661530_73182523,video1661530_158881807'
            }, function(data) {
              log("OK: wall.post: post_id: "+data.post_id+"\n");
            }, function(data) {
              log("Error: wall.post: #"+data.error_code+" "+data.error_msg+"\n");
            });
          },
          showInWidgetMode: false
        },
        {
          label: 'Subscribe to scroll',
          listener: function() {
            VK.callMethod('scrollSubscribe', true);
          },
          showInWidgetMode: true
        }
      ];
      
      var sx = 15;
      sy = 15;
      for (var i:uint; i<btns.length; i++) {
        if (widget_mode && !btns[i].showInWidgetMode) {
          continue;
        }
        var btn:VKButton = new VKButton(btns[i].label);
        if (sx + btn.width > app_width - 10) {
          sx = 15; sy += 30;
        }
        btn.x = sx;
        btn.y = sy;
        addChild(btn);
        btn.addEventListener(MouseEvent.CLICK, btns[i].listener);
        sx += btn.width + 12;
      }
      
      tf.x = 15;
      tf.y = sy += 35;
      tf.width = app_width - 30;
      tf.height = stage.stageHeight - 16 - sy;
      
      stage.align = StageAlign.TOP_LEFT;
      stage.scaleMode = StageScaleMode.NO_SCALE;
    }
    
    public function log(msg) {
      tf.appendText(msg);
      tf.scrollV = tf.maxScrollV;
    }
  }
}
