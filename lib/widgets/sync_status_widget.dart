import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firestore_service.dart';

class SyncStatusWidget extends StatefulWidget {
  final Widget child;

  const SyncStatusWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  bool _isOnline = true;
  bool _isSyncing = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
    _listenToConnectionChanges();
  }

  void _checkConnectionStatus() async {
    try {
      final isOnline = await _firestoreService.isOnline();
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOnline = false;
        });
      }
    }
  }

  void _listenToConnectionChanges() {
    // Écouter les changements de connectivité Firestore
    FirebaseFirestore.instance.snapshotsInSync().listen(
          (_) {
        if (mounted) {
          setState(() {
            _isOnline = true;
            _isSyncing = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isOnline = false;
            _isSyncing = false;
          });
        }
      },
    );
  }

  void _forceSynchronization() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      await _firestoreService.forceSynchronization();

      if (mounted) {
        setState(() {
          _isSyncing = false;
          _isOnline = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Synchronisation réussie'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _isOnline = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur de synchronisation'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // Barre de statut en haut
        if (!_isOnline || _isSyncing)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: kToolbarHeight,
              color: _isSyncing
                  ? Colors.orange.withOpacity(0.9)
                  : Colors.red.withOpacity(0.9),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        _isSyncing
                            ? Icons.sync
                            : Icons.cloud_off,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          _isSyncing
                              ? 'Synchronisation en cours...'
                              : 'Mode hors ligne - Données non synchronisées',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      if (!_isSyncing && !_isOnline)
                        TextButton(
                          onPressed: _forceSynchronization,
                          child: const Text(
                            'Réessayer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      if (_isSyncing)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Widget pour afficher l'indicateur de synchronisation dans la AppBar
class SyncIndicator extends StatefulWidget {
  const SyncIndicator({Key? key}) : super(key: key);

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator>
    with SingleTickerProviderStateMixin {
  bool _isOnline = true;
  bool _isSyncing = false;
  late AnimationController _animationController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _checkConnectionStatus();
    _listenToConnectionChanges();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkConnectionStatus() async {
    try {
      final isOnline = await _firestoreService.isOnline();
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOnline = false;
        });
      }
    }
  }

  void _listenToConnectionChanges() {
    FirebaseFirestore.instance.snapshotsInSync().listen(
          (_) {
        if (mounted) {
          setState(() {
            _isOnline = true;
            _isSyncing = false;
          });
          _animationController.stop();
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isOnline = false;
            _isSyncing = false;
          });
          _animationController.stop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isOnline && !_isSyncing) {
      return const SizedBox.shrink();
    }

    if (_isSyncing) {
      _animationController.repeat();
    } else {
      _animationController.stop();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isSyncing)
            RotationTransition(
              turns: _animationController,
              child: Icon(
                Icons.sync,
                color: Colors.orange,
                size: 20,
              ),
            )
          else
            Icon(
              Icons.cloud_off,
              color: Colors.red,
              size: 20,
            ),

          const SizedBox(width: 4),

          Text(
            _isSyncing ? 'Sync...' : 'Hors ligne',
            style: TextStyle(
              fontSize: 12,
              color: _isSyncing ? Colors.orange : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}