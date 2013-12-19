package haxe.ui.toolkit.core;

import haxe.ds.StringMap;
import haxe.ui.toolkit.controls.popups.Popup;
import haxe.ui.toolkit.controls.popups.PopupContent;
import haxe.ui.toolkit.core.interfaces.IDisplayObject;
import haxe.ui.toolkit.core.interfaces.IDisplayObjectContainer;

class Controller {
	private var _view:IDisplayObjectContainer;
	private var _namedComponents:StringMap<IDisplayObjectContainer>;
	
	public var view(get, null):IDisplayObjectContainer;
	public var root(get, null):Root;
	public var popup(get, null):Popup;
	
	public function new(view:Dynamic = null, options:Dynamic = null) {
		if (Std.is(view, IDisplayObjectContainer)) {
			_view = cast(view, IDisplayObjectContainer);
		} else if (Std.is(view, Class)) {
			var cls:Class<Dynamic> = cast(view, Class<Dynamic>);
			_view = Type.createInstance(cls, []);
		} else if (view != null) {
			options = view;
		}
		
		if (_view == null) {
			_view = new Component();
		}
		
		if (options != null) {
			for (f in Reflect.fields(options)) {
				if (Reflect.getProperty(_view, "set_" + f) != null) {
					Reflect.setProperty(_view, f, Reflect.field(options, f));
				}
			}
		}
		
		refereshNamedComponents();
	}
	
	public function addChild<T>(child:Dynamic = null, options:Dynamic = null):Null<T> {
		var childObject:IDisplayObject = null;
		if (Std.is(child, IDisplayObject)) {
			childObject = cast(child, IDisplayObject);
		} else if (Std.is(child, Class)) {
			var cls:Class<Dynamic> = cast(child, Class<Dynamic>);
			childObject = Type.createInstance(cls, []);
		} else if (child != null) {
			options = child;
		}
		
		if (childObject == null) {
			childObject = new Component();
		}

		if (options != null) {
			for (f in Reflect.fields(options)) {
				if (Reflect.getProperty(childObject, "set_" + f) != null) {
					Reflect.setProperty(childObject, f, Reflect.field(options, f));
				}
			}
		}
		
		var retVal:IDisplayObject = _view.addChild(childObject);
		refereshNamedComponents();
		return cast retVal;
	}
	
	public function attachEvent(id:String, type:String, listener:Dynamic->Void):Void {
		var c:Component = getComponent(id);
		if (c != null) {
			c.addEventListener(type, listener);
		}
	}
	
	public function getComponent(id:String):Component {
		return getComponentAs(id, Component);
	}
	
	public function getComponentAs<T>(id:String, type:Class<T>):Null<T> {
		var c:IDisplayObjectContainer = _namedComponents.get(id);
		if (c == null) {
			return null;
		}

		return cast c;
	}
	
	private function refereshNamedComponents():Void {
		_namedComponents = new StringMap<IDisplayObjectContainer>();
		addNamedComponentsFrom(_view);
	}

	private function addNamedComponentsFrom(parent:IDisplayObjectContainer):Void {
		if (parent == null) {
			return;
		}
		
		if (parent != null && parent.id != null) {
			_namedComponents.set(parent.id, parent);
		}
		
		for (child in parent.children) {
			addNamedComponentsFrom(cast(child, IDisplayObjectContainer));
		}
	}
	
	private function get_view():IDisplayObjectContainer {
		return _view;
	}
	
	private function get_root():Root {
		if (_view == null) {
			return null;
		}
		return _view.root;
	}
	
	private function get_popup():Popup {
		var popup:Popup = null;
		if (Std.is(view.parent, PopupContent)) {
			popup = cast(view.parent, PopupContent).popup;
		}
		return popup;
	}
}