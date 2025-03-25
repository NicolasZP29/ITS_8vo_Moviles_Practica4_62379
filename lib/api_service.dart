import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final String _apiUrl = dotenv.get('API_URL');

  // Metodos para el login y registro
static Future<void> login(String username, String password) async {
  final response = await http.post(
    Uri.parse('$_apiUrl/auth/login'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: json.encode({'username': username, 'password': password}),
  );

  if (response.statusCode == 200) {
    final body = json.decode(response.body);
    final token = body['token'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  } else {
    throw Exception('Login fallido');
  }
}


static Future<void> register(String username, String password) async {
  final response = await http.post(
    Uri.parse('$_apiUrl/auth/register'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
      },
    body: json.encode({'username': username, 'password': password}),
  );
  if (response.statusCode != 201) {
    throw Exception('Registro fallido');
  }
}

static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
  }


  // Obtener todas las tareas
  static Future<List<Map<String, dynamic>>> getTasks() async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse('$_apiUrl/tareas'), headers: headers);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al cargar las tareas');
    }
  }

  // Obtener una tarea por ID
  static Future<Map<String, dynamic>> getTaskById(int id) async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse('$_apiUrl/tareas/$id'), headers: headers);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Error al cargar la tarea');
    }
  }

  // Crear una nueva tarea
  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> task) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$_apiUrl/tareas'),
      headers: headers,
      body: json.encode(task),
    );

    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Error al crear la tarea');
    }
  }

  // Actualizar una tarea
  static Future<Map<String, dynamic>> updateTask(int id, Map<String, dynamic> task) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: headers,
      body: json.encode(task),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar la tarea');
    }
  }

  // Marcar una tarea como completada
  static Future<Map<String, dynamic>> toggleTaskCompletion(int id, bool completed) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: headers,
      body: json.encode({'completada': completed}),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar la tarea');
    }
  }

  // Eliminar una tarea
  static Future<void> deleteTask(int id) async {
    final headers = await _authHeaders();
    final response = await http.delete(Uri.parse('$_apiUrl/tareas/$id'), headers: headers);

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la tarea');
    }
  }
}