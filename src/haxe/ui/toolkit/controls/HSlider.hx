package haxe.ui.toolkit.controls;

import flash.events.MouseEvent;
import flash.geom.Point;
import haxe.ui.toolkit.core.interfaces.Direction;
import haxe.ui.toolkit.core.Screen;

/**
 Horizontal slider bar control
 
 <b>Events:</b>
 
 * `Event.CHANGE` - Dispatched when value of the progess bar has changed
 **/
class HSlider extends Slider {
	public function new() {
		super();
		direction = Direction.HORIZONTAL;
	}
	
	//******************************************************************************************
	// Event handler overrides
	//******************************************************************************************
	private override function _onBGMouseDown(event:MouseEvent):Void {
		if (!_thumb.hitTest(event.stageX, event.stageY)){
			_thumb.x = event.localX - (_thumb.width*.5);
			_thumb.onMouseDown();
			_onMouseDown(event);
			_onScreenMouseMove(event);
		}
	}

	private override function _onMouseDown(event:MouseEvent):Void {
		startTracking(event.stageX - _thumb.stageX);
	}

	private override function _onScreenMouseMove(event:MouseEvent):Void {
		var xpos:Float = event.stageX - this.stageX - _mouseDownOffset;
		pos = Std.int(calcPosFromCoord(xpos));
	}
	
	private override function _onBackgroundMouseDown(event:MouseEvent):Void {
		if (_thumb.hitTest(event.stageX, event.stageY) == false) {
			var xpos:Float = event.stageX - this.stageX;
			xpos -= _thumb.width / 2;
			pos = Std.int(calcPosFromCoord(xpos));
			_thumb.state = Button.STATE_DOWN;
			startTracking(_thumb.width / 2);
		}
	}
	
	//******************************************************************************************
	// Helpers
	//******************************************************************************************
	private function startTracking(offset:Float):Void {
		_mouseDownOffset = offset;
		
		Screen.instance.addEventListener(MouseEvent.MOUSE_UP, _onScreenMouseUp);
		Screen.instance.addEventListener(MouseEvent.MOUSE_MOVE, _onScreenMouseMove);
	}

	//******************************************************************************************
	// Overrides
	//******************************************************************************************
	private override function calcPosFromCoord(xpos:Float):Float {
		var minX:Float = 0;
		var maxX:Float = layout.usableWidth - _thumb.width;
		
		if (xpos < minX) {
			xpos = minX;
		} else if (xpos > maxX) {
			xpos = maxX;
		}
		
		var ucx:Float = layout.usableWidth;
		ucx -= _thumb.width;
		var m:Int = Std.int(max - min);
		var v:Float = xpos - minX;
		var newValue:Float = min + ((v / ucx) * m);
		return newValue;
	}
	
}