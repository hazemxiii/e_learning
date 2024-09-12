import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../global.dart';

// the path of the current directory
String path = "All";
// a global function that updates the whole page state
Function? pathChanged;
// selected files to perform delete
List<String> selectedFiles = [];

class FilesListStudentPage extends StatefulWidget {
  const FilesListStudentPage({super.key});

  @override
  State<FilesListStudentPage> createState() => _FilesListStudentPageState();
}

class _FilesListStudentPageState extends State<FilesListStudentPage> {
  // show files as row or grid
  bool isGrid = true;
  int level = 0;
  List<Reference> files = [];
  // if the page is still loading
  bool loading = true;

  @override
  void initState() {
    pathChanged = () async {
      loading = true;
      if (level == 0) {
        level = (await Dbs.firestore
                .doc("users/${Dbs.auth.currentUser!.uid}")
                .get())
            .get("level");
      }
      if (path == "All") {
        path = StudentLevels.levels[level];
      }
      ListResult? filesForAll;
      if (path == StudentLevels.levels[level]) {
        filesForAll = await Dbs.storage.child("All").listAll();
      }
      ListResult filesForGrade = await Dbs.storage.child(path).listAll();
      setState(() {
        loading = false;
        files = filesForGrade.prefixes + filesForGrade.items;
        if (filesForAll != null) {
          files = filesForAll.prefixes + files + filesForAll.items;
        }
        // get both files and folders
        selectedFiles = [];
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  color: Clrs.main,
                  onPressed: () {
                    setState(() {
                      isGrid = !isGrid;
                    });
                  },
                  icon: Icon(
                      isGrid ? Icons.grid_view : Icons.table_rows_outlined)),
            ],
          ),
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
    int hiddenCount = 0;
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
          int hiddenIndex = i;
          // the hidden file is called "system.hid"
          while (widget.files[hiddenIndex].name == "system.hid") {
            hiddenCount++;
            hiddenIndex++;
            if (hiddenIndex >= widget.files.length) {
              break;
            }
          }
          int index = i + hiddenCount;

          // if there's no more files
          if (index >= widget.files.length) {
            return Container();
          }

          FileExt fileType = FileHandler.getFileType(widget.files[index].name);
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
          Icon(
            icon,
            color: Clrs.main,
            size: 100,
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
        Icon(
          icon,
          color: Clrs.main,
          // size: 100,
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
          if (v == "download") {}
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

void openFile(BuildContext context, FileExt fileType, String filePath) async {
  if (fileType == FileExt.dir) {
    path = filePath;
    pathChanged!();
  } else if (fileType != FileExt.loading) {
    FileHandler.downloadFile(context, filePath);
  }
}

void toggleSelectFile(String filePath) {
  // if (selectedFiles.contains(filePath)) {
  //   selectedFiles.remove(filePath);
  // } else {
  //   selectedFiles.add(filePath);
  // }
}
