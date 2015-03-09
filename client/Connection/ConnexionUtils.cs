using ENet;
using UnityEngine;
using keron.messages;
using FlatBuffers;

namespace client
{
	public static class ConnexionUtils
	{
		public static Host host;
		public static Peer peer;
		public static ENet.Event @event;
		public static string userName = "";

		private static bool connected = false;

		public static void connectTo(string server)
		{
			int port = 20336;
			string ipServer = server;
			if (server.Contains (":")) {
				string[] serverSplited = server.Split (':');
				ipServer = serverSplited [0];
				port = int.Parse (serverSplited [1]);
			}

			ConnexionUtils.host.InitializeClient (1);
			ConnexionUtils.peer = ConnexionUtils.host.Connect (ipServer, port, 0, 2);
			if (ConnexionUtils.host.Service (2000, out ConnexionUtils.@event)) {
				if (ENet.EventType.Connect == ConnexionUtils.@event.Type) {
					ConnexionUtils.connected = true;
					Debug.Log ("Connected to server at IP/port " + peer.GetRemoteAddress ());
				}
			} else {
				Debug.LogError ("Problème de connexion, met plus de 2s à répondre");
				peer.Disconnect (0);
				host.Dispose ();
			}
		}

		public static void disconnect ()
		{
			if (ConnexionUtils.isConnected()) {
				ConnexionUtils.peer.Disconnect (0);
			}
		}

		public static bool isConnected ()
		{
			return ConnexionUtils.connected;
		}

		public static string receiveChatMessage ()
		{
			string colorFrom = "CCCCFF";
			string returnMessage = "";
			if (ConnexionUtils.host.Service (2000, out ConnexionUtils.@event)) {
				if (ENet.EventType.Receive == ConnexionUtils.@event.Type) {
					Debug.Log ("Reception d'un message");
					Debug.Log ("Message reçu sur le channel " + @event.ChannelID);

					NetMessage messageRecieved = NetMessage.GetRootAsNetMessage (new ByteBuffer(@event.Packet.GetBytes()));
					if (messageRecieved.MessageType() == NetID.Chat) {
						Chat mesChat = new Chat ();
						mesChat = (Chat)messageRecieved.Message (mesChat);
						Debug.Log ("message de chat de " + mesChat.From () + " : " + mesChat.Message ());
						if (mesChat.From () == userName) {
							colorFrom = "FF8585";
						}
						returnMessage = "<b><color=" + colorFrom + ">" + mesChat.From () + ": " + "</color></b>" + mesChat.Message ();
					}
				}
			} else {
				Debug.LogError ("Problème de connexion, met plus de 2s à répondre");
			}
			return returnMessage;
		}

		public static string sendChatMessage (string from, string message)
		{
			FlatBufferBuilder fbb = new FlatBufferBuilder (1);

			userName = from;

			int mon = NetMessage.CreateNetMessage (fbb, 
				NetID.Chat,
				Chat.CreateChat (fbb, 
					fbb.CreateString (from), 
					fbb.CreateString (message)));

			NetMessage.FinishNetMessageBuffer (fbb, mon);

			peer.Send (0, fbb.SizedByteArray (), PacketFlags.Reliable);

			return ConnexionUtils.receiveChatMessage ();
		}
	}
}

