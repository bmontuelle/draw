library draw;
import 'dart:html';

DrawWindow drawWindow;

abstract class View<T> {
  final T elem;

  View(this.elem) {
    bind();
  }

  // bind to event listeners
  void bind() { }
}

class DrawWindow extends View<CanvasElement> {
  DrawWindow(CanvasElement elem) : super(elem);
  bind() {
    elem.on.mouseMove.add((e) => onMouseMove());
    elem.on.mouseDown.add((e) => onMouseDown());
    elem.on.mouseUp.add((e) => onMouseUp());
  }
  onMouseMove(Event e) {
  }
  onMouseDown() {
  }
  onMouseUp() {
  }
}

void main() {
  CanvasElement canvas = query("#drawZone");
  
  drawWindow = new DrawWindow(canvas);
  var context = canvas.context2d;
  
  
}

