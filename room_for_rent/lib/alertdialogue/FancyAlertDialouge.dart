// import 'package:flutter/material.dart';

// class BeautifulAlertDialog extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Dialog(
        
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         child: Container(
//           padding: EdgeInsets.only(right: 16.0),
//           height: 150,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(75),
//               bottomLeft: Radius.circular(75),
//               topRight: Radius.circular(10),
//               bottomRight: Radius.circular(10)
//             )
//           ),
//           child: Row(
//             children: <Widget>[
//               SizedBox(width: 20.0),
//               CircleAvatar(radius: 55, backgroundColor: Colors.grey.shade200, child: Image.asset('assets/img/info-icon.png', width: 60,),),
//               // SizedBox(width: 20.0),
              
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                   Text("An Error Occurred!!", style: Theme.of(context).textTheme.title,),
//                     SizedBox(height: 10.0),
                   
//                       Text(
//                         "Do you want to continue to turn off the services?"),
                   
//                     SizedBox(height: 10.0),
//                     Row(children: <Widget>[
                      
//                         // RaisedButton(
//                         //   child: Text("No"),
//                         //   color: Colors.red,
//                         //   colorBrightness: Brightness.dark,
//                         //   onPressed: (){Navigator.pop(context);},
//                         //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//                         // ),
                      
//                       SizedBox(width: 10.0),
                    
//                         RaisedButton(
//                           child: Text("ok"),
//                           color: Colors.green,
//                           colorBrightness: Brightness.dark,
//                           onPressed: (){Navigator.pop(context);},
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//                         ),
                      
//                     ],)
//                   ],
//                 ),
              
//             ],
//           ),
//         ),
        
//       )
//       );
    
//   }
// }