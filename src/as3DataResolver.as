package
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	[SWF(width="480", height="320", backgroundColor="#666666")]
	public class as3DataResolver extends Sprite
	{
		private var _unCompressBtn:SimpleButton;
		private var _compressBtn:SimpleButton;
		private var _file:FileReference;
		
		public function as3DataResolver()
		{
			if (stage) init(null);
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.stageFocusRect = false;
			
			var panel:S_Panel = new S_Panel();
			panel.x = (stage.stageWidth - panel.width) * 0.5;
			panel.y = (stage.stageHeight - panel.height) * 0.5;
			addChild(panel);
			_unCompressBtn = panel.getChildByName("unCompressBtn") as SimpleButton;
			_compressBtn = panel.getChildByName("compressBtn") as SimpleButton;
			
			_unCompressBtn.addEventListener(MouseEvent.CLICK, onClick);
			_compressBtn.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		protected function onClick(e:MouseEvent):void
		{
			// 解密
			if (e.currentTarget == _unCompressBtn)
			{
				_file = new FileReference();
				_file.browse([new FileFilter("DataFile", "*.data")]);
				_file.addEventListener(Event.SELECT, onSelectUnCompress);
			}
			
			// 加密
			if (e.currentTarget == _compressBtn)
			{
				_file = new FileReference();
				_file.browse([new FileFilter("JsonFile", "*.json")]);
				_file.addEventListener(Event.SELECT, onSelectCompress);
			}
		}
		
		// 加密文件选择
		protected function onSelectCompress(event:Event):void
		{
			_file.removeEventListener(Event.SELECT, onSelectCompress);
			_file.load();
			_file.addEventListener(Event.COMPLETE, onLoadCompress);
		}
		
		// 选择解密文件
		protected function onSelectUnCompress(e:Event):void
		{
			_file.removeEventListener(Event.SELECT, onSelectUnCompress);
			_file.load();
			_file.addEventListener(Event.COMPLETE, onLoadUnCompress);
		}	
		
		// 处理加密文件
		protected function onLoadUnCompress(e:Event):void
		{
			_file.removeEventListener(Event.COMPLETE, onLoadUnCompress);
			var fileContent:ByteArray = ByteArray(e.target.data);
			var byte:ByteArray = new ByteArray();
			fileContent.readBytes(byte);
			byte.uncompress();
			var itemDic:Dictionary = byte.readObject() as Dictionary;
			var str:String = "{";
			for (var key:String in itemDic)
			{
				str += "\"" + key + "\":" + JSON.stringify(itemDic[key]) + ",";
			}
			str = str.substr(0, str.length - 1);
			str += "}";
			var fileref:FileReference = new FileReference();
			fileref.save(str, getFileName(_file.name) + ".json");
			_file = null;
		}
		
		// 处理Json文件
		protected function onLoadCompress(e:Event):void
		{
			_file.removeEventListener(Event.COMPLETE, onLoadCompress);
			var jsonString:String = e.target.data;
			var jsonObject:Object = JSON.parse(jsonString);
			var dict:Dictionary = new Dictionary();
			for (var key:String in jsonObject)
			{
				dict[key] = jsonObject[key];
			}
			var byte:ByteArray = new ByteArray();
			byte.writeObject(dict);
			byte.compress();
			var fileref:FileReference = new FileReference();
			fileref.save(byte, getFileName(_file.name) + ".data");
			_file = null;
		}
		
		private function getFileName(pString:String):String
		{
			return pString.substring(0, pString.lastIndexOf("."));
		}
	}
}