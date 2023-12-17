# Waypoint Tow / Hauling

![wp-tow-hauling](https://github.com/WaypointRP/wp-tow-hauling/assets/18689469/b4babe29-9ebb-4923-ada5-38e7a054fcdb)

This script provides an intuitive and user-friendly solution for towing and hauling vehicles and props. Unlike other scripts, it attaches vehicles and objects at their exact positions rather than teleporting it to a hardcoded spot. You can attach any number of vehicles/objects, the only limit is the physical space on your tow vehicle. Players can configure their towing/hauling load however they see fit and let their imagination run wild. By default, there is no limit to what vehicles or objects can be towed, allowing for maximum creativity and roleplay immersion. However, you can configure the script to limit the vehicles that can be used to tow if you wish.


Preview: https://youtu.be/oTn4ASd33R8

## Overview

Some examples of what you can do with this script:
- haul multiple offroad / non street legal vehicles to your destination
 - haul motorcycle(s) on the back of a pickup truck
- haul boats on a trailer
- haul multiple vehicles using the car carrier trailer (tr2)
- haul cargo on a trailer (crates, pallets, etc)
- create a mobile farmers market on the back of a pickup truck
- create a mobile firework show on a party bus (with [wp-fireworks](https://backsh00ter.tebex.io/package/5753511))
- create immersive jobs where players can haul vehicles or props to a destination

The scenarios that can be created with this script are limited only by your imagination.

Best paired with a script that can be used for placing props in the world such as [Waypoint Placeables](https://github.com/WaypointRP/wp-placeables).


## Usage

**Towing**
1. Enter tow selection mode by using the command `/tow` or by using the event `wp-hauling:client:startTowSelection`
2. Look at and select the vehicle you will be towing to
3. Look at and select the vehicle/object you want to tow/haul
4. Confirm or cancel the selection
5. If confirmed, the vehicle/object will be attached to the tow vehicle at its exact position

Repeat steps 1-5 as many times as you like to attach more vehicles/objects.

**Untowing**
1. Enter untow selection mode by using the command `/untow` or by using the event `wp-hauling:client:startUntowSelection`
2. Look at and select the vehicle/object you want to untow
3. Vehicle/object will be unattached and remain in the same position

## Setup

1. Enable the script in your server.cfg
2. Configure the script in the config.lua
    - Choose the notification framework you are using with `Config.Notify`.
    - Choose the keybinds you want to use for selecting and canceling select mode: `Config.ConfirmVehicleSelectionKey` / `Config.ExitVehicleSelectionKey`
    - Decide whether you want to limit the vehicles that can be used to tow with `Config.AllowAllVehiclesToTow` and `Config.AllowedTowVehicles`. 
        - _Recommendation: For the best experience and enabling fullest potential of creativity, I do NOT recommend limiting the allowed vehicles._
    - Decide whether you want to allow attaching props with `Config.AllowHaulingProps`.
3. By default, the commands `/tow` and `/untow` are used to start the actions. You can use the provided events to hook these up in your own way (ex: Radial menu).
    `wp-hauling:client:startTowSelection` and `wp-hauling:client:startUntowSelection`
 
## Additional Notes

For the best experience, it is recommended to have a script for placing/carrying/moving props in the world. 
[Waypoint Placeables](https://github.com/WaypointRP/wp-placeables) is a great option for this and also provides ramp items that can be used to easily load vehicles onto trailers.

This script is designed to be immersive and attach vehicles in place. As such it does not teleport vehicles onto your tow vehicle. To be able to tow broken down cars, it is recommended to have a script for pushing broken down cars. You can then place a ramp, and push the vehicle up the ramp onto your tow trailer.


## Performance

This script was written with performance in mind. The only time the resource will run higher than 0.00ms is while in tow/untow select mode when we are running the raycast thread. Otherwise there are no other threads or loops running. 

Idle: 0.00ms
With vehicles attached: 0.00ms
Attachment mode active: 0.02ms - 0.08ms (drawing markers + using raycast to detect selection)
    - After selection is confirmed resource returns to 0.00ms


## Dependencies

This resource was designed to be **standalone** and does not require any other resources to function. 

If you want to use notifications, there is a built in framework wrapper around the `Notify()` function to hook into the notifications framework of your choice.

## Gallery

![image](https://github.com/WaypointRP/wp-tow-hauling/assets/18689469/05b46c96-651a-4c87-9f1e-0cafffd9b9c9)

![image](https://github.com/WaypointRP/wp-tow-hauling/assets/18689469/deadcb9b-d983-41a2-a7e5-3dbb6245b56b)

![image](https://github.com/WaypointRP/wp-tow-hauling/assets/18689469/62d2b874-ba74-4753-bbc4-caea9884806f)

![image](https://github.com/WaypointRP/wp-tow-hauling/assets/18689469/4a00075f-19fa-4a54-9f71-90d2da4c8d46)



