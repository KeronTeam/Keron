using UnityEngine;

namespace client
{
	public abstract class AKeronWindow : MonoBehaviour
	{
		private Rect _windowPos;
		private string _windowTitle;

		public AKeronWindow (){}

		public Rect windowPos {
			get { return _windowPos; }
			set { _windowPos = value; }
		}

		public string windowTitle {
			get { return _windowTitle; }
			set { _windowTitle = value; }
		}

		public void DrawWindow ()
		{
			InitStyles();
			GUI.skin = HighLogic.Skin;
			windowPos = GUILayout.Window(1, windowPos, DrawContent, windowTitle, GUILayout.MinWidth(300));
		}

		protected abstract void DrawContent (int windowID);

		protected abstract void InitStyles ();

		public void OnGUI() 
		{
			this.DrawWindow ();
		}
	}
}

