package 
{
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	/**
	 * Testing memory tracking (with bug). Basically if you create and then delete the sprite, everything's
	 * fine. However, if you create, click on the sprite (with buttonMode = true), then delete it, it won't 
	 * be deleted as it seems Flash holds a reference to the last object clicked
	 * @author Damian Connolly
	 */
	public class GCtest extends Sprite 
	{
		
		/********************************************************************/
		
		private var m_sprite:Sprite	= null;	// the sprite that we're going to be testing
		private var m_log:TextField	= null;	// the textfield we'll use to show the trace
		private var m_id:int		= 0;	// the sprite id
		
		/********************************************************************/
		
		public function GCtest():void 
		{
			this.stage.addEventListener( KeyboardEvent.KEY_UP, this._onKeyUp );
			
			// draw a bg
			this.graphics.beginFill( 0xffffff );
			this.graphics.drawRect( 0.0, 0.0, this.stage.stageWidth, this.stage.stageHeight );
			this.graphics.endFill();
			
			// create the log
			this._createLog();
			
			// set the stage property on the memory tracker and set the debug textfield
			MemoryTracker.stage 			= this.stage;
			MemoryTracker.debugTextField	= this.m_log;
			
			// instructions
			this._log( "Press SPACE to create/destroy Sprite" );
			this._log( "Press CONTROL to run garbage collection and check for remaining references" );
			this._log( "Press BACKSPACE to clear the log" );
			this._log( "Click on the Sprite, then destroy it, then run garbage collection" );
		}
		
		/********************************************************************/
		
		// creates the log so we can see trace statements on the stage
		private function _createLog():void
		{
			var tf:TextFormat = new TextFormat( "Courier Sans Ms", 10 );
			
			// create our textfield
			this.m_log 						= new TextField;
			this.m_log.defaultTextFormat	= tf;
			this.m_log.width				= 250;
			this.m_log.height				= 300;
			this.m_log.border				= true;
			this.m_log.background			= true;
			this.m_log.x					= this.stage.stageWidth - this.m_log.width;
			this.m_log.wordWrap				= true;
			
			this.stage.addChild( this.m_log );
		}
		
		// traces a message and logs it to the TextField log
		private function _log( msg:String ):void
		{
			trace( msg );
			this.m_log.appendText( msg + "\n" );
		}
		
		// press space to create/destroy the sprite
		// press control to run the garbage collector
		private function _onKeyUp( e:KeyboardEvent ):void
		{
			// run garbage collection when we press control
			if ( e.keyCode == Keyboard.CONTROL )
			{
				MemoryTracker.gcAndCheck();
				return;
			}
			
			// clear the debug textfield
			if ( e.keyCode == Keyboard.BACKSPACE )
			{
				this.m_log.text = "";
				return;
			}
			
			// use space to create or delete the sprite
			if ( e.keyCode != Keyboard.SPACE )
				return;
			
			if ( this.m_sprite == null )
				this._createSprite();
			else
				this._deleteSprite();
		}
		
		// creates the sprite, adds it to the stage and memory tracker, and adds the mouse listener
		private function _createSprite():void
		{
			if ( this.m_sprite != null )
				return;
			
			this.m_sprite = new Sprite;
			this.m_sprite.graphics.beginFill( 0xff0000 );
			this.m_sprite.graphics.drawCircle( 50.0, 50.0, 30.0 );
			this.m_sprite.graphics.endFill();
			
			// button props
			this.m_sprite.buttonMode 	= true;
			this.m_sprite.useHandCursor	= true;
			
			this.stage.addChild( this.m_sprite ); // add it to the stage
			
			// add the mouse event
			this.m_sprite.addEventListener( MouseEvent.CLICK, this._onClick );
			
			// add it to our memory tracker
			MemoryTracker.track( this.m_sprite, "Sprite " + this.m_id++ );
			
			this._log( "Sprite created!" );
		}
		
		// removes the sprite from the stage and clears the event listener
		private function _deleteSprite():void
		{
			if ( this.m_sprite == null )
				return;
			
			// remove the mouse event
			this.m_sprite.removeEventListener( MouseEvent.CLICK, this._onClick );
			
			// remove it from the stage
			this.stage.removeChild( this.m_sprite );
			
			// null it
			this.m_sprite = null;
			
			// set the focus
			this.stage.focus = null;
			
			this._log( "Sprite deleted!" );
		}
		
		// something to do when you click the button
		private function _onClick( e:MouseEvent ):void
		{
			this._log( "Clicked!" );
		}
		
	}
	
}