package haxe.ui.toolkit.core;

import flash.filters.BitmapFilter;
import flash.geom.Rectangle;
import haxe.ds.StringMap;
import haxe.ui.toolkit.core.interfaces.InvalidationFlag;
import haxe.ui.toolkit.core.interfaces.IStyleable;
import haxe.ui.toolkit.layout.GridLayout;
import haxe.ui.toolkit.style.Style;
import haxe.ui.toolkit.style.StyleHelper;
import haxe.ui.toolkit.style.StyleManager;
import haxe.ui.toolkit.util.FilterParser;

class StyleableDisplayObject extends DisplayObjectContainer implements IStyleable  {
	private var _style:Style;
	private var _storedStyles:StringMap<Style>; // styles stored for ease later
	private var _styleName:String;
	
	public function new() {
		super();
	}
	
	//******************************************************************************************
	// Overridables
	//******************************************************************************************
	private override function preInitialize():Void {
		super.preInitialize();

		buildStyles();
		if (Std.is(this, StateComponent)) {
			var state:String = cast(this, StateComponent).state;
			if (state == null) {
				state = "normal";
			}
			_style = retrieveStyle(state);//StyleManager.instance.buildStyleFor(this, cast(this, StateComponent).state);
			if (_style == null) {
				_style = StyleManager.instance.buildStyleFor(this, cast(this, StateComponent).state);
			}
		} else {
			_style = StyleManager.instance.buildStyleFor(this);
		}
		
		if (_style != null) {
			// get props from style if they exist
			if (_style.width != -1 && width == 0) {
				width = _style.width;
			}
			if (_style.height != -1 && height == 0) {
				height = _style.height;
			}

			if (_style.percentWidth != -1 && percentWidth == -1) {
				percentWidth = _style.percentWidth;
			}
			if (_style.percentHeight != -1 && percentHeight == -1) {
				percentHeight = _style.percentHeight;
			}
			
			// set layout props from style
			if (layout != null) {
				if (_style.paddingLeft != -1) {
					layout.padding.left = _style.paddingLeft;
				}
				if (_style.paddingTop != -1) {
					layout.padding.top = _style.paddingTop;
				}
				if (_style.paddingRight != -1) {
					layout.padding.right = _style.paddingRight;
				}
				if (_style.paddingBottom != -1) {
					layout.padding.bottom = _style.paddingBottom;
				}
				if (_style.spacingX != -1) {
					_layout.spacingX = _style.spacingX;
				}
				if (_style.spacingY != -1) {
					_layout.spacingY = _style.spacingY;
				}
			}
		}
		
		applyStyle();
	}
	
	public override function paint():Void {
		//super.paint(); // no point in clearing twice
		if (_width == 0 || _height == 0) { // can happen
			return;
		}
		
		var rc:Rectangle = new Rectangle(0, 0, _width, _height); // doesnt like 0 widths/heights
		StyleHelper.paintStyle(graphics, style, rc);
	}
	
	
	private override function set_id(value:String):String { // if id changes, rebuild styles
		if (value == id) {
			return value;
		}
		var v:String = super.set_id(value);
		if (_ready) {
			buildStyles();
			_style = StyleManager.instance.buildStyleFor(this);
			invalidate(InvalidationFlag.DISPLAY);
		}
		return v;
	}
	
	//******************************************************************************************
	// IStyleable
	//******************************************************************************************
	public var style(get, set):Style;
	public var styleName(get, set):String;
	
	private function get_style():Style {
		return _style;
	}
	
	private function set_style(value:Style):Style {
		_style = value;
		applyStyle();
		return value;
	}
	
	private function get_styleName():String {
		return _styleName;
	}
	
	private function set_styleName(value:String):String {
		_styleName = value;
		if (_ready) {
			buildStyles();
			_style = StyleManager.instance.buildStyleFor(this);
			invalidate(InvalidationFlag.DISPLAY);
		}
		return value;
	}
	
	public function storeStyle(id:String, value:Style):Void {
		if (_storedStyles == null) {
			_storedStyles = new StringMap<Style>();
		}
		_storedStyles.set(id, value);
	}
	
	public function retrieveStyle(id:String):Style {
		if (_storedStyles == null) {
			return null;
		}
		return _storedStyles.get(id);
	}
	
	public function applyStyle():Void {
		if (_style != null) {
			if (_style.alpha != -1) {
				_sprite.alpha = _style.alpha;
			} else {
				_sprite.alpha = 1;
			}
			
			if (_style.filter != null) {
				_sprite.filters = [_style.filter];
			} else {
				_sprite.filters = [];
			}
		}
		
		invalidate(InvalidationFlag.DISPLAY);
	}
	
	public function buildStyles():Void {
		
	}
}