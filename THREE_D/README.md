3D
=================

3Dのサンプルスケッチ．
マウスかキーをクリックするとジオメトリが変わっていきます．

![capture](https://raw.githubusercontent.com/mattatz/InteractiveCoding/master/THREE_D/data/capture.gif)

ProcessingでShaderを使いたいと思い，
[PShaderのチュートリアル記事](https://processing.org/tutorials/pshader/)を参考にしながら作りました．

# 実装メモ
* メッシュ(PShape)をProcessingで作ろうと思ったのですが，時間がなかったのでobjファイルを[ネット](http://graphics.stanford.edu/hackliszt/meshes/sphere.obj)から拝借しました．
* vertex shader(sample.vert)では，4次元ベクトルをシードとして用いる[simplex noiseのアルゴリズム](https://github.com/ashima/webgl-noise/blob/master/src/noise4D.glsl)を使いました．このノイズの値に応じて頂点を法線方向に動かしてグニャグニャさせています．
* グニャグニャの状態から遷移する形はモデル座標をインプットとして計算を行い，球型を箱型にしたり，花のようなジオメトリになるように調整しました．(box(vec3)関数やflower(vec3)関数)
* ジオメトリをvertex shaderでグニャグニャにしたりすると法線をモデルからそのまま使うのは面倒になるので，法線はfragment shader(sample.frag)で求めるようにしています．これにより，いくらジオメトリを崩壊させても，パリッとした法線を得ることができます．
* 色は法線ベクトルの値を元に，2色を適当に補完して求めています．

## Tools

- Processing

