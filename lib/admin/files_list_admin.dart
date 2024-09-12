import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../global.dart';

// the path of the current directory
String path = "All";
// a global function that updates the whole page state
Function? pathChanged;
// the current uploading file data
double uploadProgress = 0;
String uploadName = "";
String uploadPath = "";
UploadTask? uploadTask;
// selected files to perform delete
List<String> selectedFiles = [];

class FilesListPage extends StatefulWidget {
  const FilesListPage({super.key});

  @override
  State<FilesListPage> createState() => _FilesListPageState();
}

class _FilesListPageState extends State<FilesListPage> {
  // show files as row or grid
  bool isGrid = true;
  int level = 0;
  List<Reference> files = [];
  // if the page is still loading
  bool loading = true;

  @override
  void initState() {
    pathChanged = () {
      loading = true;
      Dbs.storage.child(path).listAll().then((v) {
        setState(() {
          loading = false;
          // get both files and folders
          files = v.prefixes + v.items;
          selectedFiles = [];
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

class FilesContainer extends StatefulWidget {
  final List<Reference> files;
  final bool isGrid;
  const FilesContainer({super.key, required this.files, required this.isGrid});

  @override
  State<FilesContainer> createState() => _FilesContainerState();
}

class _FilesContainerState extends State<FilesContainer> {
  @override
  Widget build(BuildContext context) {
    // there's a hidden file in every directory, without it we can't create a new one
    // track when this file is shown and start using files at index+1 to avoid showing it
    bool hiddenFound = false;
    return GridView.builder(
        gridDelegate: widget.isGrid
            ? const SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                maxCrossAxisExtent: 200,
                mainAxisExtent: 160)
            : const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, mainAxisExtent: 50),
        itemCount: widget.files.length,
        itemBuilder: (_, i) {
          // the hidden file is called "system.hid"
          if (widget.files[i].name == "system.hid") {
            hiddenFound = true;
          }
          int index = hiddenFound ? i + 1 : i;

          // if there's no more files
          // if there's an uploading file, show upload progress, else show empty element
          if (index >= widget.files.length) {
            if (uploadProgress != 0 && uploadPath == path) {
              return FileWidget(
                filePath: "",
                fileType: FileExt.loading,
                fileName: uploadName,
                isGrid: widget.isGrid,
              );
            }
            return Container();
          }

          FileExt fileType = getFileType(widget.files[index].name);
          return InkWell(
              onTap: selectedFiles.isEmpty
                  ? () {
                      openFile(context, fileType, widget.files[index].fullPath);
                    }
                  : () {
                      setState(() {
                        toggleSelectFile(widget.files[index].fullPath);
                      });
                    },
              onLongPress: () {
                if (!selectedFiles.contains(widget.files[index].fullPath)) {
                  setState(() {
                    toggleSelectFile(widget.files[index].fullPath);
                  });
                }
              },
              child: FileWidget(
                  filePath: widget.files[index].fullPath,
                  fileType: fileType,
                  fileName: widget.files[index].name,
                  isGrid: widget.isGrid));
        });
  }
}

class FileWidget extends StatelessWidget {
  final String fileName;
  final FileExt fileType;
  final bool isGrid;
  final String filePath;
  const FileWidget(
      {super.key,
      required this.fileName,
      required this.fileType,
      required this.isGrid,
      required this.filePath});

  @override
  Widget build(BuildContext context) {
    // if the file is still uploading
    bool isLoading = fileType == FileExt.loading;
    IconData? icon;
    if (!isLoading) {
      icon = FileData.icons[fileType]!;
    }
    if (isGrid) {
      return Container(
        decoration: BoxDecoration(
            // show a different color for selected files
            color: selectedFiles.contains(filePath)
                ? Color.lerp(Colors.white, Clrs.sec, .3)
                : Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Column(children: [
          !isLoading
              ? Icon(
                  icon,
                  color: Clrs.main,
                  size: 100,
                )
              : SizedBox(
                  height: 100,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        // uploadTask!.cancel();
                      },
                      child: LinearProgressIndicator(
                        color: Clrs.main,
                        value: uploadProgress,
                      ),
                    ),
                  ),
                ),
          Text(
            overflow: TextOverflow.ellipsis,
            fileName,
            style: TextStyle(color: Clrs.sec),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FileContextMenu(
                filePath: filePath,
              ),
            ],
          )
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          color: selectedFiles.contains(filePath)
              ? Color.lerp(Colors.white, Clrs.sec, .3)
              : Colors.white,
          border: Border(bottom: BorderSide(color: Clrs.main))),
      child: Row(children: [
        !isLoading
            ? Icon(
                icon,
                color: Clrs.main,
                // size: 100,
              )
            : SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  value: uploadProgress,
                  color: Clrs.main,
                ),
              ),
        const SizedBox(
          width: 10,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width - 120,
          child: Text(
            overflow: TextOverflow.ellipsis,
            fileName,
            style: TextStyle(color: Clrs.sec),
          ),
        ),
        FileContextMenu(
          filePath: filePath,
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
              // back button
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
            onPressed: () {
              showNewFolderDialog(context);
            },
            icon: const Icon(Icons.create_new_folder)),
        IconButton(
            color: Colors.red,
            onPressed: () {
              if (selectedFiles.isNotEmpty) {
                confirmDeleteFile(context, "");
              }
            },
            icon: const Icon(Icons.delete))
      ],
    );
  }
}

class FileContextMenu extends StatelessWidget {
  final String filePath;
  const FileContextMenu({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        color: Clrs.sec,
        onSelected: (v) {
          if (v == "delete") {
            confirmDeleteFile(context, filePath);
          }
        },
        itemBuilder: (_) {
          return [
            PopupMenuItem(
                value: "delete",
                child: Text(
                  "Delete",
                  style: TextStyle(color: Clrs.main),
                )),
          ];
        });
  }
}

void confirmDeleteFile(BuildContext context, String filePath) {
  showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Clrs.sec,
          content: Text(
            "Deleted data will be lost forever",
            style: TextStyle(color: Clrs.main),
          ),
          actions: [
            MaterialButton(
                color: Clrs.main,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Clrs.sec),
                )),
            MaterialButton(
                color: Colors.red,
                onPressed: () async {
                  // empty file path means delete all selected files
                  if (filePath != "") {
                    await deleteFile(filePath);
                  } else {
                    for (int i = 0; i < selectedFiles.length; i++) {
                      await deleteFile(selectedFiles[i]);
                    }
                  }
                  pathChanged!();

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                )),
          ],
        );
      });
}

Future<void> deleteFile(String filePath) async {
  // if it's a file delete
  // if it's a directory recursively delete children
  if (filePath.contains(".")) {
    await Dbs.storage.child(filePath).delete();
    return;
  }
  ListResult subFilesRef = await Dbs.storage.child(filePath).listAll();

  List<Reference> subFiles = subFilesRef.items + subFilesRef.prefixes;

  for (int i = 0; i < subFiles.length; i++) {
    await deleteFile(subFiles[i].fullPath);
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

void openFile(BuildContext context, FileExt fileType, String filePath) async {
  if (fileType == FileExt.dir) {
    path = filePath;
    pathChanged!();
  } else if (fileType != FileExt.loading) {
    FileHandler.downloadFile(context, filePath);
  }
}

void pickFile() async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(allowMultiple: true);

  if (result != null) {
    for (int i = 0; i < result.count; i++) {
      String name = result.names[i]!;
      Uint8List? bytes;
      try {
        if (Platform.isAndroid) {
          bytes = await File(result.paths[i]!).readAsBytes();
        }
      } catch (e) {
        bytes = result.files[i].bytes!;
      }

      uploadTask = Dbs.storage.child("$path/$name").putData(bytes!);
      uploadName = name;
      uploadPath = path;
      uploadTask!.snapshotEvents.listen((TaskSnapshot snap) {
        switch (snap.state) {
          case TaskState.running:
            uploadProgress = snap.bytesTransferred / snap.totalBytes;
            pathChanged!();
            break;
          case TaskState.paused:
            break;
          case TaskState.success:
            uploadTask = null;
            uploadProgress = 0;
            uploadPath = "";
            pathChanged!();
            break;
          case TaskState.canceled:
            uploadProgress = 0;
            uploadPath = "";
            pathChanged!();
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

void showNewFolderDialog(BuildContext context) {
  TextEditingController cont = TextEditingController();
  showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Clrs.sec,
          content: TextField(
            style: TextStyle(color: Clrs.main),
            cursorColor: Clrs.main,
            controller: cont,
            decoration: CustomDecoration.giveInputDecoration(
                BorderType.under, Clrs.main),
          ),
          actions: [
            IconButton(
                color: Clrs.main,
                onPressed: () async {
                  try {
                    // must add an empty hidden file to create the directory
                    await Dbs.storage
                        .child("$path/${cont.text}/system.hid")
                        .putString("data");
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                    pathChanged!();
                  } catch (e) {
                    //
                  }
                },
                icon: Text(
                  "Save",
                  style: TextStyle(color: Clrs.main),
                ))
          ],
        );
      });
}

void toggleSelectFile(String filePath) {
  if (selectedFiles.contains(filePath)) {
    selectedFiles.remove(filePath);
  } else {
    selectedFiles.add(filePath);
  }
}
