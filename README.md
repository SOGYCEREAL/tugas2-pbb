Pertama-tama tambahkan beberapa package kedalam `pubspec.yaml`, seperti Isar dengan cara
```
dart pub add isar:^3.1.8 isar_flutter_libs:^3.1.8 --hosted-url=https://pub.isar-community.dev
dart pub add dev:isar_generator:^3.1.8 --hosted-url=https://pub.isar-community.dev
```

Setelah itu tambahakan provider, path_provider dan build runner ke dalam `pubspec.yaml` dengan cara membuka laman pub.dev,

Hasil akhir dari dependencies yang terdapat di `pubspec.yaml` :

```
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  isar:
    hosted: https://pub.isar-community.dev
    version: 3.1.8
  isar_flutter_libs:
    hosted: https://pub.isar-community.dev
    version: 3.1.8
  provider: ^6.1.4
  path_provider: ^2.1.5
  build_runner: ^2.4.15
```

Setelah menambahkan dependencies kita membuat model data base, 
```
import 'package:isar/isar.dart';

//run : dart run build_runner build
part 'note.g.dart';

@Collection()
class Note{
  Id id = Isar.autoIncrement;
  late String text;
}
```

Kemudian kita meng-run `dart run build_runner build` setelah melakukan itu tabel data sudah terbuat.

Setelah itu kita membuat operation CRUD, 
Initialize Database
```
 static Future<void> initialize() async{
    try {
      final dir = await getApplicationDocumentsDirectory();
      isar = await Isar.open([NoteSchema], directory: dir.path);
      print("Isar opened successfully");
    } catch (e) {
      print("Isar failed to open: $e");
    }
  }

```

List Note,
```
final List<Note> currentNotes = [];
```

Create
```
  Future<void> addNote(String textFromUser) async{
    final newNote = Note()..text = textFromUser;
    // save to db
    await isar.writeTxn(() => isar.notes.put(newNote));
    fetchNotes();
  }
```

Read,
```
  Future<void> fetchNotes() async{
    List<Note> fetchedNotes = await isar.notes.where().findAll();
    currentNotes.clear();
    currentNotes.addAll(fetchedNotes);
    notifyListeners();
  }
```

Update
```
  Future<void> updateNote(int id, String newText) async{
    final existingNote = await isar.notes.get(id);
    if(existingNote != null){
      existingNote.text = newText;
      await isar.writeTxn(() => isar.notes.put(existingNote));
      await fetchNotes();
    }
  }
```

Delete
```
  Future<void> deleteNotes(int id) async {
    await isar.writeTxn(() => isar.notes.delete(id));
    await fetchNotes();
  }
```

Setelah itu sambungkan CRUD diatas ke dalam UI.
