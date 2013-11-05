Keron
=====

**Ker**bal **On**line.

Use Unity Network features, enabling you to play with friends (and foes?).

Heavy inspiration from and credits to https://github.com/TehGimp/KerbalMultiPlayer.

Design
------

The server runs in non-authoritative fashion: clients send updates and they are broadcasted to everybody through the server.

Each client runs in their own subspace. It enables everyone to warp at will.
Players can synchronize with each other:

* Future ships will only appear when on rails. This means one cannot disturb a ship which is not online.
* Past ship will appear iff on rails.

It enables players to move back and forth in their timelines.

Vessels are online iff they are on-rails, i.e. on a stable orbit.


Technicalities
--------------

The client is a standard KSP Plugin which leverage Unity Networking functionalities.

The server is developped in C++ for technical reasons, using RakNet 3.732 (the one that matches Unity at the time of this writing).
The server project uses CMake for portability.
