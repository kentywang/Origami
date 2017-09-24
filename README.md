# Origami

### 👩‍💻 Pinch to resize any window
![](https://github.com/kentywang/Origami/blob/master/demo.gif)

On macOS, there are plenty of trackpad gestures for navigating the desktop environment, such as switching between Spaces or viewing all windows open. But manually resizing a window still requires placing the cursor over the edge of a window and dragging. And if I wanted to also resize in another direction, I would have to place the cursor over the other edge and drag again. Considering the technology available, I think this is pretty unrefined.

I built this app so that I could resize windows the same way I zoom in and out when looking at photos: by spreading and pinching with two fingers. This not only means that windows can be resized in all four directions simultaneously but also that each side can be resized independently from the others.

### Usage
Hold down Option (⌥) and Command (⌘) and use one finger to drag the entire window or two fingers to resize it.

### Download
The latest build can be found under [releases](https://github.com/kentywang/Origami/releases/).

### Acknowledgements
Thanks goes to [jnordberg](https://github.com/jnordberg) for building a solution to retrieve raw multitouch data from the trackpad and also for building a [great visualization app](https://github.com/jnordberg/FingerMgmt) for the data that came in super handy for sensitivity tuning and debugging.

Thanks also goes to [keith](https://github.com/keith) for providing a [nice Swift app](https://github.com/keith/ModMove) that served as this app's base. 
