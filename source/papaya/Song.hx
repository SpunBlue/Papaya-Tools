package papaya;

typedef SwagSong =
{
	var song:String;
	/**
	 * SECTIONS, NOT NOTES TOO LAZY TO FIX.
	 */
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var girlfriend:String;

	var visualStyle:String;
	var ?curStage:String;
}

typedef SwagSection =
{
	var sectionNotes:Array<SectionNoteData>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
}

typedef SectionNoteData =
{
	var strumTime:Float;
	var noteData:Int;
	var sustainLength:Float;
	var altAnimation:Bool;
}