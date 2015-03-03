using UnityEngine;

namespace client
{
	[KSPAddon(KSPAddon.Startup.SpaceCentre , false)]
	public class ChatWindow : AKeronWindow
	{
		private GUIStyle buttonStyles;
		private string message = "";
		private string messages = "";

		public ChatWindow () : base()
		{
			windowTitle = "Fenêtre de chat";
		}
		
		#region IKeronWindow implementation

		protected override void DrawContent (int windowID)
		{
			GUILayout.BeginVertical();
			{
				GUILayout.Label (messages);
				GUILayout.Label ("Message to sent: ");
				message = GUILayout.TextArea (message);
				if (GUILayout.Button ("Envoyer", buttonStyles, GUILayout.ExpandWidth (true))) {//GUILayout.Button is "true" when clicked	
					if (ConnexionUtils.isConnected() && message != null && !"".Equals(message)) {
						messages += "\n" + ConnexionUtils.sendChatMessage("FloFlal", message);
						message = "";
					}
				}
				//if (GUILayout.Button ("Save Game", buttonStyles, GUILayout.ExpandWidth (true))) {//GUILayout.Button is "true" when clicked	
				//	Debug.Log ("on demande de sauvegarder le jeu");
				//	string gameSaved = GamePersistence.SaveGame ("KeronState.save", "GameData/Keron/", SaveMode.OVERWRITE);
				//	Debug.Log ("Le retour de la sauvegarde : " + gameSaved);
				//}
			}
			GUILayout.EndVertical();
		}

		protected override void InitStyles ()
		{
			buttonStyles = new GUIStyle(GUI.skin.button); 
			buttonStyles.normal.textColor = buttonStyles.focused.textColor = Color.white;
			buttonStyles.hover.textColor = buttonStyles.active.textColor = Color.yellow;
			buttonStyles.onNormal.textColor = buttonStyles.onFocused.textColor = buttonStyles.onHover.textColor = buttonStyles.onActive.textColor = Color.green;
			buttonStyles.padding = new RectOffset(8, 8, 8, 8);
		}

		#endregion
	}
}

