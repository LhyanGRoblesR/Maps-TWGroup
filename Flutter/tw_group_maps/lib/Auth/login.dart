// ignore_for_file: use_build_context_synchronously
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

 @override
 Widget build(BuildContext context) {
    return Scaffold(
       body: ListView(
         padding: const EdgeInsets.only(top:0),
         physics: const BouncingScrollPhysics(),
         children: [

            const Stack(
              children: [

                HeaderLogin(),
                
                LogoHeader()
              ],
            ),

            _Titulo(),

            const SizedBox(height: 40),

            _EmailAndPassword(
              emailController: emailController,
              passwordController: passwordController,
            ),

            // _ForgotPassword(),

            const SizedBox(height: 40),

            _BottonSignIn(
              emailController: emailController,
              passwordController: passwordController,
            )
         ],
       )
     );
  }
}


class _BottonSignIn extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  
  const _BottonSignIn({
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(42, 198, 82, 1),
        borderRadius: BorderRadius.circular(50)
      ),
      child: TextButton(
        child: const TextFrave(text: 'Iniciar sesión', color: Colors.white, fontSize: 18),
        onPressed: (){
          _login(context);
        },
      ),
    );
  }

  void _login(BuildContext context) async {
    final email = emailController.text;
    final password = passwordController.text;

    // Validar campos de correo electrónico y contraseña antes de enviar la solicitud
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor, completa todos los campos'),
      ));
      return;
    }

    // Aquí puedes enviar las credenciales a tu API utilizando http.post
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.28:8000/api/auth/login'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(jsonResponse['message']),
        ));
        
        if(jsonResponse['status'] == true){
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', jsonResponse['token']);
          prefs.setInt('expiration', jsonResponse['expiration']);

          Navigator.pushReplacementNamed(context, '/maps');
        }

      } else {
        // Manejar errores de la API
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al iniciar sesión: ${response.reasonPhrase}'),
        ));
      }
    } catch (e) {
      // Manejar errores de conexión
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error de conexión'),
      ));
    }
  }
}

// class _ForgotPassword extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.only(right: 25, top: 20),
//       alignment: Alignment.centerRight,
//       child: const TextFrave(text: 'Forgot Password?'),
//     );
//   }
// }

class _EmailAndPassword extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  
  const _EmailAndPassword({
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:20.0),
      child: Column(
        children: [

          TextFieldCustom(icono: Icons.mail_outline, type: TextInputType.emailAddress, texto: 'Correo electrónico', controller: emailController),
          const SizedBox(height: 20),
          TextFieldCustom(icono: Icons.visibility_off, type: TextInputType.text, pass: true, texto: 'Contraseña', controller: passwordController),
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [

          const TextFrave(text: 'Iniciar sesión', fontSize: 25, fontWeight: FontWeight.bold),

          const TextFrave(text: '/', fontSize: 25, color: Colors.grey),
          
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Futura implementación"),
            )),
            child: const TextFrave(text: 'Registrarse', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)
          )

        ],
      ),
    );
  }
}

class TextFrave extends StatelessWidget {

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final double? letterSpacing;

  const TextFrave({
    super.key, 
    required this.text,
    this.fontSize = 18,
    this.fontWeight = FontWeight.normal,
    this.color = Colors.black,
    this.maxLines = 1,
    this.overflow = TextOverflow.visible,
    this.textAlign = TextAlign.left,
    this.letterSpacing,
  });
  
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.getFont('Roboto', fontSize: fontSize, fontWeight: fontWeight, color: color, letterSpacing: letterSpacing),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}


class TextFieldCustom extends StatelessWidget {

  final IconData icono;
  final TextInputType type;
  final bool pass;
  final String texto;
  final TextEditingController controller;

  const TextFieldCustom({ super.key, required this.icono, required this.type, this.pass = false,  required this.texto, required this.controller });

 @override
 Widget build(BuildContext context){
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: pass,
      decoration: InputDecoration(
        hintText: texto,
        filled: true,
        fillColor: const Color.fromRGBO(229, 253, 235, 1),
        prefixIcon: Icon( icono, color: Colors.grey),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromRGBO(229, 253, 235, 1)),
          borderRadius: BorderRadius.circular(50)
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromRGBO(229, 253, 235, 1)),
          borderRadius: BorderRadius.circular(50),
        ),
        
      ),
    );
  }
}


class HeaderLogin extends StatelessWidget
{
  const HeaderLogin({super.key});

 @override
 Widget build(BuildContext context)
 {
    return SizedBox(
        height: 250,
        width: double.infinity,
        child: CustomPaint(
          painter: _HeaderLoginPainter(),
        ),
    );
  }
}

class _HeaderLoginPainter extends CustomPainter
{
  @override
  void paint(Canvas canvas, Size size)
  {
    final paint = Paint();
    paint.color = const Color.fromRGBO(42, 198, 82, 1);
    paint.style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * 1.0);
    path.lineTo( size.width * 0.2, size.height * 0.8);
    path.lineTo( size.width, size.height * 1.0);
    path.lineTo( size.width, 0);


    canvas.drawPath(path, paint); 
  }
  
    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
  
}


class LogoHeader extends StatelessWidget 
{
  const LogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: MediaQuery.of(context).size.width * 0.38,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: const [
            BoxShadow(blurRadius: 10, color: Colors.black26)
          ]
        ),
        child: const Align(
          alignment: Alignment.center,
          child: Text('LRR', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color.fromRGBO(42, 198, 82, 1)))
        ),
      ),
    );
  }
}