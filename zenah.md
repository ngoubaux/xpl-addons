# Introduction #

Zenah has two part:
  * Engine
  * Web site

This page try to explain a little bit how to use Zenah.

# rules engine #

First you can see the wiki page on the zenah web site: [here](http://www.zenah.org.uk/wiki/Engine)
Zenah has several rule types:
  * **xpl**: the trigger is based on each xPL message received by the engine.
  * **scene** : the trigger is call by other rules
  * **at**: the trigger is based `xPL::Timer` events

### Rule type: xpl ###

A xpl rule can be build with
  * message\_type : can be
    * xpl-trig
    * xpl-stat
    * both (xpl-trig|xpl-stat)
  * class: the name of the xPL class. Look on the [xPL Project](http://xplproject.org.uk) schema wiki page to know all class names: [here](http://xplproject.org.uk/wiki/index.php?title=XPL_Message_Schema)
  * device: can be
    * the device name
    * lookup\_map`[`_type_`]` where type is the map type the rule will search for matching
    * lookuptype_`[`_values_`]`_

```
message_type="(xpl-trig|xpl-stat)" class="sensor.basic" device="lookup_map[ztamp]"
```