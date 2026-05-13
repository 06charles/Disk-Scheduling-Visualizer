import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.CustomPaint(
          size: const PdfPoint(400, 200),
          painter: (PdfGraphics canvas, PdfPoint size) {
            canvas.drawRect(0, 0, size.x, size.y);
            canvas.setStrokeColor(PdfColors.black);
            canvas.strokePath();
            
            final font = pw.Theme.of(context).defaultTextStyle.font!.getFont(context);
            canvas.setFillColor(PdfColors.black);
            canvas.drawString(font, 10, "Test Label", 10, 10);
          },
        );
      },
    ),
  );
  print('CustomPaint with text created successfully');
}
