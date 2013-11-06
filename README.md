Keron
=====

**Ker**bal **On**line.

Use Unity Network features, enabling you to play with friends (and foes?).

Heavy inspiration from and credits to [KMP](https://github.com/TehGimp/KerbalMultiPlayer).

Design
------

The server runs in non-authoritative fashion: clients send updates and they are broadcasted to everybody through the server.

Each client runs in their own subspace. It enables everyone to warp at will.
Players can synchronize with each other:

* Future ships will only appear when on rails. This means one cannot disturb a ship which is not online.
* Past ship will appear iff on rails.

It enables players to move back and forth in their timelines.

Vessels are online iff they are on-rails, i.e. on a stable orbit.

### KSC

The KSC launchpad and runway are viewed as shared resources: one player is allowed at a given time.

Two cylindrical corridors are defined for each shared resource. As long as there is something in the corridor
(an active player, a debris, a plane, a bird, superman...), a player cannot claim the resource.

For the launchpad, it would be a corridor 100m wide and 10km tall (note: subject to change).
For the runway, it would be 100m tall and 500m wide before and after the track.

Example:

* Alice requests a launch. The corridor is clear, he acquires it and proceed to his launch.
* Bob sees that Alice has reached the 10k limit. He requests a launch, but there are unlanded debris: he must wait.
* After a time, Bob requests the corridor. All debris are landed, the 10k corridor is clear,
  but there are debris on the launchpad (such as [TT18-A LSE](http://wiki.kerbalspaceprogram.com/wiki/TT18-A_Launch_Stability_Enhancer)s).
  He can clear it using the standard _Clear Launchpad_ button.

If a player disconnects while in a corridor, its vessel shall be destroyed immediately.

Technicalities
--------------

The client is a standard KSP Plugin which leverage Unity Networking functionalities.

The server is developped in C++ for technical reasons, using RakNet 3.732 (the one that matches Unity at the time of this writing).
The server project uses CMake for portability.
