BEGIN TRANSACTION;


UPDATE "template" SET text = '[% IF template.name.match(''.(css|js|txt)'') OR template.name.match(''(png|json|text|fragment)'');
     debug("Passing page through as text: $template.name");
     content;
   ELSE;
     IF template.name.match(''dojo'');
       debug("Applying DOJO wrapper to $template.name");
       content WRAPPER site/dojo;
     ELSE; 
       IF template.name.match(''iphone'');
         debug("Applying IPHONE wrapper to $template.name");
         content WRAPPER site/iphone;
       ELSE;
         debug("Applying HTML wrapper to $template.name");
         content WRAPPER site/html;
       END;
     END;
   END;
-%]
' WHERE id = 23;
INSERT INTO "template" VALUES(46,'iphone','layout','[% PROCESS iphone/header %]
[% PROCESS iphone/default %]
',1270485403);
INSERT INTO "template" VALUES(47,'site','iphone','<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
 <head>
  <title>[% template.title or site.title %] for iPhone</title>
  <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;"/>  
  <meta name="apple-mobile-web-app-capable" content="yes" /> 
  <link rel="icon" type="image/png" href="favicon.png"> 
  <link rel="apple-touch-icon" href="images/zenah-50.png" />
  <style type="text/css" media="screen">
@import "iui/iui.css";
@import "iui/t/default/default-theme.css";
@import "iui/ext-sandbox/masabi/t/default/iui_ext.css";
</style>
  <link rel="stylesheet" href="css/iui-panel-list_.css" type="text/css" /> 
  <link rel="stylesheet" href="css/iphone.css" type="text/css" /> 
  <script type="application/x-javascript" src="iui/iui.js"></script> 
  <script type="application/x-javascript" src="iui/ext-sandbox/masabi/iui_ext.js"></script>
[% IF meta_refresh %]
  <meta http-equiv="refresh" content="[% meta_refresh %]">
[% END %]
<script type="text/javascript">

    function button_action(device, action) {
      iui.ajax("[% Catalyst.uri_for("ajax") %]?args="+device+"&args="+action, null, "GET", function () { } );
    }
  </script>
 </head>
 <body>
[% content %]
 </body>
</html>',1271178196);
INSERT INTO "template" VALUES(48,'iphone','default','[% SET t_content = ''iphone/'' _ (Catalyst.request.param(''content'') || ''house'') %]
[% PROCESS $t_content %]',1269770643);
INSERT INTO "template" VALUES(49,'iphone','house',' [% PROCESS iphone/main %]
 [% PROCESS iphone/rooms %]
 [% PROCESS iphone/devices %]
 [% PROCESS iphone/sensors %]
 [% PROCESS iphone/lights %]
 [% PROCESS iphone/devices_action %]',1271598636);
INSERT INTO "template" VALUES(50,'iphone','rooms','[% USE table_class = Class(''ZenAH::Model::CDBI::Room'') %]
[% USE stable_class = Class(''ZenAH::Model::CDBI::State'') %]
<ul id="rooms" title="Rooms">
[% FOR zone = [''Principale'', ''Repos'', ''Extérieur''] %] 
    <li class="group">[% zone %]</li> 
    [% FOR r = table_class.by_attribute(''zone'', zone) %] 
       <li id="[% r.name %]_tab"> 
          [% FOR d = r.devices %]
                [% NEXT UNLESS d.type == ''Sensor'' %]
                [% SET s = stable_class.search({ name => d.name }) %]
                 [% IF s %]
                    [% FOREACH sensor = s %]
                      [% IF sensor.type == ''temp'' %]
                         <small id="temp" class="counter">[% sensor.value %]°C</small>
                      [% END %]
                   [% END %]
                [% END %]
          [% END %]
          <a href="[% Catalyst.uri_for("/iphonefragment/room") %]?content=room&room=[% r.id %]">
             <img src="images/puzzle.png" />
             [% r.string %]
          </a> 
       </li>
    [% END %]
[% END %]
</ul>',1271619922);
INSERT INTO "template" VALUES(51,'iphone','header','<!-- BEGIN nav -->
<div class="toolbar">
  <h1 id="pageTitle"></h1>
  <a id="backButton" class="button" href="#"></a>
</div>',1270487171);
INSERT INTO "template" VALUES(52,'iphone','main','<ul id="house" title="house" selected="true">
    <li id="lights_tab">
        <a href="#lights"><img src="images/light_bulb.png" />Lights</a>
    </li>
    <li id="rooms_tab">
        <a href="#rooms"><img src="images/puzzle.png" /> Rooms</a>
    </li>
    <li id="devices_tab">
        <a href="#devices"><img src="images/wired.png" /> Devices</a>
    </li>
    <li id="windows_tab">
        <a href="#windows"><img src="images/promotion.png" /> Windows</a>
    </li>
    <li id="motion_tab">
        <a href="#motions"><img src="images/webcam.png" /> Motion</a>
    </li>
    <li id="light_tab">
        <a href="#lights"><img src="images/light_bulb.png" /> Light</a>
    </li>
    <li id="sensors_tab">
        <a href="#sensors"><img src="images/wireless.png" /> Sensors</a>
    </li>
</ul>',1271598161);
INSERT INTO "template" VALUES(53,'iphone','devices','[% USE table_class = Class(''ZenAH::Model::CDBI::Room'') %]
[% SET rooms = table_class.retrieve_all() %]
<ul id="devices" title="Devices">
  [% FOR r = rooms %]
        <li id="[% r.name %]" class="group">[% r.string %]</li>
       [% FOR d = r.devices %]
            [% PROCESS iphone/device device = d %]
        [% END %]
   [% END %]
</ul>
',1271601645);
INSERT INTO "template" VALUES(54,'iphonefragment','room','[% USE table_class = Class(''ZenAH::Model::CDBI::Room'') %]
[% SET room = table_class.retrieve(Catalyst.request.param(''room'')) %]
<form id="room" class="panel" title="[% room.string %]">
<h2>Devices:</h2>
<fieldset> 
[% FOR d = room.devices %]
  [% NEXT IF d.type == ''Sensor'' %]
  [% NEXT UNLESS d.device_controls %]
  <div class="row">
     <a href="#action_[% d.name %]">
         [% SET img = ''wired.png'' %]
         [% IF  d.type == ''X10Lamp'' %]
            [% SET img = ''light_bulb.png'' %]
         [% END %]
         <img src="images/[% img %]" />
         [% d.string %]
        <var class="_lookup">...</var>
     </a>
   </div>
[% END %]
</fieldset>


[% FOR d = room.devices %]
  [% NEXT UNLESS d.type == ''Sensor'' %]
  [% PROCESS iphone/sensor device = d %]
[% END %]
</form>
',1271613336);
INSERT INTO "template" VALUES(55,'iphone','device','<li id="[% device.name %]">
     <a href="#action_[% device.name %]">
         [% SET img = ''wired.png'' %]
         [% IF  device.type == ''X10Lamp'' %]
            [% SET img = ''light_bulb.png'' %]
         [% END %]
         <img src="images/[% img %]" />
         [% device.string %]
     </a>
</li>',1271612924);
INSERT INTO "template" VALUES(56,'iphone','sensor','[% USE table_class = Class(''ZenAH::Model::CDBI::State'') %]
[% IF device.attribute("uid") %]
  [% SET s = table_class.search({ name => device.name }) %]
[% ELSE %]
  [% SET s = [] %]
[% END %]
<h2>[% device.string %]:</h2>
<fieldset>
  [% IF s %]
    [% FOREACH sensor = s %]
      <div class="row">
         <label>[% sensor.type %]</label>
          <var>  [% sensor.value %]</var>   
      </div>
     [% END %]
  [% ELSE %]
    <div class="row">no results</div>
  [% END %]
</fieldset>',1271277161);
INSERT INTO "template" VALUES(57,'iphone','sensors','[% USE table_class = Class(''ZenAH::Model::CDBI::Device'') %]
[% USE state_class = Class(''ZenAH::Model::CDBI::State'') %]
<div id="sensors" class="panel" title="Sensors">
    [% FOR d = table_class.search({ type => ''Sensor'' }) %]
       <h2 >[% d.string %]</h2>
       <ul id="[% d.name %]_tab" tittle="[% d.string %]"> 
          [% FOREACH sensor = state.search({ name => d.name}) %]
             <li id="[% sensor.name %]"> [% sensor.string %]
                 <small id="temp" class="counter">[% sensor.value %]
                      [% IF sensor.type == ''temp'' %] °C [% END %]
                 </small>
            </li>
         [% END %]
     </ul>
    [% END %]
</div>',1271586514);
INSERT INTO "template" VALUES(58,'iphone','devices_action','[% USE table_class = Class(''ZenAH::Model::CDBI::Device'') %]
  [% FOR d = table_class.retrieve_all() %]
    [% NEXT IF d.type == ''Sensor'' %]
    [% NEXT UNLESS d.device_controls %]
      <form class="panel" id="action_[% d.name %]" tittle="[% d.string %]" >
        <fieldset class="radiogroup">
         [% FOR control = d.device_controls %]
           <div class="row">
              <label onclick="button_action(''[% d.name %]'',''[% control.name %]''); iui.goBack();">[% control.string %]
              </label>
            </div>
          [% END %]
        </fieldset>
     </form>
  [% END %]',1271586454);
INSERT INTO "template" VALUES(60,'iphone','lights','[% USE table_class = Class(''ZenAH::Model::CDBI::Room'') %]
[% SET rooms = table_class.retrieve_all() %]
<ul id="lights" title="Devices">
  [% FOR r = rooms %]
        <li id="[% r.name %]" class="group">[% r.string %]</li>
       [% FOR d = r.devices %]
          [% NEXT UNLESS d.type == ''X10Lamp'' %]
            [% PROCESS iphone/device device = d %]
        [% END %]
   [% END %]
</ul>
',1271602334);
COMMIT;
