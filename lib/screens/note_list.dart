import 'package:flutter/material.dart';
import 'package:flutter_notes_app/screens/note_detail.dart';
import 'package:flutter_notes_app/models/note.dart';
import 'package:flutter_notes_app/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;

  int count = 0;

  bool ismark = true;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = <Note>[];
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: getNotesListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToNoteDetailsScreen(Note(3, '', ''), 'Add Note');
        },
        tooltip: "Add Note",
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNotesListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.headline6;

    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: getPriorityColor(this.noteList[position].priority),
            elevation: 2.0,
            child: ListTile(
              leading: Checkbox(
                value: ismark,
                onChanged: (bool value) {
                  print('checkbox');
                  setState(() {
                    ismark = value;
                  });
                },
              ),
              title: Text(
                this.noteList[position].title,
                style: titleStyle,
              ),
              subtitle: Text('${this.noteList[position].description}'
                  '\n${this.noteList[position].date}'),
              trailing: GestureDetector(
                child: Icon(
                  Icons.delete,
                  color: Colors.black54,
                ),
                onTap: () {
                  _delete(context, noteList[position]);
                },
              ),
              onTap: () {
                print("Listtile ontap");
                navigateToNoteDetailsScreen(
                    this.noteList[position], 'Edit Note');
              },
            ),
          );
        });
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red[400];
        break;
      case 2:
        return Colors.yellow[400];
        break;
      case 3:
        return Colors.green[400];
        break;
      default:
        return Colors.white;
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, "Note Deleted Successfully");
      updateListView();
    }
  }

  void navigateToNoteDetailsScreen(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
