using System.Collections.Generic;
using UnityEngine;

namespace client
{
	/// <summary>
	/// The window used to connect to a server and to manage saved servers
	/// </summary>
	[KSPAddon(KSPAddon.Startup.MainMenu, false)]
	public class ConnexionWindow : AKeronWindow
	{
		/// <summary>
		/// The server URL/IP + port to connect to
		/// </summary>
		private string server = "";

		/// <summary>
		/// The name of the user who wants to connect to the server
		/// </summary>
		private string surnom = "";

		/// <summary>
		/// The button styles.
		/// </summary>
		protected GUIStyle buttonStyles;

		/// <summary>
		/// The server list styles.
		/// </summary>
		protected GUIStyle serverListStyles;

		/// <summary>
		/// The saved servers list.
		/// </summary>
		protected List<string> savedServersList = new List<string>();

		/// <summary>
		/// Initializes a new instance of the <see cref="client.ConnexionWindow"/> class,
		/// in particular the window title.
		/// </summary>
		public ConnexionWindow () : base()
		{
			ConnexionUtils.disconnect ();
			windowTitle = "Connexion au serveur";
		}

		#region AKeronWindow implementation

		/// <summary>
		/// Inits the styles used in the window.
		/// </summary>
		protected override void InitStyles ()
		{
			// initialize the buttons style
			buttonStyles = new GUIStyle(GUI.skin.button); 
			buttonStyles.normal.textColor = buttonStyles.focused.textColor = Color.white;
			buttonStyles.hover.textColor = buttonStyles.active.textColor = Color.yellow;
			buttonStyles.onNormal.textColor = buttonStyles.onFocused.textColor = buttonStyles.onHover.textColor = buttonStyles.onActive.textColor = Color.green;
			buttonStyles.padding = new RectOffset(8, 8, 8, 8);

			// initialize the saved server list style
			serverListStyles = new GUIStyle (GUI.skin.box);
			serverListStyles.normal.textColor = serverListStyles.focused.textColor = Color.white;
			buttonStyles.hover.textColor = buttonStyles.active.textColor = Color.yellow;
		}

		/// <summary>
		/// Draws the content of the window.
		/// </summary>
		/// <param name="windowID">Window I.</param>
		protected override void DrawContent (int windowID)
		{
			GUILayout.BeginVertical();
			{
				// The server name region
				GUILayout.BeginHorizontal ();
				{
					GUILayout.Label ("Server Address: ");
					server = GUILayout.TextField (server);
				}
				GUILayout.EndHorizontal ();

				// the user name region
				GUILayout.BeginHorizontal ();
				{
					GUILayout.Label ("Surname: ");
					surnom = GUILayout.TextField (surnom);
				}
				GUILayout.EndHorizontal ();

				// the buttons region
				GUILayout.BeginHorizontal ();
				{
					if (GUILayout.Button ("Save", buttonStyles, GUILayout.ExpandWidth (true))) {//GUILayout.Button is "true" when clicked	
						Debug.Log ("On a cliqué sur le bouton save: " + server);
						savedServersList.Add(server);
					}
					if (GUILayout.Button ("Connect", buttonStyles, GUILayout.ExpandWidth (true))) {//GUILayout.Button is "true" when clicked	
						Debug.Log ("On a cliqué sur le bouton connect: " + server + " avec le surnom: " + surnom);
						if (server != null && !"".Equals (server) && surnom != null && !"".Equals (surnom)) {
							Debug.Log ("Initializing client...");

							ConnexionUtils.connectTo (server, surnom);
							if (ConnexionUtils.isConnected ()) {
								Debug.Log ("on charge le jeu");
								Game game = GamePersistence.LoadGame ("KeronMultiGame", "../GameData/Keron", true, false);
								game.Load ();
								game.Start ();
							}
						}
					}
					if (GUILayout.Button ("Erase", buttonStyles, GUILayout.ExpandWidth (true))) {//GUILayout.Button is "true" when clicked	
						Debug.Log ("On a cliqué sur le bouton erase");
						server = "";
					}
				}
				GUILayout.EndHorizontal ();

				// the saved server region
				savedServersList.ForEach(
					s => 
					{
						if (GUILayout.Button (s, serverListStyles, GUILayout.ExpandWidth (true))) {//GUILayout.Button is "true" when clicked	
							UnityEngine.Debug.Log ("On a cliqué sur le bouton : " + s);
							server = s;
						}
					}
				);
			}
			GUILayout.EndVertical();
		}

		#endregion


	}
}

