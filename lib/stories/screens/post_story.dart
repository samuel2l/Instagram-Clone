// 

import 'dart:math';

import 'package:flutter/material.dart';

import 'dart:math';
import 'package:flutter/material.dart';

class StoryEditor extends StatefulWidget {
  const StoryEditor({Key? key}) : super(key: key);

  @override
  State<StoryEditor> createState() => _StoryEditorState();
}

class _StoryEditorState extends State<StoryEditor> {
  EditableItem? _activeItem;

  late Offset _initPos;
  late Offset _currentPos;
  late double _currentScale;
  late double _currentRotation;

  bool _inAction = false;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onScaleStart: (details) {
          if (_activeItem == null) return;

          _initPos = details.focalPoint;
          _currentPos = _activeItem!.position;
          _currentScale = _activeItem!.scale;
          _currentRotation = _activeItem!.rotation;
        },
        onScaleUpdate: (details) {
          if (_activeItem == null) return;

          final delta = details.focalPoint - _initPos;
          final left = (delta.dx / screen.width) + _currentPos.dx;
          final top = (delta.dy / screen.height) + _currentPos.dy;

          setState(() {
            _activeItem!.position = Offset(left, top);
            _activeItem!.rotation = details.rotation + _currentRotation;
            _activeItem!.scale =
                max(min(details.scale * _currentScale, 3), 0.2);
          });
        },
        child: Stack(
          children: [
            Container(color: Colors.black26),
            ...mockData.map(_buildItemWidget)
          ],
        ),
      ),
    );
  }

  Widget _buildItemWidget(EditableItem e) {
    final screen = MediaQuery.of(context).size;

    Widget widget;
    switch (e.type) {
      case ItemType.Text:
        widget = Text(
          e.value,
          style: const TextStyle(color: Colors.white),
        );
        break;
      case ItemType.Image:
        widget = Image.network(e.value);
        break;
    }

    return Positioned(
      top: e.position.dy * screen.height,
      left: e.position.dx * screen.width,
      child: Transform.scale(
        scale: e.scale,
        child: Transform.rotate(
          angle: e.rotation,
          child: Listener(
            onPointerDown: (details) {
              if (_inAction) return;
              _inAction = true;
              _activeItem = e;
              _initPos = details.position;
              _currentPos = e.position;
              _currentScale = e.scale;
              _currentRotation = e.rotation;
            },
            onPointerUp: (details) {
              _inAction = false;
            },
            child: widget,
          ),
        ),
      ),
    );
  }
}

enum ItemType { Image, Text }

class EditableItem {
  Offset position = const Offset(0.1, 0.1);
  double scale = 1.0;
  double rotation = 0.0;
  late ItemType type;
  late String value;
}

final mockData = [
  EditableItem()
    ..type = ItemType.Image
    ..value =
        'https://fifpro.org/media/ovzgbezo/messi_w11_2024.jpg?width=1000&height=640&rnd=133781565917900000',
  EditableItem()
    ..type = ItemType.Text
    ..value = 'Hello',
  EditableItem()
    ..type = ItemType.Text
    ..value = 'World',
];