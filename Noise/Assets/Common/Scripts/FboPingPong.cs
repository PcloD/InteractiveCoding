using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace Utils {

	public class FboPingPong {

		private int _readTex  = 0;
		private int _writeTex = 1;
		private RenderTexture[] _buffer;

		public FboPingPong (int width_, int height_, FilterMode filterMode = FilterMode.Point, TextureWrapMode wrapMode = TextureWrapMode.Repeat){

			_readTex  = 0;
			_writeTex = 1;

			_buffer = new RenderTexture [2];

			for (int i = 0; i < 2; i++){
				_buffer [i] = new RenderTexture (width_, height_, 0, RenderTextureFormat.ARGBFloat);
				_buffer [i].hideFlags  = HideFlags.DontSave;
				_buffer [i].filterMode = filterMode;
				_buffer [i].wrapMode   = wrapMode;
				_buffer [i].Create ();
			}

			Clear ();
		}

		public void Swap (){
			int t     = _readTex;
			_readTex  = _writeTex;
			_writeTex = t;
		}

		public void Clear (){
			for (int i = 0; i < _buffer.Length; i++){
				RenderTexture.active = _buffer [i];
				GL.Clear (false, true, Color.black);
				RenderTexture.active = null;
			}
		}

		public void Delete (){
			if (_buffer != null) {
				for (int i = 0; i < _buffer.Length; i++){
					_buffer[i].Release ();
					_buffer[i].DiscardContents ();
					_buffer[i] = null;
				}
			}
		}

		public RenderTexture GetReadTex (){
			return _buffer [_readTex];	
		}

		public RenderTexture GetWriteTex (){
			return _buffer [_writeTex];
		}

	}

}


