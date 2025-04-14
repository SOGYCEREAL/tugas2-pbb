import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:isar_todo_database/models/note.dart';
import 'package:path_provider/path_provider.dart';


class NoteDatabase extends ChangeNotifier{
  static late Isar isar;

  //Init
  static Future<void> initialize() async{
    try {
      final dir = await getApplicationDocumentsDirectory();
      isar = await Isar.open([NoteSchema], directory: dir.path);
      print("Isar opened successfully");
    } catch (e) {
      print("Isar failed to open: $e");
    }
  }

  //List of note
  final List<Note> currentNotes = [];

  //Create
  Future<void> addNote(String textFromUser) async{
    final newNote = Note()..text = textFromUser;
    // save to db
    await isar.writeTxn(() => isar.notes.put(newNote));
    fetchNotes();
  }

  //Read
  Future<void> fetchNotes() async{
    List<Note> fetchedNotes = await isar.notes.where().findAll();
    currentNotes.clear();
    currentNotes.addAll(fetchedNotes);
    notifyListeners();
  }

  //Update
  Future<void> updateNote(int id, String newText) async{
    final existingNote = await isar.notes.get(id);
    if(existingNote != null){
      existingNote.text = newText;
      await isar.writeTxn(() => isar.notes.put(existingNote));
      await fetchNotes();
    }
  }

  //Delete
  Future<void> deleteNotes(int id) async {
    await isar.writeTxn(() => isar.notes.delete(id));
    await fetchNotes();
  }
}