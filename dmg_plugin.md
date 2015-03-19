# Introduction #
As explained on its website:

Domogik is a free home automation solution. At the moment Domogik is still in development so there is no stable version yet. It is based on the xPL protocol? in order to easily use a lot of different technologies.

[Website](http://www.domogik.org/)

As Domogik is based on XPL, it is normally possible to include external device come from external module.

# How to #

Several steps are needed to add a new technology and device.
For this how to, Chacon technologie is taken as example

## Add new technology ##

Insert into _core\_device\_technology_ table

```
INSERT INTO  `domogik`.`core_device_technology` (`id`, `name`, `description`)
VALUES ('chacon',  'Chacon',  'Protocol homeeasy'),
('oregon', 'Oregon', 'Oregon Scientific weather sensors');
```

## Add new type ##

Insert into _core\_device\_type_

```
INSERT INTO `core_device_type` (`id`, `device_technology_id`, `name`, `description`) VALUES
('chacon.switch', 'chacon', 'Switch', NULL),
('chacon.dimmer', 'chacon', 'Dimmer', NULL),
('oregon.sensor',  'oregon',  'Oregon sensor',  'Oregon Scientific weather sensors');
```

## Add new model ##

Insert into _core\_device\_feature\_model_ table

```
INSERT INTO  `domogik`.`core_device_feature_model`(`id`,`name`,`feature_type`,`device_type_id`,`parameters`,`value_type`,`stat_key`,`return_confirmation`)
VALUES ('chacon.switch.switch',  'Switch',  'actuator',  'chacon.switch',  '{&quot;command&quot;:&quot;&quot;,&quot;value0&quot;:&quot;off&quot;, &quot;value1&quot;:&quot;on&quot;}', 'binary',  'command',  '0');
```