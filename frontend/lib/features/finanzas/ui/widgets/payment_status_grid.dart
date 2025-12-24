import 'package:flutter/material.dart';
import '../../models/estado_cuenta.dart';

class PaymentStatusGrid extends StatelessWidget {
  final List<ItemEstadoCuenta> mensualidades;
  final Function(ItemEstadoCuenta)? onMonthSelected;

  const PaymentStatusGrid({Key? key, required this.mensualidades, this.onMonthSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Estado de Mensualidades", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: mensualidades.map((item) => _buildMonthItem(context, item)).toList(),
        ),
      ],
    );
  }

  Widget _buildMonthItem(BuildContext context, ItemEstadoCuenta item) {
    Color color;
    IconData icon;
    
    // Logic for color/icon
    if (item.estado == 'PAGADO') {
      color = Colors.green;
      icon = Icons.check;
    } else if (item.estado == 'PENDIENTE') {
      if (item.diasRetraso > 0) {
        color = Colors.red;
        icon = Icons.priority_high;
      } else {
        color = Colors.orange;
        icon = Icons.schedule;
      }
    } else {
       color = Colors.grey;
       icon = Icons.lock;
    }

    return InkWell(
      onTap: () {
        if (onMonthSelected != null) {
          onMonthSelected!(item);
        }
      },
      child: Container(
        width: 80,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 4),
            Text(
              item.concepto.replaceAll("Mensualidad ", ""), // Shorten name
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
