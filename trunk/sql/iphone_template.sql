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
  <style type="text/css" media="screen">
@import "iui/iui.css";
@import "iui/t/default/default-theme.css";
@import "iui/ext-sandbox/masabi/t/default/iui_ext.css";
</style>
  <link rel="stylesheet" href="css/iui-panel-list_.css" type="text/css" /> 
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
</html>',1271170543);
INSERT INTO "template" VALUES(48,'iphone','default','[% SET t_content = ''iphone/'' _ (Catalyst.request.param(''content'') || ''house'') %]
[% PROCESS $t_content %]',1269770643);
INSERT INTO "template" VALUES(49,'iphone','house',' [% PROCESS iphone/main %]
 [% PROCESS iphone/rooms %]
 [% PROCESS iphone/devices %]',1270579949);
INSERT INTO "template" VALUES(50,'iphone','rooms','[% USE table_class = Class(''ZenAH::Model::CDBI::Room'') %] 
<ul id="rooms" title="Rooms">
[% FOR zone = [''Downstairs'', ''Upstairs'', ''Outside''] %] 
    <li class="group">[% zone %]</li> 
    [% FOR r = table_class.by_attribute(''zone'', zone) %] 
       <li id="[% r.name %]_tab"> 
          <a href="[% Catalyst.uri_for("/iphonefragment/room") %]?content=room&room=[% r.id %]">[% r.string %]</a> 
       </li>
    [% END %]
[% END %]
</ul>',1270583560);
INSERT INTO "template" VALUES(51,'iphone','header','<!-- BEGIN nav -->
<div class="toolbar">
  <h1 id="pageTitle"></h1>
  <a id="backButton" class="button" href="#"></a>
</div>',1270487171);
INSERT INTO "template" VALUES(52,'iphone','main','<ul id="house" title="house" selected="true">
    <li id="lights_tab">
        <a href="[% Catalyst.uri_for("/iphone") %]?content=lights">Lights</a>
    </li>
    <li id="rooms_tab">
        <a href="#rooms">Rooms</a>
    </li>
    <li id="devices_tab">
        <a href="#devices">Devices</a>
    </li>
    <li id="windows_tab">
        <a href="#windows">Windows</a>
    </li>
    <li id="motion_tab">
        <a href="#motions">Motion</a>
    </li>
    <li id="light_tab">
        <a href="#lights">Light</a>
    </li>
    <li id="sensors_tab">
        <a href="#sensors">Sensors</a>
    </li>
</ul>',1270579931);
INSERT INTO "template" VALUES(53,'iphone','devices','[% USE table_class = Class(''ZenAH::Model::CDBI::Room'') %]
[% SET rooms = table_class.retrieve_all() %]
<ul id="devices" title="Devices">
  [% FOR r = rooms %]
        <li id="[% r.name %]" class="group">[% r.string %]</li>
       [% FOR d = r.devices %]
            <li id="[% d.name %]">[% d.string %]</li>
        [% END %]
   [% END %]
</ul>
',1270581736);
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
         [% d.string %]
        <var class="_lookup">...</var>
     </a>
   </div>
[% END %]
</fieldset>

<h2>Sensors:</h2>
<fieldset>xw
[% FOR d = room.devices %]
  [% NEXT UNLESS d.type == ''Sensor'' %]
  [% NEXT UNLESS d.device_controls %]
  [% PROCESS iphone/sensor device = d %]
[% END %]
</fieldset>
</form>

 [% FOR d = room.devices %]
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
[% END %]
',1271171208);
INSERT INTO "template" VALUES(55,'iphone','device','[% FOR control = device.device_controls %]
  <option value="[% control.name %]">[% control.string %]</option> 
[% END %]',1270978329);
COMMIT;