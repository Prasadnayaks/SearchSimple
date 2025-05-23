// lib/services/chat_web_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kDebugMode and kIsWeb
import 'package:web_socket_client/web_socket_client.dart';

class ChatWebService {
  static final ChatWebService _instance = ChatWebService._internal();
  WebSocket? _socket;
  bool _isConnected = false;
  bool _isConnecting = false;
  late Uri
      _socketUri; // Make it late, will be initialized in constructor or connect

  factory ChatWebService() {
    return _instance;
  }

  ChatWebService._internal() {
    // Determine the correct URI based on the platform
    if (kIsWeb) {
      // For web, localhost generally works if server is on the same machine
      _socketUri = Uri.parse(kDebugMode
          ? "ws://localhost:8000/ws/chat"
          : "wss://your-production-server.com/ws/chat");
    } else {
      // For mobile (Android/iOS)
      if (defaultTargetPlatform == TargetPlatform.android) {
        // Android Emulator typically uses 10.0.2.2 to reach host's localhost
        _socketUri = Uri.parse(kDebugMode
            ? "ws://10.0.2.2:8000/ws/chat"
            : "wss://your-production-server.com/ws/chat");
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // iOS Simulator can usually use localhost or 127.0.0.1
        // For physical iOS devices, you'd need your computer's local network IP.
        // This setup makes it configurable for development.
        _socketUri = Uri.parse(kDebugMode
            ? "ws://localhost:8000/ws/chat"
            : "wss://your-production-server.com/ws/chat");
      } else {
        // Fallback for other platforms (e.g. desktop) - localhost might work
        _socketUri = Uri.parse(kDebugMode
            ? "ws://localhost:8000/ws/chat"
            : "wss://your-production-server.com/ws/chat");
      }
    }
    print("[ChatWebService] Target WebSocket URI: $_socketUri");
  }

  // Using .broadcast() allows multiple listeners and late subscriptions
  final StreamController<Map<String, dynamic>> _searchResultController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _contentController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  Stream<Map<String, dynamic>> get searchResultStream =>
      _searchResultController.stream;
  Stream<Map<String, dynamic>> get contentStream => _contentController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<String> get statusStream => _statusController.stream;

  Future<void> connect() async {
    if (_isConnected || _isConnecting) {
      print("[ChatWebService] Already connected or actively connecting.");
      if (_isConnected) _statusController.add("Already connected.");
      return;
    }

    print("[ChatWebService] Attempting to connect to $_socketUri...");
    _isConnecting = true;
    _statusController.add("Connecting to Simple Search...");

    try {
      _socket = WebSocket(_socketUri);

      _socket!.connection.listen((state) {
        print('[ChatWebService] Connection state: $state');
        _isConnected = state is Connected;
        _isConnecting = state is Connecting || state is Reconnecting;
        if (state is Connected) {
          _statusController.add("Connected");
          print("[ChatWebService] WebSocket successfully connected.");
        } else if (state is Reconnecting) {
          _statusController.add("Reconnecting...");
          print("[ChatWebService] WebSocket is reconnecting...");
        } else if (state is Disconnected) {
          _statusController.add("Disconnected. Please try again.");
          print(
              "[ChatWebService] WebSocket disconnected: ${state.reason}, code: ${state.code}");
          _isConnected = false;
          _isConnecting = false;
          final disconnectReason = state.reason?.isNotEmpty == true
              ? state.reason
              : "Connection lost.";
          _errorController
              .add("$disconnectReason Please check server and retry.");
        }
      }, onError: (error) {
        print('[ChatWebService] Connection stream error: $error');
        _isConnected = false;
        _isConnecting = false;
        _statusController.add("Connection Error.");
        _errorController.add("Connection error: $error. Please check server.");
      });

      _socket!.messages.listen(
        (message) {
          if (kDebugMode) {
            // print("[ChatWebService] Message received: $message");
          }
          try {
            final data = json.decode(message as String);
            final type = data['type'];

            if (type == 'search_result') {
              _searchResultController.add(data);
            } else if (type == 'content') {
              _contentController.add(data);
            } else if (type == 'error') {
              print(
                  "[ChatWebService] Error message from server: ${data['data']}");
              _errorController.add("Server error: ${data['data']}");
            } else if (type == 'finished') {
              print("[ChatWebService] Server indicated response finished.");
            } else {
              print("[ChatWebService] Unknown message type received: $type");
            }
          } catch (e) {
            print(
                "[ChatWebService] Error decoding message or unknown message structure: $e");
            _errorController.add("Error processing server message.");
          }
        },
      );
    } catch (e) {
      print(
          "[ChatWebService] Failed to establish WebSocket initial connection object: $e");
      _isConnected = false;
      _isConnecting = false;
      _statusController.add("Connection Failed.");
      _errorController.add("Failed to connect: $e");
    }
  }

  void chat(String query) {
    if (!_isConnected) {
      // Only try to connect if not already connected and not attempting.
      print(
          "[ChatWebService] Not connected. Attempting to connect before sending chat...");
      _statusController.add("Connecting to send message...");
      connect().then((_) {
        if (_isConnected && _socket != null) {
          print(
              "[ChatWebService] Sending query (after connect attempt): $query");
          _socket!.send(json.encode({'query': query}));
        } else {
          print("[ChatWebService] Still not connected. Query not sent.");
          _errorController.add("Not connected. Please tap search again.");
        }
      });
      return;
    }

    if (_isConnected && _socket != null) {
      print("[ChatWebService] Sending query: $query");
      _socket!.send(json.encode({'query': query}));
    } else {
      print(
          "[ChatWebService] Socket not ready or not connected. Query '$query' not sent.");
      _errorController.add("Cannot send message. Not connected.");
    }
  }

  void dispose() {
    print("[ChatWebService] Disposing ChatWebService and closing streams.");
    _socket?.close(1000, 'Client closing connection');
    _searchResultController.close();
    _contentController.close();
    _errorController.close();
    _statusController.close();
    _isConnected = false;
    _isConnecting = false;
  }
}
