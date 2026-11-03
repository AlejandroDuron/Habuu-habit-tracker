/// Lo que respondió el verificador sobre una foto de evidencia.
class VerificationResult {
  VerificationResult({
    required this.coincide,
    required this.confianza,
    required this.motivo,
  }) : assert(confianza >= 0 && confianza <= 1, 'La confianza va de 0 a 1'),
       assert(motivo.trim().isNotEmpty, 'El motivo no puede ir vacío');

  /// Si la foto sirve como evidencia del hábito.
  final bool coincide;

  /// Qué tan seguro está el verificador, de 0 a 1.
  final double confianza;

  /// Frase corta que explica la decisión.
  final String motivo;

  /// Lanza [FormatException] si falta un campo, viene con otro tipo o la
  /// confianza no está entre 0 y 1.
  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    final coincide = json['coincide'];
    final confianza = json['confianza'];
    final motivo = json['motivo'];

    if (coincide is! bool) {
      throw const FormatException('"coincide" falta o no es booleano');
    }
    if (confianza is! num) {
      throw const FormatException('"confianza" falta o no es un número');
    }
    // La comparación también descarta NaN, que no es mayor ni menor que nada.
    if (!(confianza >= 0 && confianza <= 1)) {
      throw FormatException('"confianza" fuera de rango: $confianza');
    }
    if (motivo is! String || motivo.trim().isEmpty) {
      throw const FormatException('"motivo" falta o está vacío');
    }

    return VerificationResult(
      coincide: coincide,
      confianza: confianza.toDouble(),
      motivo: motivo.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'coincide': coincide, 'confianza': confianza, 'motivo': motivo};
  }
}
