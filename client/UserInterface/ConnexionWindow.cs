using System.Collections.Generic;
using UnityEngine;

namespace client
{
	[KSPAddon(KSPAddon.Startup.MainMenu, false)]
	public class ConnexionWindow : AKeronWindow
	{
		private string server = "";
		private string surnom = "";
		protected GUIStyle buttonStyles;
		protected GUIStyle serverListStyles;
		protected List<string> savedServersList = new List<string>();

		public ConnexionWindow () : base()
		{
			ConnexionUtils.disconnect ();
			windowTitle = "Connexion au serveur";
		}

		#region AKeronWindow implementation

		protected override void InitStyles ()
		{
			buttonStyles = new GUIStyle(GUI.skin.button); 
			buttonStyles.normal.textColor = buttonStyles.focused.textColor = Color.white;
			buttonStyles.hover.textColor = buttonStyles.active.textColor = Color.yellow;
			buttonStyles.onNormal.textColor = buttonStyles.onFocused.textColor = buttonStyles.onHover.textColor = buttonStyles.onActive.textColor = Color.green;
			buttonStyles.padding = new RectOffset(8, 8, 8, 8);

			serverListStyles = new GUIStyle (GUI.skin.box);
			serverListStyles.normal.textColor = serverListStyles.focused.textColor = Color.white;
			buttonStyles.hover.textColor = buttonStyles.active.textColor = Color.yellow;
		}

		protected override void DrawContent (int windowID)
		{
			GUILayout.BeginVertical();
			{
				GUILayout.BeginHorizontal ();
				{
					GUILayout.Label ("Server Address: ");
					server = GUILayout.TextField (server);
				}
				GUILayout.EndHorizontal ();
				GUILayout.BeginHorizontal ();
				{
					GUILayout.Label ("Surname: ");
					surnom = GUILayout.TextField (surnom);
				}
				GUILayout.EndHorizontal ();
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

							ConnexionUtils.connectTo (server);
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

