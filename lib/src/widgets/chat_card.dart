import 'package:flutter/material.dart';

class ChatCard extends StatefulWidget {
  const ChatCard(
      {super.key,
      required this.title,
      required this.description,
      required this.onTap,
      this.isActive = false
      });

  final String title;
  final String description;
  final Function onTap;
  final bool isActive;

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {

  @override
  Widget build(BuildContext context) {   
    return InkWell(
      onTap: (){
        widget.onTap();
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: widget.isActive?Colors.blue:Colors.transparent,
            width: 2
          )
        ),
        child: SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Opacity(
                  opacity: 0.5,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child:
                        Text(maxLines: 2, overflow: TextOverflow.ellipsis, widget.title),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 45),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          widget.description),
                    )),
                const Spacer(),
                const Positioned(
                    bottom: 0,
                    right: 0,
                    child: Icon(
                      Icons.arrow_forward,
                      size: 20,
                    )),
                    widget.isActive?const Positioned(
                      right: 0,
                      top: 0,
                      child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    )):Container()
              ],
            ))
        ),
      ),
    );
  }
}
