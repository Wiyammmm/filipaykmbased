import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(   color:Colors.grey),
       
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color:Colors.green),
            child: SingleChildScrollView(
              child: Column(
                
                children: [
                  
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                  Text('asdsadsadsa'),
                  Text('asdsadsadsa'),
                  Text('asdsadsadsa'),
                  Text('asdsadsadsa'),
                  Text('asdsadsadsa'),
                  Text('asdsadsadsa'),
                  Text('asdsadsadsa'),
                  Text('asdsadsadsa'),

                  ],)),
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Row(children: [
                             Expanded(
                               child: ElevatedButton(onPressed: (){}, child: Text('CANCEL'),
                               
                               ),
                             ),
                             SizedBox(width: 10,),
                                Expanded(
                   child: ElevatedButton(onPressed: (){}, child: Text('SAVE'),
                             
                             ),
                                )
                           ],),
                 )
              ],),
            ),
          ),
        ),
      ],),
    );
  }
}