using ENet;
using UnityEngine;
using keron.messages;
using FlatBuffers;

namespace client
{
	/// <summary>
	/// Save the connection parameters and manage the network uage.
	/// </summary>
	public static class ConnexionUtils
	{
		/// <summary>
		/// The host.
		/// </summary>
		public static Host host;

		/// <summary>
		/// The server.
		/// </summary>
		public static Peer peer;

		/// <summary>
		/// The event received.
		/// </summary>
		public static ENet.Event @event;

		/// <summary>
		/// The user name in the server.
		/// </summary>
		public static string userName = "";

		/// <summary>
		/// <b>true</b> if the connection with the server has been
		/// established, <b>false</b> otherwise
		/// </summary>
		private static bool connected = false;

		/// <summary>
		/// Enable to connect to a server
		/// </summary>
		/// <param name="server">Server.</param>
		public static void connectTo(string server, string user)
		{
			userName = user;
			int port = 20336;
			string ipServer = server;

			// parse to have the server IP and Port
			if (server.Contains (":")) {
				string[] serverSplited = server.Split (':');
				ipServer = serverSplited [0];
				port = int.Parse (serverSplited [1]);
			}

			// initialize the connection, after 2s to wait, it is concidered
			// that the server does not respond
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

		/// <summary>
		/// Disconnect from the server connected to.
		/// </summary>
		public static void disconnect ()
		{
			if (ConnexionUtils.isConnected()) {
				ConnexionUtils.peer.Disconnect (0);
			}
		}

		/// <summary>
		/// Are we already connected to a server ?
		/// </summary>
		/// <returns><c>true</c>, if connected, <c>false</c> otherwise.</returns>
		public static bool isConnected ()
		{
			return ConnexionUtils.connected;
		}

		/// <summary>
		/// Receives a chat message.
		/// </summary>
		/// <returns>The chat message.</returns>
		public static string receiveChatMessage ()
		{
			string colorFrom = "CCCCFF";
			string returnMessage = "";
			// the time out is set to 10ms because we are going to pass here very often
			if (ConnexionUtils.host.Service (10, out ConnexionUtils.@event)) {
				if (ENet.EventType.Receive == ConnexionUtils.@event.Type) {
					Debug.Log ("Reception d'un message");
					Debug.Log ("Message reçu sur le channel " + @event.ChannelID);

					NetMessage messageReceived = NetMessage.GetRootAsNetMessage (new ByteBuffer(@event.Packet.GetBytes()));
					if (messageReceived.MessageType == NetID.Chat) {
						Chat mesChat = new Chat ();
						mesChat = (Chat)messageReceived.GetMessage (mesChat);
						Debug.Log ("message de chat de " + mesChat.From + " : " + mesChat.Message );
						if (mesChat.From == userName) {
							colorFrom = "FF8585";
						}
						returnMessage = "<b><color=#" + colorFrom + ">" + mesChat.From + ": " + "</color></b>" + mesChat.Message;
					}
				}
			} else {
				Debug.LogError ("Pas de message (pas de reception après 10ms)");
			}
			return returnMessage;
		}

		/// <summary>
		/// Sends a chat message.
		/// </summary>
		/// <param name="message">Message.</param>
		public static void sendChatMessage (string message)
		{
			FlatBufferBuilder fbb = new FlatBufferBuilder (1);

			var mon = NetMessage.CreateNetMessage (fbb,
				NetID.Chat,
				Chat.CreateChat (fbb,
					fbb.CreateString (userName),
					fbb.CreateString (message)).Value);

			NetMessage.FinishNetMessageBuffer (fbb, mon);

			peer.Send (0, fbb.SizedByteArray (), PacketFlags.Reliable);
		}
	}
}

