# Parallax2D

## Modern API

`Parallax2D` replaces `ParallaxBackground` and `ParallaxLayer` for 4.3+.

```gdscript
var parallax := $FarBackground as Parallax2D
parallax.scroll_scale = Vector2(0.25, 0.25)
parallax.repeat_size = Vector2(1920, 1080)
parallax.repeat_times = 3
```

- `scroll_scale = 0`: static
- `scroll_scale = 1`: camera 1:1
- `0 < scroll_scale < 1`: distant background
- `repeat_size`: texture dimensions used for tiling
- `repeat_times`: additional repeats available around the viewport

## GECS Usage

Parallax is rendering infrastructure. Keep it outside gameplay queries unless gameplay systems intentionally control parallax as visual feedback.

If a component must control parallax, use a small render Component such as `C_ParallaxState`; synchronize it in a dedicated rendering System. Do not add relation, movement, or collision components to the background.
