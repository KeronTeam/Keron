using UnityEngine;

namespace client
{
	/// <summary>
	/// The basic definition of all windows of Keron
	/// </summary>
	public abstract class AKeronWindow : MonoBehaviour
	{
		/// <summary>
		/// The window position.
		/// </summary>
		private Rect _windowPos;

		/// <summary>
		/// The window title.
		/// </summary>
		private string _windowTitle;

		/// <summary>
		/// Gets or sets the window position.
		/// </summary>
		/// <value>The window position.</value>
		public Rect windowPos {
			get { return _windowPos; }
			set { _windowPos = value; }
		}

		/// <summary>
		/// Gets or sets the window title.
		/// </summary>
		/// <value>The window title.</value>
		public string windowTitle {
			get { return _windowTitle; }
			set { _windowTitle = value; }
		}

		/// <summary>
		/// Draws the window, basically call initStyles to initialize the styles
		/// used in the window and the creation of the window
		/// with windowTitle as title windowPos as position and DrawContent
		/// as the content draw method.
		/// </summary>
		public void DrawWindow ()
		{
			InitStyles();
			GUI.skin = HighLogic.Skin;
			windowPos = GUILayout.Window(1, windowPos, DrawContent, windowTitle, GUILayout.MinWidth(300));
		}

		/// <summary>
		/// Draws the content of the window.
		/// </summary>
		/// <param name="windowID">Window I.</param>
		protected abstract void DrawContent (int windowID);

		/// <summary>
		/// Inits the styles used in the window.
		/// </summary>
		protected abstract void InitStyles ();

		/// <summary>
		/// Raises the GUI refresh event.
		/// </summary>
		public void OnGUI() 
		{
			this.DrawWindow ();
		}
	}
}

