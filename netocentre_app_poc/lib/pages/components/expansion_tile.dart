import 'package:flutter/material.dart';

class MyExpansionTile extends StatefulWidget {
  const MyExpansionTile(
    this.title, {
    this.subtitle,
    this.nbNotifications,
    super.key,
    required this.dataset,
  });

  final String title;
  final List<({String name, String? url})> dataset;
  final String? subtitle;
  final int? nbNotifications;

  @override
  State<MyExpansionTile> createState() => _MyExpansionTile();
}

class _MyExpansionTile extends State<MyExpansionTile> {
  ExpansibleController controller = ExpansibleController();
  List<Widget> widgets = [];

  @override
  void initState() {
    super.initState();

    widgets = widget.dataset.map(
      (data) {
        return Container(
          color: Colors.white,
          width: 400,
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTapDown: (aaa) {},
            onTapUp: (bbb) {},
            onTapCancel: () {},
            child: TextButton(onPressed: () => {}, child: Text(data.name)),
          ),
        );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      width: MediaQuery.of(context).size.width - 10,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFe9e9e9)),
        borderRadius: const BorderRadius.all(Radius.circular(18)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          listTileTheme: ListTileTheme.of(context).copyWith(dense: false),
        ),
        child: ExpansionTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 11.0,
                      ),
                    ),
                ],
              ),
              if (widget.nbNotifications != null)
                Container(
                  width: 38,
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Center(
                    child: Text(
                      "${widget.nbNotifications!}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
            ],
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          backgroundColor: const Color(0xFFf4f4f4),
          collapsedBackgroundColor: const Color(0xFFf4f4f4),
          children: widgets,
        ),
      ),
    );
  }
}
