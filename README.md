IFlash
------

**IFlash** - IFrame-посредник для Flash-приложений.

Зачем нужен **IFlash**:

* если приложение написано на ActionScript 2.0 и нет желания адаптировать [Flash-посредник](http://vkontakte.ru/developers.php?oid=-1&p=Flash-%D0%BF%D1%80%D0%B8%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%B8%D1%8F) под него;
* если не хватает возможностей [Flash-посредника](http://vkontakte.ru/developers.php?oid=-1&p=Flash-%D0%BF%D1%80%D0%B8%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%B8%D1%8F);
* если хотите добавить HTML-контент к Flash-приложению;
* если хотите использовать [виджеты](http://vkontakte.ru/developers.php?oid=-1&p=%D0%98%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5_%D0%B2%D0%B8%D0%B4%D0%B6%D0%B5%D1%82%D0%BE%D0%B2_%D0%B2_IFrame_%D0%BF%D1%80%D0%B8%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%B8%D1%8F%D1%85) в приложении.


### Как использовать?

1. Подключите к Вашему проекту класс `vk.APIConnection` (или `APIConnection` для AS2 версии)
2. Создайте экземпляр этого класса:

        // var VK:APIConnection = new APIConnection(domain:String = '*', onConnectionInit:Function = null);
        // где:
        //   domain - домен приложения, на котором будет размещена IFrame-обертка,
        //   onConnectionInit - функция, вызываемая в момент, когда IFlash готов к работе, в ней задаются обработчики событий.
        
        // ActionScript 2.0
        var VK:APIConnection = new APIConnection('vk.asmico.ru', function(VK) {
          VK.onLocationChanged = function(l:String) {
            VK.debug(l);
          };
        });
        
        // ActionScript 3.0
        var VK:APIConnection = new APIConnection('vk.asmico.ru', initListeners);
        ...
        function initListeners(e:IFlashEvent): void {
          var VK = e.VK;
          VK.addEventListener('onLocationChanged', function(e:CustomEvent):void {
            VK.debug(e.params[0]);
          });
        }

3. Если Вы не хотите добавлять HTML-контент и/или виджеты к приложению, то переходите к пункту 7
4. Создайте файл `index.htm` с необходимым HTML-контентом (пример такого файла - `html/index_as2.htm`)
5. В тело страницы добавьте `DIV` элемент с уникальным id в месте, где будет расположено Flash-приложение:

        <div id="flash_container"></div>

6. В тег `HEAD` добавьте следующий код:

        <script type="text/javascript" src="http://vkontakte.ru/js/api/xd_connection.js"></script>
        <script type="text/javascript" src="api_connection.min.js"></script>
        <script type="text/javascript">
          IFlash.init('flash_container', 607, 500);
        </script>

7. Разместите на своем сервере файлы `index.htm` и `api_connection.min.js` из каталога `/html`
8. Загрузите приложение на сервер ВКонтакте, используя дополнительные SWF-файлы
9. Выберите тип приложения IFrame. В поле "Адрес IFrame" пропишите адрес файла `index.htm`, по которому он доступен из сети Интернет, в параметре `flash_url` укажите ссылку на загруженное приложение (без `http://`):

        http://vk.asmico.ru/iflash/index.htm?flash_url=cs5937.vkontakte.ru/u1661530/6c91ee72244c9e.zip

10. Если Вы используете IFlash без HTML-контента, то в поле "Размер IFrame" обязательно укажите размер приложения


### Объект IFlash

После подключения файла `api_connection.min.js` становится доступным глобальный объект `IFlash`, который имеет следующие свойства и методы:

* `IFlash.flashvars` - объект `flashvars`
* `IFlash.init([options])` - подготавливает IFlash к работе без HTML-контента. `options` может содержать следующие поля:
    * `url` - адрес Flash-приложения (если не используется `flash_url`)
    * `wmode` - Flash-параметр wmode (по умолчанию `opaque`)
* `IFlash.init(container[, width, height][, options])` - подготавливает IFlash к работе, позволяя добавлять к приложению HTML-контент. Параметр `container` должен содержать id элемента, в который будет вставлен Flash-ролик. Параметры `width` и `height` обязательны, их можно передать непосредственно в параметрах или в объекте `options`.

        <script type="text/javascript">
          // Варианты инициализации IFlash без HTML-контента
          IFlash.init();
          IFlash.init({wmode: 'window'});
          // Варианты инициализации IFlash с HTML-контентом
          IFlash.init('flash_container', {width: 607, height: 500});
          IFlash.init('flash_container', 607, 500, {wmode: 'window'});
        </script>

* `IFlash.resizeFlash(width, height)` - изменяет размеры Flash-приложения. При этом в приложении сработает событие `onWindowResized`. Обратите внимание, что размеры IFrame-приложения изменены не будут, при необходимости это нужно сделать вручную


### Примеры

Примеры приложений, использующих **IFlash**: [на ActionScript 2.0](http://vkontakte.ru/app1986275), [на ActionScript 3.0](http://vkontakte.ru/app1985383).

Исходные коды к ним в папках `/as2` и `/as3` соответственно, IFrame-обертка в папке `/html` (`index_as2.htm`, `index_as3.htm` соответственно).

Более подробную документацию можно найти [здесь](http://vkontakte.ru/pages?oid=-20710465&p=%D0%94%D0%BE%D0%BA%D1%83%D0%BC%D0%B5%D0%BD%D1%82%D0%B0%D1%86%D0%B8%D1%8F).