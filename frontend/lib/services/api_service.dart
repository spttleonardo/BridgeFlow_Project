import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class ApiService {
  static String? _authToken;
  static String? _tokenType;
  static Map<String, dynamic>? currentUser;

  static const String baseUrl = 'http://localhost:8080';

  static Future<void> _cacheAuthData(Map<String, dynamic> data) async {
    final token = data['token'];
    if (token is String && token.isNotEmpty) {
      _authToken = token;
      _tokenType = (data['tipo'] as String?) ?? 'Bearer';
      // Salva token de forma segura
      await AuthService.saveToken(token);
    }
    final usuario = data['usuario'];
    if (usuario is Map<String, dynamic>) {
      currentUser = usuario;
    }
  }

  static Future<void> clearAuth() async {
    _authToken = null;
    _tokenType = null;
    currentUser = null;
    await AuthService.clearToken();
  }

  static Future<void> restoreAuthFromStorage() async {
    if (_authToken != null) return;
    final token = await AuthService.getToken();
    if (token != null && token.isNotEmpty) {
      _authToken = token;
      _tokenType ??= 'Bearer';
    }
  }

  static Map<String, String> _authHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = '${_tokenType ?? 'Bearer'} ${_authToken!}';
    }
    return headers;
  }

  static Future<Map<String, dynamic>?> verifyEmail(
      String email, String code) async {
    final url = Uri.parse('$baseUrl/auth/verify?code=$code&email=$email');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await _cacheAuthData(data);
        return data;
      } catch (_) {
        return {'error': 'Erro ao processar resposta do servidor'};
      }
    } else {
      return {
        'error':
            response.body.isNotEmpty ? response.body : 'Erro ao validar email'
      };
    }
  }

  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'senha': password,
      }),
    );
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await _cacheAuthData(data);
        return data;
      } catch (_) {
        return {'error': 'Erro ao processar resposta do servidor'};
      }
    } else if (response.statusCode == 403) {
      return {
        'error':
            response.body.isNotEmpty ? response.body : 'E-mail não verificado'
      };
    } else if (response.statusCode == 401) {
      await clearAuth();
      return {'error': 'Login não autorizado'};
    } else {
      if (response.body.isNotEmpty) {
        return {'error': response.body};
      } else {
        return {'error': 'Erro ao fazer login'};
      }
    }
  }

  static Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String cargo,
    required int secretariaId,
    String? departamento,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'cargo': cargo,
        'secretariaId': secretariaId,
        if (departamento != null && departamento.isNotEmpty)
          'departamento': departamento,
      }),
    );
    if (response.statusCode == 200) {
      return null; // Sucesso
    } else {
      // O backend retorna mensagem de erro como string simples
      if (response.body.isNotEmpty) {
        return response.body;
      } else {
        return 'Erro ao registrar';
      }
    }
  }

  static Future<String?> resendVerificationEmail(String email) async {
    final url = Uri.parse('$baseUrl/auth/resend-verification');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode == 200) {
      return null; // Sucesso
    } else {
      return response.body.isNotEmpty
          ? response.body
          : 'Erro ao reenviar o código';
    }
  }

  static Future<Map<String, dynamic>?> fetchDashboardStats() async {
    if (_authToken == null) {
      return {'error': 'Usuário não autenticado'};
    }
    final url = Uri.parse('$baseUrl/dashboard/stats');
    final response = await http.get(url, headers: _authHeaders());
    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return {'error': 'Erro ao processar resposta do servidor'};
      }
    } else if (response.statusCode == 401) {
      clearAuth();
      return {'error': 'Sessão expirada. Faça login novamente.'};
    } else {
      final message = response.body.isNotEmpty
          ? response.body
          : 'Erro ao carregar dashboard';
      return {'error': message};
    }
  }

  static Future<List<Map<String, dynamic>>> fetchSecretarias({
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl/secretarias');
    if (requiresAuth && _authToken == null) {
      throw Exception('Usuário não autenticado');
    }

    final headers = requiresAuth ? _authHeaders() : <String, String>{};

    final response = await http.get(
      url,
      headers: headers.isEmpty ? null : headers,
    );
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList(growable: false);
        }
        throw Exception('Formato de dados inesperado');
      } catch (_) {
        throw Exception('Erro ao processar resposta do servidor');
      }
    } else if (response.statusCode == 401) {
      if (requiresAuth) {
        clearAuth();
        throw Exception('Sessão expirada. Faça login novamente.');
      }
      throw Exception(response.body.isNotEmpty
          ? response.body
          : 'Não foi possível carregar secretarias');
    } else {
      throw Exception(response.body.isNotEmpty
          ? response.body
          : 'Erro ao carregar secretarias');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchUsuarios(
      {int? secretariaId}) async {
    if (_authToken == null) {
      throw Exception('Usuário não autenticado');
    }

    final uri = Uri.parse('$baseUrl/usuarios${secretariaId != null ? '?secretariaId=$secretariaId' : ''}');
    final response = await http.get(uri, headers: _authHeaders());

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList(growable: false);
        }
        throw Exception('Formato de dados inesperado');
      } catch (_) {
        throw Exception('Erro ao processar resposta do servidor');
      }
    } else if (response.statusCode == 401) {
      clearAuth();
      throw Exception('Sessão expirada. Faça login novamente.');
    } else {
      throw Exception(response.body.isNotEmpty
          ? response.body
          : 'Erro ao carregar usuários');
    }
  }

  static Future<Map<String, dynamic>?> criarComunicado({
    required String titulo,
    required String conteudo,
    required String prioridade,
    int? secretariaDestinoId,
    String? emailNotificacao,
  }) async {
    if (_authToken == null) {
      return {'error': 'Usuário não autenticado'};
    }

    final url = Uri.parse('$baseUrl/comunicados');
    final body = <String, dynamic>{
      'titulo': titulo,
      'conteudo': conteudo,
      'prioridade': prioridade,
    };

    if (secretariaDestinoId != null) {
      body['secretariaDestinoId'] = secretariaDestinoId;
    }

    if (emailNotificacao != null && emailNotificacao.isNotEmpty) {
      body['emailNotificacao'] = emailNotificacao;
    }

    final response = await http.post(
      url,
      headers: _authHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return {'error': 'Erro ao processar resposta do servidor'};
      }
    } else if (response.statusCode == 400) {
      return {
        'error': response.body.isNotEmpty ? response.body : 'Dados inválidos',
      };
    } else if (response.statusCode == 401) {
      clearAuth();
      return {'error': 'Sessão expirada. Faça login novamente.'};
    } else {
      return {
        'error': response.body.isNotEmpty
            ? response.body
            : 'Erro ao criar comunicado',
      };
    }
  }

  static Future<Map<String, dynamic>?> criarDecisao({
    required String titulo,
    required String descricao,
    required int responsavelId,
    DateTime? prazo,
    String? emailNotificacao,
  }) async {
    if (_authToken == null) {
      return {'error': 'Usuário não autenticado'};
    }

    final url = Uri.parse('$baseUrl/decisoes');
    final body = <String, dynamic>{
      'titulo': titulo,
      'descricao': descricao,
      'responsavelId': responsavelId,
    };

    if (prazo != null) {
      body['prazo'] = prazo.toIso8601String();
    }

    if (emailNotificacao != null && emailNotificacao.isNotEmpty) {
      body['emailNotificacao'] = emailNotificacao;
    }

    final response = await http.post(
      url,
      headers: _authHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return {'error': 'Erro ao processar resposta do servidor'};
      }
    } else if (response.statusCode == 400) {
      return {
        'error': response.body.isNotEmpty ? response.body : 'Dados inválidos',
      };
    } else if (response.statusCode == 401) {
      clearAuth();
      return {'error': 'Sessão expirada. Faça login novamente.'};
    } else {
      return {
        'error': response.body.isNotEmpty
            ? response.body
            : 'Erro ao criar decisão',
      };
    }
  }

  static Future<List<Map<String, dynamic>>> fetchDecisoes({String? status}) async {
    if (_authToken == null) {
      throw Exception('Usuário não autenticado');
    }

    final query = status != null ? '?status=$status' : '';
    final uri = Uri.parse('$baseUrl/decisoes$query');
    final response = await http.get(uri, headers: _authHeaders());

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList(growable: false);
        }
        throw Exception('Formato de dados inesperado');
      } catch (_) {
        throw Exception('Erro ao processar resposta do servidor');
      }
    } else if (response.statusCode == 401) {
      clearAuth();
      throw Exception('Sessão expirada. Faça login novamente.');
    } else {
      throw Exception(response.body.isNotEmpty
          ? response.body
          : 'Erro ao carregar decisões');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchComunicados({String? status, String? prioridade}) async {
    if (_authToken == null) {
      throw Exception('Usuário não autenticado');
    }

    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (prioridade != null && prioridade.isNotEmpty) {
      queryParams['prioridade'] = prioridade;
    }

    final uri = Uri.parse('$baseUrl/comunicados')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final response = await http.get(uri, headers: _authHeaders());

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList(growable: false);
        }
        throw Exception('Formato de dados inesperado');
      } catch (_) {
        throw Exception('Erro ao processar resposta do servidor');
      }
    } else if (response.statusCode == 401) {
      clearAuth();
      throw Exception('Sessão expirada. Faça login novamente.');
    } else {
      throw Exception(response.body.isNotEmpty
          ? response.body
          : 'Erro ao carregar comunicados');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchNotificacoes({bool apenasNaoLidas = false}) async {
    if (_authToken == null) {
      throw Exception('Usuário não autenticado');
    }

    final uri = Uri.parse('$baseUrl/notificacoes')
        .replace(queryParameters: apenasNaoLidas ? {'apenasNaoLidas': 'true'} : null);
    final response = await http.get(uri, headers: _authHeaders());

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList(growable: false);
        }
        throw Exception('Formato de dados inesperado');
      } catch (_) {
        throw Exception('Erro ao processar resposta do servidor');
      }
    } else if (response.statusCode == 401) {
      clearAuth();
      throw Exception('Sessão expirada. Faça login novamente.');
    } else {
      throw Exception(response.body.isNotEmpty
          ? response.body
          : 'Erro ao carregar notificações');
    }
  }

  static Future<Map<String, dynamic>?> criarComentario({
    required int decisaoId,
    required String conteudo,
  }) async {
    if (_authToken == null) {
      return {'error': 'Usuário não autenticado'};
    }

    final url = Uri.parse('$baseUrl/decisoes/$decisaoId/comentarios');
    final response = await http.post(
      url,
      headers: _authHeaders(),
      body: jsonEncode({'conteudo': conteudo}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return {'error': 'Erro ao processar resposta do servidor'};
      }
    } else if (response.statusCode == 400) {
      return {
        'error': response.body.isNotEmpty ? response.body : 'Dados inválidos',
      };
    } else if (response.statusCode == 401) {
      clearAuth();
      return {'error': 'Sessão expirada. Faça login novamente.'};
    } else if (response.statusCode == 404) {
      return {
        'error': response.body.isNotEmpty
            ? response.body
            : 'Decisão não encontrada',
      };
    } else {
      return {
        'error': response.body.isNotEmpty
            ? response.body
            : 'Erro ao adicionar comentário',
      };
    }
  }

  static Future<Map<String, dynamic>?> criarNotificacao({
    required String titulo,
    required String mensagem,
    required String tipo,
    required int usuarioDestinoId,
    String? emailNotificacao,
    int? decisaoId,
    int? comunicadoId,
  }) async {
    if (_authToken == null) {
      return {'error': 'Usuário não autenticado'};
    }

    final url = Uri.parse('$baseUrl/notificacoes');
    final body = <String, dynamic>{
      'titulo': titulo,
      'mensagem': mensagem,
      'tipo': tipo,
      'usuarioDestinoId': usuarioDestinoId,
    };

    if (emailNotificacao != null && emailNotificacao.isNotEmpty) {
      body['emailNotificacao'] = emailNotificacao;
    }

    if (decisaoId != null) {
      body['decisaoId'] = decisaoId;
    }

    if (comunicadoId != null) {
      body['comunicadoId'] = comunicadoId;
    }

    final response = await http.post(
      url,
      headers: _authHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return {'error': 'Erro ao processar resposta do servidor'};
      }
    } else if (response.statusCode == 400) {
      return {
        'error': response.body.isNotEmpty ? response.body : 'Dados inválidos',
      };
    } else if (response.statusCode == 401) {
      clearAuth();
      return {'error': 'Sessão expirada. Faça login novamente.'};
    } else if (response.statusCode == 404) {
      return {
        'error': response.body.isNotEmpty
            ? response.body
            : 'Recurso relacionado não encontrado',
      };
    } else {
      return {
        'error': response.body.isNotEmpty
            ? response.body
            : 'Erro ao criar notificação',
      };
    }
  }
}
