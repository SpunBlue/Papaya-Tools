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

                        print("Finishing Up...");

                        var json = {
                            "song": papaya
                        }

                        holding = Bytes.ofString(Json.stringify(json));
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