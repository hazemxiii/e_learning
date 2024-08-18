import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../global.dart';

String path = "All";
Function? pathChanged;
double uploadProgress = 0;

class FilesListPage extends StatefulWidget {
  const FilesListPage({super.key});

  @override
  State<FilesListPage> createState() => _FilesListPageState();
}

class _FilesListPageState extends State<FilesListPage> {
  bool isGrid = true;
  int level = 0;
  List<Reference> files = [];
  bool loading = true;

  @override
  void initState() {
    pathChanged = () {
      loading = true;
      Dbs.storage.child(path).listAll().then((v) {
        setState(() {
          loading = false;
          files = v.prefixes + v.items;
        });
      }).catchError((e) {
        // print(e);
      });
    };
    pathChanged!();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    child: DropdownButton(
                        focusColor: null,
                        iconEnabledColor: Clrs.sec,
                        dropdownColor: Clrs.main,
                        value: level,
                        items: List.generate(7, (i) {
                          return DropdownMenuItem(
                              value: i,
                              child: Text(
                                StudentLevels.levels[i],
                                style: TextStyle(color: Clrs.sec),
                              ));
                        }),
                        onChanged: (v) {
                          setState(() {
                            level = v!;
                          });
                          path = StudentLevels.levels[level];
                          pathChanged!();
                        }),
                  ),
                  IconButton(
                      color: Clrs.main,
                      onPressed: () {
                        setState(() {
                          isGrid = !isGrid;
                        });
                      },
                      icon: Icon(
                          isGrid ? Icons.grid_view : Icons.table_rows_outlined))
                ],
              )),
          const FilesOptionRow(),
          Expanded(
              child: loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Clrs.main,
                      ),
                    )
                  : FilesContainer(
                      isGrid: isGrid,
                      files: files,
                    ))
        ],
      ),
    );
  }
}

class FilesContainer extends StatelessWidget {
  final List<Reference> files;
  final bool isGrid;
  const FilesContainer({super.key, required this.files, required this.isGrid});

  @override
  Widget build(BuildContext context) {
    bool hiddenFound = false;
    return GridView.builder(
        gridDelegate: isGrid
            ? const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200, mainAxisExtent: 150)
            : const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, mainAxisExtent: 50),
        itemCount: uploadProgress == 0 ? files.length : files.length + 1,
        itemBuilder: (_, i) {
          if (files[i].name == "system.hid") {
            hiddenFound = true;
          }
          int index = hiddenFound ? i + 1 : i;
          if (index > files.length + 1) {
            return FileWidget(
              fileType: FileExt.loading,
              fileName: "",
              isGrid: isGrid,
            );
          }
          if (index > files.length) {
            return Container();
          }

          FileExt fileType = getFileType(files[index].name);
          return InkWell(
              onTap: () {
                openFile(fileType, files[index].fullPath);
              },
              child: FileWidget(
                  fileType: fileType,
                  fileName: files[index].name,
                  isGrid: isGrid));
        });
  }
}

class FileWidget extends StatelessWidget {
  final String fileName;
  final FileExt fileType;
  final bool isGrid;
  const FileWidget(
      {super.key,
      required this.fileName,
      required this.fileType,
      required this.isGrid});

  @override
  Widget build(BuildContext context) {
    bool isLoading = fileType == FileExt.loading;
    IconData? icon;
    if (!isLoading) {
      icon = FileIcon.icons[fileType]!;
    }
    if (isGrid) {
      return Column(children: [
        !isLoading
            ? Icon(
                icon,
                color: Clrs.main,
                size: 100,
              )
            : Center(
                child: LinearProgressIndicator(
                  color: Clrs.main,
                  value: uploadProgress,
                ),
              ),
        Text(
          fileName,
          style: TextStyle(color: Clrs.sec),
        )
      ]);
    }
    return Container(
      decoration:
          BoxDecoration(border: Border(bottom: BorderSide(color: Clrs.main))),
      child: Row(children: [
        Icon(
          icon,
          color: Clrs.main,
          // size: 100,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          fileName,
          style: TextStyle(color: Clrs.sec),
        )
      ]),
    );
  }
}

class FilesOptionRow extends StatelessWidget {
  const FilesOptionRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            color: Clrs.main,
            onPressed: () {
              if (path.contains("/")) {
                path = path.substring(0, path.lastIndexOf("/"));
                pathChanged!();
              }
            },
            icon: const Icon(Icons.arrow_back)),
        IconButton(
            color: Clrs.main,
            onPressed: () {
              pickFile();
            },
            icon: const Icon(Icons.add)),
        IconButton(
            color: Clrs.main,
            onPressed: () async {
              try {
                await Dbs.storage
                    .child("$path/newfolder/system.hid")
                    .putString("data");
                pathChanged!();
              } catch (e) {
                //
              }
            },
            icon: const Icon(Icons.create_new_folder))
      ],
    );
  }
}

FileExt getFileType(String fileName) {
  if (!fileName.contains(".")) {
    return FileExt.dir;
  }
  String ex = fileName.substring(fileName.indexOf(".") + 1).toLowerCase();
  if (["jpg", "png", "jpeg"].contains(ex)) {
    return FileExt.img;
  }
  if (['mp4', "m4a"].contains(ex)) {
    return FileExt.vid;
  }
  return FileExt.file;
}

void openFile(FileExt fileType, String filePath) {
  if (fileType == FileExt.dir) {
    path = filePath;
  }
  pathChanged!();
}

void pickFile() async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(allowMultiple: true);

  if (result != null) {
    for (int i = 0; i < result.count; i++) {
      String name = result.names[i]!;
      Uint8List bytes = result.files[i].bytes!;
      final upload = Dbs.storage.child("$path/$name").putData(bytes);
      upload.snapshotEvents.listen((TaskSnapshot snap) {
        switch (snap.state) {
          case TaskState.running:
            uploadProgress = snap.bytesTransferred / snap.totalBytes;
            pathChanged!();
          case TaskState.paused:
            break;
          case TaskState.success:
            uploadProgress = 0;
            pathChanged!();
          case TaskState.canceled:
            break;
          case TaskState.error:
            break;
        }
      });
    }
  } else {
    // User canceled the picker
  }
}
