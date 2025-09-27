// lib/features/gastos diarios/ocr/ocr_rules.dart
// Catálogos Internos Normalizados (CIN) + Pesos de scoring

class OcrWeights {
  static const double wWhitelistPrefix = 2.0;
  static const double wUppercase = 1.2;
  static const double wLettersOverDigits = 1.0;
  static const double wLengthGood = 0.6;
  static const double wNearCifNif = 1.2;
  static const double wBlacklistTpv = -3.0;
  static const double wAccountingWords = -2.0;
  static const double wTooManyDigits = -1.0;

  static const int headerWindowLines = 15;
  static const double maxDigitRatio = 0.35;
  static const int minLen = 3;
  static const int maxLen = 32;
}

// Palabras clave cercanas al total/importe
const List<String> kTotalKeywords = [
  'total','importe','a pagar','total a pagar','pagar','saldo','base','iva','cambio'
];

// Contabilidad / no-merchant
const List<String> kAccountingWords = [
  'iva','base','impuestos','subtotal','total','importe','a pagar','propina','cambio',
  'factura','simplificada','cliente','cajero'
];

// Blacklist TPV ampliada (descarta como Establecimiento – global)
const List<String> kBlacklistTPV = [
  // Bancos / redes / pasarelas
  'bbva','santander','caixa','caixabank','bankia','sabadell','unicaja',
  'comercia','global payments','redsys','servired','ceca','euro6000','wizink',
  // Terminales
  'ingenico','verifone','pin','pin-pad','tpv','terminal',
  // Tarjetas / medios de pago
  'visa','mastercard','maestro','amex','american express','unionpay','bizum','contactless','nfc',
  // Campos técnicos
  'aut','autorizacion','autorización','autorizada','ref','referencia','aprobada','operacion','operación',
  'operador','trans','transaccion','transacción','pan','aid','cryptogram','arqc','tsi','tvr','tc','mid','tid','stan','rrn','batch','lote',
  // Identificadores genéricos
  'nº','num','no.','id','codigo','código',
  // Contacto / web / dirección
  'tel','tlf','telefono','email','@','www','http','https','calle','c/','avda','avenida','plaza','cp','cod postal','código postal'
];

/// Palabras que solo deben penalizarse en CONTEXTO TPV.
/// Ejemplos: "Badalona" (municipio) o "Jessica" (nombre de cajera) no deben bloquear
/// líneas como "Bar Jessica" / "Restaurante Badalona".
const List<String> kBlacklistContextOnly = [
  'badalona','jessica'
];

// CIN — Genéricos
const List<String> kCINGenericos = [
  'bar','cafeteria','cafetería','restaurante','bocateria','bocatería','panader','pasteler',
  'pizzeria','pizzería','kebab','taperia','tapería','taberna','tasca','meson','mesón',
  'hostal','hotel','gasolinera','estanco','expendeduria','expendeduría','farmacia',
  'super','supermercado','ultramarinos','mercado'
];

// CIN — Cadenas / marcas frecuentes (alimentación/retail)
const List<String> kCINMarcasFrecuentes = [
  'mercadona','carrefour','lidl','dia','ahorramas','alcampo','eroski','hipercor','caprabo',
  'spar','bm','aldi','bonpreu','condis','supeco','gadis','froiz','coviran','simply','supersol'
];

// CIN — Gasolineras
const List<String> kCINGasolineras = [
  'repsol','cepsa','bp','shell','galp','ballenoil','plenoil','avanti','petronor'
];

// CIN — Restauración / café (cadenas)
const List<String> kCINRestaCafe = [
  'starbucks','vips','foster','mcdonald','burger king','telepizza','domino','pans','rodilla',
  'tgb','100 montaditos','ginos','tagliatella','udon','taco bell','five guys','paulaner'
];

// CIN — Otros retail / tiendas
const List<String> kCINOtrosRetail = [
  'zara','pull&bear','pull and bear','bershka','stradivarius','massimo duti','massimo dutti','lefties',
  'primark','sprinter','decathlon','mediamarkt','fnac','ikea','leroy merlin','bricomart','bricodepot',
  'nike','adidas','foot locker','calzedonia','intimissimi'
];

String normalizeForMatch(String s) {
  var out = s.toLowerCase();
  out = out.replaceAll('á','a').replaceAll('é','e').replaceAll('í','i').replaceAll('ó','o').replaceAll('ú','u');
  out = out.replaceAll('ü','u').replaceAll('ñ','n');
  return out;
}

bool lineContainsAny(String normalizedLine, List<String> words) {
  for (final w in words) {
    if (normalizedLine.contains(w)) return true;
  }
  return false;
}

bool lineStartsWithAny(String normalizedLine, List<String> prefixes) {
  for (final p in prefixes) {
    if (normalizedLine.startsWith(p)) return true;
  }
  return false;
}
