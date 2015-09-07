Keron
=====

 [![Travis CI](https://img.shields.io/travis/KeronTeam/Keron.svg?style=flat-square&label=Linux)](https://travis-ci.org/KeronTeam/Keron/)
 [![AppVeyor](https://img.shields.io/appveyor/ci/gregoire-astruc/keron.svg?style=flat-square&label=Windows)](https://ci.appveyor.com/project/gregoire-astruc/keron)

**Ker**bal **On**line.

Enabling you to play with friends (and foes?).

Heavy inspiration from and credits to [KMP](https://github.com/TehGimp/KerbalMultiPlayer).

If you are looking for a (somewhat) working product, please head over to [DarkMultiPlayer](https://github.com/godarklight/DarkMultiPlayer).


See `CHANGELOG.md` for the list of comprehensive changes.

Dependencies
------------

- [ENet](http://enet.bespin.org/): Network library.
- [ENetCS](https://github.com/KeronTeam/enetcs): ENet for C# bindings (client-side).
- [FlatBuffers](https://github.com/google/flatbuffers): Serialization library.
- [LMDB](http://symas.com/mdb/): Eembedded datastore (server-side).
- [lmdb++](https://github.com/bendiken/lmdbxx): C++11 wrapper for LMDB.
- [spdlog](https://github.com/gregoire-astruc/spdlog): Logging library. 

Building
--------

The project dependencies are rather small and self-sufficient.
Therefore, we use [submodules](http://www.git-scm.com/book/en/v2/Git-Tools-Submodules) to guarantee
that we share the same version across all builds.

Get the submodules:
```sh
git submodule init
git submodule update
```


Get a copy of [CMake 3.1](http://www.cmake.org/download/), or above, and make it available in your PATH.
Then run cmake with your flavor of arguments:
```sh
# Linux build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DKSP_MANAGED_PATH=/path/to/your/ksp/Managed ..

# Windows build
cd build
cmake -G 'Visual Studio 14 2015 Win64' -DCMAKE_BUILD_TYPE=Debug -DKSP_MANAGED_PATH=C:/Path/To/KSP/Managed ..
```
See the CI scripts in `scripts` for other configurations.

or use CMake's own GUI.

Design
------

**THIS SECTION IS OUT OF DATE**. See the issues for details.

The server runs in non-authoritative fashion:
clients send updates and they are broadcasted to everybody through the server.

### KSC

**THIS SECTION IS OUT OF DATE**. See the issues for details.

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

### Warp

**THIS SECTION IS OUT OF DATE**. See the issues for details.

Warping handling is probably _the_ most challenging issue of networked KSP.
Disabling it all together is not a valid option (who would spend _months_ to get to Eve,
or simply _hours_ to get to the Mun?).

Same goes with a shared warp-time

Imagine:
> Got to go to Eve. warping x1000. Sorry folks who were doing high-precision docking manoeuvers!

Or even:
> Got to re-entry. I take the lock on the time. Sorry folks who'd like to go to Eve before retirement!

Those are simply unacceptable from a gameplay perspective.

The answer to this is simple: subspaces. Each player plays in his own timeline, and may catch up with the server.
The server time is simply the highest available.

This system implies a very simple, very important rule: _one cannot interact with a vessel's past or future._ **Ever.**

Reason is that you weren't there at that time.
So you shouldn't interfere with the vessel if you have not caught up with it.
It's completely unlogical from a realistic perspective but we believe it to be to the gameplay's profits.
And we would not have to deal with alternatives futures, which would be a mess.

Moreover a player may never go back in his own timeline (just trust the Time Lords on this).

This together means:

* **Late** players would see a _replay_ of future ships, as well as their trajectories.
* **Current** players would see past ship with a _predicted trajectories_, which may change at any time.

> But what happens if a past ship is on collision course with a future ship?

Well, that's tricky. Let me put that simply: **they will collide at the point and time they should collide.**.

Multiplayer KSP is no fairy tale.

Technicalities
--------------

**THIS SECTION IS OUT OF DATE**. See the issues for details.

The client is a standard KSP Plugin. Though it originally intended to leverage Unity Networking functionalities, this turned out a dead end (basically, client would have to maintain deep copies of watched objects for the network serializer to kick in).

Instead, we use [Lidgren.Net](http://code.google.com/p/lidgren-network-gen3/).

Both the client and the server are written in C# and relies on:

* KSP (duh).
* [Lidgren.Net](http://code.google.com/p/lidgren-network-gen3/)
* [ZLibNet](https://zlibnet.codeplex.com/) and [ZLib](http://zlib.net/) (used for compressing _large_ datasets)
