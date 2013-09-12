//****************************************************************************
//Author:YouSing
//Data:2013-2-19
// App:fpPacker11.6
//****************************************************************************

package {	
	import fl.events.ComponentEvent
	import fl.controls.Button;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.display.MovieClip
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.fscommand;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;	
	[SWF(width="260",height="70",frameRate="30",backgroundColor="0xFFFFFF")]
	public class Startup extends MovieClip{
		private var loader:URLLoader=new URLLoader();
		private var fpExec:ByteArray=new ByteArray();
		private var fpSize:uint=8964976;//flashplayer11-6_sa_win_32.exe文件长度(字节)
		private var fReference:FileReference;
		private var execFilter:FileFilter = new FileFilter("Flash Player", "*.exe");
		private var swfFilter:FileFilter = new FileFilter("SWF File", "*.swf");
		private var fpBtn:Button;
		private var packBtn:Button;
		private var quitBtn:Button;
		public function Startup(){
			init();
		}
		private function init(){
			stage.showDefaultContextMenu =false;
			with(loader){
				dataFormat=URLLoaderDataFormat.BINARY;
				addEventListener(IOErrorEvent.IO_ERROR,loseFp);
				addEventListener(Event.COMPLETE,getFp);
				load(new URLRequest("fpPacker11.6.exe"));//改成你的程序名;
			}
			var temp:Array=["fpBtn","选择FP",10,"onFpBtn","packBtn","打包swf",95,"onPackBtn","quitBtn","退出",180,"onQuitBtn"];
			var fmt:TextFormat=new TextFormat(null,15,null,true);
			while(temp.length>0){
				this[temp[0]]=new Button();
				stage.addChild(this[temp[0]]);
				with(this[temp.shift()]){
					label=temp.shift();
					setStyle("textFormat",fmt);
					setSize(75,50);					
					move(temp.shift(),10);
					addEventListener(ComponentEvent.BUTTON_DOWN,this[temp.shift()]);
				}
			}
			fpBtn.alpha=0.5;packBtn.alpha=0.5;
		}
		private function onFpBtn(e:Event) {//选择FP
			fReference=new FileReference();
			with (fReference) {
				addEventListener(Event.SELECT,loadSwf);
				addEventListener(Event.COMPLETE,getFp);
				browse([execFilter]);
			}
		}
		private function onPackBtn(e:Event) {//打包swf
			fReference=new FileReference();
			with (fReference) {
				addEventListener(Event.SELECT,loadSwf);
				addEventListener(Event.COMPLETE,packFp);
				browse([swfFilter]);
			}
		}
		private function onQuitBtn(e:Event) {//退出
			fscommand("quit");
		}
		private function getFp(e:Event) {//获得FP
			e.target.removeEventListener(Event.COMPLETE,getFp);
			fpExec=e.target.data;
			fpBtn.alpha=1;packBtn.alpha=1;
			if (loader!=null) {//loader非空是初始载入
				loader.close();
				loader=null;
			} else {
				fpSize=0;
			}
		}
		private function loseFp(e:Event) {//当初始化的fp加载失败时调用
			e.target.removeEventListener(Event.COMPLETE,getFp);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR,loseFp);
			onFpBtn(e);
			loader=null;
		}
		private function loadSwf(e:Event) {//fReference加载文件
			fReference.removeEventListener(Event.SELECT,loadSwf);
			fReference.load();
		}
		private function packFp(e:Event) {//打包程序
			e.target.removeEventListener(Event.COMPLETE,packFp);
			var tempBA:ByteArray=new ByteArray();
			var tempStr:String;
			tempBA.writeBytes(fpExec,0,(fpSize!=0)?fpSize:fpExec.length);
			tempBA.position=fpExec.length;
			if (e.target is FileReference) {
				tempStr=e.target.name.replace("swf","exe");
				with (tempBA) {
					writeBytes(fReference.data,0,fReference.data.length);
					endian="littleEndian";
					writeUnsignedInt(0xFA123456);//bigEndian:writeUnsignedInt(0x563412FA);
					writeUnsignedInt(fReference.data.length);
				}
			}
			fReference.data.clear();
			fReference=new FileReference();
			fReference.save(tempBA,tempStr);
		}
	}
}
