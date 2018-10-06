package
{
	import flash.display.Sprite;
	
	public class Test2 extends Sprite
	{
		public function Test2()
		{
			super();
			
			var s:Sprite = new Sprite();
			
			MemoryTracker.track(s, "Sprite0");
		}
	}
}