import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comanda.dart';
import '../providers/comanda_provider.dart';

class PagoDialog extends StatefulWidget {
  final Comanda comanda;

  const PagoDialog({super.key, required this.comanda});

  @override
  State<PagoDialog> createState() => _PagoDialogState();
}

class _PagoDialogState extends State<PagoDialog> {
  String _metodoPago = 'efectivo';
  final _montoRecibidoCtrl = TextEditingController();
  double _cambio = 0.0;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _montoRecibidoCtrl.addListener(_calcularCambio);
  }

  void _calcularCambio() {
    final montoRecibido = double.tryParse(_montoRecibidoCtrl.text) ?? 0.0;
    final total = widget.comanda.total;
    setState(() {
      _cambio = (montoRecibido > total) ? montoRecibido - total : 0.0;
    });
  }

  // Corregido: Se reestructura para evitar usar `context` después de una operación asíncrona.
  Future<void> _confirmarPago() async {
    if (_procesando) return;
    setState(() => _procesando = true);

    // Se capturan las instancias de Navigator y ScaffoldMessenger ANTES del 'await'.
    final provider = context.read<ComandaProvider>();
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await provider.registrarPago(widget.comanda.id!, _metodoPago);
      
      // Se usan las variables locales en lugar de acceder al 'context' de nuevo.
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('✅ Pago registrado y comanda completada.')),
      );
      navigator.pop(true); // Pop dialog and indicate success

    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('❌ Error al registrar el pago: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _procesando = false);
      }
    }
  }

  @override
  void dispose() {
    _montoRecibidoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar Pago'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total a Pagar: \$${widget.comanda.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Método de Pago:', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<String>(
              title: const Text('Efectivo'),
              value: 'efectivo',
              groupValue: _metodoPago,
              onChanged: (value) => setState(() => _metodoPago = value!),
            ),
            RadioListTile<String>(
              title: const Text('Tarjeta'),
              value: 'tarjeta',
              groupValue: _metodoPago,
              onChanged: (value) => setState(() => _metodoPago = value!),
            ),
            if (_metodoPago == 'efectivo') ...[
              const Divider(),
              TextField(
                controller: _montoRecibidoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto recibido',
                  prefixText: '\$',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Cambio: \$${_cambio.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _confirmarPago,
          child: Text(_procesando ? 'Procesando...' : 'Confirmar Pago'),
        ),
      ],
    );
  }
}
