package;

import haxe.io.Bytes;
import haxe.Json;
import psych.Song.SwagSong;
import haxe.io.Path;
import sys.io.File;

using StringTools;

class Main {
    public static final actions:Array<Action> = [
        {
            argument: "loadFile",
            task: function(path:String) {
                obtained = File.getBytes(Path.normalize(path));
                print('File Read Sucessfully.');
            }
        },
        {
            argument: "convertTo",
            task: function (target:String) {
                switch (target.toLowerCase()) {
                    default:
                        print('$target is not a valid option');
                    case 'psych' | 'psych engine':
                        print('Converting to Psych Engine (v1.0) from Papaya Engine');

                        var bytes:Bytes = obtained;
                        var content:String = bytes.toString();


                        print('Parsing...');
                        var papaya:papaya.Song.SwagSong = Json.parse(content).song;

                        print('Parsing Completed');

                        var psych:psych.Song.SwagSong =
                        {
                            song: papaya.song,
                            bpm: papaya.bpm,
                            speed: papaya.speed,
                            notes: [],
                            events: [],
                            needsVoices: papaya.needsVoices,
                            player1: "bf",
                            player2: "dad",
                            gfVersion: "gf",
                            stage: "stage",
                            format: "psych_v1_convert",
                            offset: 0
                        };

                        print("Converting Sections");

                        var sections:Array<psych.Song.SwagSection> = [];
                        for (i in 0...papaya.notes.length) {
                            print('Converting Section $i');

                            var curSection = papaya.notes[i];
                            var psychSection:psych.Song.SwagSection = {
                                sectionNotes: [],
                                sectionBeats: curSection.lengthInSteps / 4,
                                mustHitSection: curSection.mustHitSection,
                                bpm: curSection.bpm,
                                changeBPM: curSection.changeBPM
                            };

                            for (note in curSection.sectionNotes) {
                                var psychNote:Array<Dynamic> = [];

                                psychNote[0] = note.strumTime;

                                var noteData = note.noteData;
                                if (!curSection.mustHitSection) {
                                    if (noteData > 3)
                                        noteData = noteData - 4;
                                    else
                                        noteData = noteData + 4;
                                }

                                psychNote[1] = noteData;
                                psychNote[2] = note.sustainLength;

                                psychSection.sectionNotes.push(psychNote);
                            }
                            
                            sections[i] = psychSection;
                            print('Finished Converting Section');
                        }

                        psych.notes = sections;

                        holding = Bytes.ofString(Json.stringify(psych));
                        print("Finished!");
                }
            }
        },
        {
            argument: "convertFrom",
            task: function(target:String) {
                switch(target.toLowerCase())
                {
                    default: 
                        print('$target is not a valid option');
                    case 'psych' | 'psych engine':
                        print('Converting from Psych Engine (v1.0) to Papaya Engine');

                        var bytes:Bytes = obtained;
                        var content:String = bytes.toString();

                        while(!content.endsWith('}'))
                            content = content.substr(0, content.length - 1);

                        print('Parsing...');
                        var psych:psych.Song.SwagSong = Json.parse(content);

                        print('Parsing Completed');
                        var papaya:papaya.Song.SwagSong = {
                            visualStyle: 'default',
                            song: "none",
                            bpm: 150,
                            speed: 1,
                            needsVoices: true,
                            player1: "bf",
                            player2: "dad",
                            girlfriend: "gf",
                            notes: []
                        };

                        papaya.song = psych.song;

                        papaya.bpm = psych.bpm;
                        papaya.speed = psych.speed;

                        papaya.needsVoices = psych.needsVoices;

                        print("Converting Sections");

                        for (i in 0...psych.notes.length) {
                            var psychSec = psych.notes[i];

                            print('Converting Section $i');

                            if (psychSec != null) {
                                var notes:Array<papaya.Song.SectionNoteData> = [];
                                for (psychNote in psychSec.sectionNotes) {
                                    if (psychNote != null) {
                                        var noteData:Int = Std.int(psychNote[1]);
                                        if (!psychSec.mustHitSection) {
                                            if (noteData > 3)
                                                noteData = noteData - 4;
                                            else
                                                noteData = noteData + 4;
                                        }
                                        
                                        notes.push({
                                            strumTime: psychNote[0],
                                            noteData: noteData,
                                            sustainLength: psychNote[2],
                                            altAnimation: false
                                        });
                                    }
                                }
                                
                                var bpm:Null<Float> = psychSec.bpm;
                                var changeBPM:Null<Bool> = psychSec.changeBPM;
                                if (bpm == null)
                                    bpm = 150;
                                if (changeBPM == null)
                                    changeBPM = false;

                                var sectionLength:Int = Math.floor(psychSec.sectionBeats * 4);

                                papaya.notes[i] = {
                                    bpm: bpm,
                                    changeBPM: changeBPM,
                                    lengthInSteps: sectionLength,
                                    mustHitSection: psychSec.mustHitSection,
                                    typeOfSection: 0,
                                    sectionNotes: notes
                                };

                                print('Finished Converting Section');
                            }
                        }

                        // print("Finishing Up...");

                        var json = {
                            "song": papaya
                        }

                        holding = Bytes.ofString(Json.stringify(json));

                        print("Finished!");
                }
            }
        },
        {
            argument: "output",
            task: function(output:String) {
                File.saveBytes(output, holding);
                print("File Saved to \"" + output + "\"");
            }
        }
    ];

    public static var obtained:Dynamic;
    public static var holding:Dynamic;
    public static var data:Dynamic;

    public static function main() {
        var args = Sys.args();

        // trace(args);

        var iteration:Int = 0;
        for (arg in args) {
            if (arg.startsWith('-')) {
                var action = findAction(arg);

                try {
                    action.task(args[iteration + 1]);
                }
                catch(e:Dynamic) {
                    print('Failed to perform ${action.argument}: $e');
                }
            }

            ++iteration;
        }
    }

    public static function print(v:Dynamic) {
        Sys.println(v);
    }

    public static function findAction(argument:String):Action {
        for (action in actions) {
            if (argument == '-${action.argument}') {
                return action;
                break;
            }
        }

        print('Couldn\'t find argument "$argument"');
        return null;
    }
}

typedef Action =
{
    var argument:String;
    var task:Dynamic;
}