import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class Player {

  static late AudioPlayer player;
  static late AudioPlayer player1;
  static late AudioPlayer player2;
  static late Record record;
  static String audioPath='';

//Play URL Audio
  static Future<void> playAudio(String url, bool value) async {
    if(value){
      playLocalAudio(url);
    }else{
      player = AudioPlayer();
      final duration = await player.setUrl(url);
      await player.play();
    }
  }

//Play Local Audio
  static Future<void> playLocalAudio(String url) async {
    player1 = AudioPlayer();
    final mainFolder = await createFolder('TEST');
    audioPath='$mainFolder/myFile.m4a';
    final duration = await player1.setFilePath(audioPath);
    await player1.play();
    player = AudioPlayer();
    await player.setUrl(url);
    await player.play();
  }

//Stop Local Audio
  static Future<void> stopLocalAudio() async {
    await player1.stop();
    await player.stop();
  }

//Play Asset Audio
  static Future<void> playAssetAudio(String assetUrl) async {
    player2 = AudioPlayer();
    await player2.setAsset(assetUrl);
    await player2.setLoopMode(LoopMode.all);
    await player2.play();
  }

//Stop Asset Audio
  static Future<void> stopAssetAudio() async {
    await player2.stop();
  }

//Pause Audio
  static Future<void> pauseAudio() async {
    await player.pause();
  }

//Resume Audio
  static Future<void> resumeAudio() async {
    await player.play();
  }

//Stop Audio
  static Future<void> stopAudio() async {
    stopLocalAudio();
    await player.stop();
  }


// Record Audio from Device Mic
  static Future<void> recordAudio() async {
    record= Record();
    if (await record.hasPermission()) {
      //Create Folder
      final mainFolder = await createFolder('BindassAudios');
      // Start recording
      await record.start(
        path: '$mainFolder/myFile.m4a',
        encoder: AudioEncoder.aacLc,
        bitRate: 128000, // by default
        samplingRate: 44100,
      );
    }
  }

//Stop Recording from Device Mic
  static Future<void> stopRecording() async {
    // Stop recording
    await record.stop();
  }

//Create folder according to the platform
  static Future<String> createFolder(String folderName) async {
    final dir = Directory(
        '${(Platform.isAndroid ? await getExternalStorageDirectory() //FOR ANDROID
            : await getApplicationDocumentsDirectory() //FOR IOS
        )!.path}/$folderName');
    if ((await dir.exists())) {
      return dir.path;
    } else {
      dir.create();
      return dir.path;
    }
  }

}
