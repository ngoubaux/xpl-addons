# Introduction #

How to organize yours devices in Zenah.


# Details #

> A device is defined by:
    * name
    * string
    * description
    * type
    * attributes
    * controls
    * room


## name ##
The name is a "name" of the device that defined one device. It has to be unique name.
For sensor the name has to be the same as it's appear in the state table.

## string ##
The string is the Display name

## description ##
The description is a full explanation of the device.

## type ##
The type of the device can be:
  * Blind
  * Curtain
  * Sensor
  * X10App
  * X10Lamp
  * X10Light
  * X10Motion
  * Media
  * ...

## attributes ##
Attributes will be used for actions.
For exemple:
  * X10 device has _unit_ attribut with the X10 address like unit=a3
  * Sensor device has _uid_ attribut like uid=

<uid\_sensor>



## controls ##
Controls device actions the device can provide.
like:
  * x10/on
  * x10/off
  * media/on
  * media/off
  * ...