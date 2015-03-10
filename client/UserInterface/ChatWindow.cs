using UnityEngine;

namespace client
{
	/// <summary>
	/// The window used to chat when connected in the server
	/// </summary>
	[KSPAddon(KSPAddon.Startup.SpaceCentre , false)]
	public class ChatWindow : AKeronWindow
	{
		/// <summary>
		/// The button styles.
		/// </summary>
		private GUIStyle buttonStyles;

		/// <summary>
		/// The message to send.
		/// </summary>
		private string message = "";

		/// <summary>
		/// The chat messages sent and received
		/// </summary>
		private string messages = "";

		/// <summary>
		/// Called at each update of the game. Used to check received messages
		/// </summary>
		public void FixedUpdate () {
			Debug.Log ("On entre dans fixedUpdate de  chatWindow");

			string receiveMessage = ConnexionUtils.receiveChatMessage ();
			if ( !"".Equals(receiveMessage) )
			{
				messages += '\n' + receiveMessage;
			}
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="client.ChatWindow"/> class,
		/// in particular define the title of the window
		/// </summary>
		public ChatWindow () : base()
		{
			windowTitle = "Fenêtre de chat";
		}
		
		#region IKeronWindow implementation

		/// <summary>
		/// Draws the content of the window.
		/// </summary>
		/// <param name="windowID">Window I.</param>
		protected override void DrawContent (int windowID)
		{
			GUILayout.BeginVertical();
			{
				GUILayout.Label (messages);
				GUILayout.Label ("Message to sent: ");
				message = GUILayout.TextArea (message);
				if (GUILayout.Button ("Envoyer", buttonStyles, GUILayout.ExpandWidth (true))) {//GUILayout.Button is "true" when clicked	
					if (ConnexionUtils.isConnected() && message != null && !"".Equals(message)) {
						ConnexionUtils.sendChatMessage(message);
						message = "";
					}
				}
			}
			GUILayout.EndVertical();
		}

		/// <summary>
		/// Inits the styles used in the window.
		/// </summary>
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

