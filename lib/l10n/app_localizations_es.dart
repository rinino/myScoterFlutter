// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'My Scooter';

  @override
  String get myScooters => 'Mis Scooters';

  @override
  String get noScooterFound => 'No se encontró ningún scooter.';

  @override
  String get addScooterPrompt => '¡Pulsa \"+\" para añadir uno!';

  @override
  String get delete => 'ELIMINAR';

  @override
  String get cancel => 'CANCELAR';

  @override
  String get save => 'GUARDAR';

  @override
  String get deleteScooterTitle => 'Eliminar Scooter';

  @override
  String deleteScooterContent(String modello) {
    return '¿Estás seguro de que quieres eliminar el scooter $modello?\nEsta acción también borrará todos sus repostajes.';
  }

  @override
  String get brand => 'Marca';

  @override
  String get model => 'Modelo';

  @override
  String get displacement => 'Cilindrada';

  @override
  String get mixer => 'Mezclador';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get refuelings => 'REPOSTAJES';

  @override
  String get noDataPresent => 'No hay datos';

  @override
  String get sharePhoto => 'Compartir foto';

  @override
  String get saveToGallery => 'Guardar en galería';

  @override
  String get scooterUpdated => '¡Scooter actualizado!';

  @override
  String get refuelingSaved => '¡Repostaje guardado!';

  @override
  String get addScooter => 'Añadir Scooter';

  @override
  String get editScooter => 'Editar Scooter';

  @override
  String get licensePlate => 'Matrícula';

  @override
  String get year => 'Año';

  @override
  String get tankCapacity => 'Capacidad Depósito (L)';

  @override
  String get selectImage => 'Seleccionar Imagen';

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get removePhoto => 'Eliminar Foto';

  @override
  String get missingFields => 'Rellena todos los campos obligatorios';

  @override
  String get insertBrand => 'Introduce la marca';

  @override
  String get insertModel => 'Introduce el modelo';

  @override
  String get refuelingDetails => 'Detalles del Repostaje';

  @override
  String get date => 'Fecha';

  @override
  String get currentKm => 'Km Actuales';

  @override
  String get gasLiters => 'Litros Gasolina';

  @override
  String get oilLiters => 'Litros Aceite';

  @override
  String get none => 'Ninguno';

  @override
  String get oilPercentage => 'Porcentaje Aceite';

  @override
  String get kmTraveled => 'Km Recorridos';

  @override
  String get averageConsumption => 'Consumo Medio';

  @override
  String get averageConsumptionCalcTitle => 'Cálculo del Consumo Medio';

  @override
  String get averageConsumptionCalcDesc =>
      'El consumo medio se calcula dividiendo los kilómetros recorridos desde el último repostaje por los litros de gasolina introducidos. Se asume que se llena el depósito en cada repostaje.';

  @override
  String get addRefueling => 'Añadir Repostaje';

  @override
  String get editRefueling => 'Editar Repostaje';

  @override
  String get selectDate => 'Seleccionar Fecha';

  @override
  String get dateTime => 'Fecha y Hora';

  @override
  String get oilAdded => '¿Aceite añadido?';

  @override
  String get saveRefueling => 'Guardar Repostaje';

  @override
  String get deleteRecordTitle => 'Eliminar';

  @override
  String get deleteRecordContent => '¿Quieres eliminar este registro?';

  @override
  String get generalInfo => 'INFORMACIÓN GENERAL';

  @override
  String get details => 'DETALLES';

  @override
  String get autoMixer => 'Mezclador Automático';

  @override
  String get autoMixerDesc =>
      'Actívalo si el scooter gestiona el aceite de forma automática';

  @override
  String get requiredField => 'Campo obligatorio';

  @override
  String get insertNumber => 'Introduce un número válido';

  @override
  String get invalidLicensePlate => 'Formato de matrícula no válido';

  @override
  String get invalidYear => 'Año no válido';

  @override
  String get impostazioni => 'Ajustes';

  @override
  String get aspetto => 'Apariencia';

  @override
  String get lingua => 'Idioma';

  @override
  String get informazioni => 'Información';

  @override
  String get versione => 'Versión';

  @override
  String get termini_condizioni => 'Términos y Condiciones';

  @override
  String get fatto => 'Hecho';

  @override
  String get legale => 'Legal';

  @override
  String get maggiori_info => 'Más Información';

  @override
  String get leggi_sito => 'Leer en la web';

  @override
  String get info_text =>
      'Para conocer los detalles sobre la gestión de datos y términos de uso, visita nuestra web oficial.';

  @override
  String get info_dati =>
      'La app no recopila datos personales en servidores externos. Todo se guarda localmente.';

  @override
  String get sistema => 'Sistema';

  @override
  String get chiaro => 'Claro';

  @override
  String get scuro => 'Oscuro';

  @override
  String get errorSharing => 'Error al compartir';

  @override
  String get errorSaving => 'Error al guardar';

  @override
  String get errorLoadingRefuelings => 'Error al cargar los repostajes';

  @override
  String get errorDeleting => 'Error al eliminar';

  @override
  String get recordDeleted => 'Registro eliminado con éxito';

  @override
  String get permissionDenied => 'Permiso denegado';

  @override
  String get imageSaved => '¡Imagen guardada en la galería!';

  @override
  String get errorUpdating => 'Error al actualizar';

  @override
  String get scooterAdded => '¡Scooter añadido con éxito!';

  @override
  String get scooterDeleted => 'Scooter eliminado';

  @override
  String get licensePlateShort => 'Matrícula';

  @override
  String shareText(String scooter) {
    return '¡Mira mi $scooter!';
  }

  @override
  String get shareSubject => 'Foto Scooter';

  @override
  String get refuelingData => 'Datos de Repostaje';

  @override
  String get dateAndKm => 'FECHA Y KILÓMETROS';

  @override
  String get fuelAndMix => 'COMBUSTIBLE Y MEZCLA';

  @override
  String get calculatedLabel => '(Calculado)';

  @override
  String get errorInitialData => 'Error al cargar los datos iniciales.';

  @override
  String mustBeGreaterThan(String km) {
    return 'Debe ser > que el anterior ($km km)';
  }

  @override
  String get cantOpenBrowser => 'Imposible abrir el navegador';

  @override
  String get dati => 'DATOS';

  @override
  String get backupRestoreTitle => 'Copia de Seguridad y Restauración';

  @override
  String get backupSection => 'EXPORTAR COPIA DE SEGURIDAD';

  @override
  String get backupDesc =>
      'Guarda una copia segura de tus datos. Puedes guardarla en Google Drive, iCloud, enviarla por email o mantenerla en tu teléfono.';

  @override
  String get createBackupBtn => 'Crear Copia de Seguridad';

  @override
  String get restoreSection => 'RESTAURAR COPIA DE SEGURIDAD';

  @override
  String get restoreDesc =>
      'ATENCIÓN: La restauración sobrescribirá todos los datos actuales de la app. Esta operación no se puede deshacer.';

  @override
  String get restoreBtn => 'Elegir archivo de copia';

  @override
  String get restoreSuccess => '¡Datos restaurados con éxito!';

  @override
  String get errorBackup => 'Error durante la copia de seguridad';

  @override
  String get errorRestore => 'Error al restaurar o archivo no válido';

  @override
  String get costoLabel => 'Coste';

  @override
  String get noteLabel => 'Notas';

  @override
  String get placeholderNote => 'Añadir notas (ej. nombre de la estación)';

  @override
  String get posizioneGPSLabel => 'Ubicación GPS';

  @override
  String get aggiungiPosizione => 'Añadir ubicación';

  @override
  String get posizioneSalvata => 'Ubicación guardada';

  @override
  String get selezionaSullaMappa => 'Seleccionar en el mapa';

  @override
  String get confermaPosizione => 'Confirmar ubicación';

  @override
  String get erroreCostoNonValido => 'Introduce un coste válido';

  @override
  String get apriInGoogleMaps => 'Abrir en Google Maps';

  @override
  String get apriInWaze => 'Abrir en Waze';

  @override
  String get distributorePin => 'Gasolinera';

  @override
  String get registroManutenzione => 'Registro de Mantenimiento';

  @override
  String get nessunaManutenzione => 'Ningún mantenimiento registrado.';

  @override
  String get aggiungiIntervento => 'Añadir Intervención';

  @override
  String get nuovoIntervento => 'Nueva Intervención';

  @override
  String get dettagliIntervento => 'Detalles de la Intervención';

  @override
  String get modificaIntervento => 'Editar Intervención';

  @override
  String get titoloIntervento => 'Título (ej. Cambio de bujía)';

  @override
  String get dataIntervento => 'Fecha';

  @override
  String get categoria => 'Categoría';

  @override
  String get specificaAltro => 'Especificar categoría';

  @override
  String get costoOpzionale => 'Coste (Opcional)';

  @override
  String get noteDettagli => 'Notas / Detalles';

  @override
  String get fotoRicevuta => 'Foto / Recibo';

  @override
  String get selezionaFoto => 'Seleccionar una imagen';

  @override
  String get rimuoviFoto => 'Eliminar foto';

  @override
  String get datiMancanti => 'Datos faltantes';

  @override
  String get erroreDatiMessaggio =>
      'Introduce un título y kilómetros válidos para continuar.';

  @override
  String get infoPrincipali => 'Información Principal';

  @override
  String get dettagliAggiuntivi => 'Detalles Adicionales';

  @override
  String get notePlaceholder => 'Añadir notas sobre la intervención...';

  @override
  String get cat_motore => 'Motor';

  @override
  String get cat_accensione => 'Encendido / Eléctrico';

  @override
  String get cat_alimentazione => 'Alimentación';

  @override
  String get cat_olio_cambio => 'Aceite de Transmisión';

  @override
  String get cat_trasmissione => 'Transmisión / Cables';

  @override
  String get cat_freni_gomme => 'Frenos / Neumáticos';

  @override
  String get cat_carrozzeria => 'Carrocería / Chasis';

  @override
  String get cat_altro => 'Otro';

  @override
  String get confirmTitle => 'Confirmar';

  @override
  String get confirmDeleteMaintenance =>
      '¿Estás seguro de que deseas eliminar esta intervención?';

  @override
  String get maintenanceSaved => '¡Intervención guardada!';

  @override
  String get maintenanceDeleted => 'Intervención eliminada';

  @override
  String get backupShareSubject => 'Copia de Seguridad MyScooter';

  @override
  String get backupShareText => 'Copia de Seguridad MyScooter (Datos + Fotos)';

  @override
  String get documentiScadenze => 'Documentos y Vencimientos';

  @override
  String get nessunDocumento => 'Ningún documento guardado';

  @override
  String get scadeIl => 'Vence el:';

  @override
  String get scaduto => '¡Caducado!';

  @override
  String get inScadenza => 'A punto de caducar';

  @override
  String get senzaScadenza => 'Sin caducidad';

  @override
  String get tipoDocumento => 'Tipo de Documento';

  @override
  String get haScadenza => '¿Tiene fecha de caducidad?';

  @override
  String get dataScadenza => 'Fecha de Caducidad';

  @override
  String get docLibretto => 'Permiso de Circulación';

  @override
  String get docAssicurazione => 'Seguro';

  @override
  String get docRevisione => 'ITV (Revisión)';

  @override
  String get docBollo => 'Impuesto de Circulación';

  @override
  String get docCertificato => 'Certificado Histórico';

  @override
  String get docPatente => 'Carnet de Conducir';

  @override
  String get documentSaved => '¡Documento guardado!';

  @override
  String get documentDeleted => 'Documento eliminado';

  @override
  String get aggiungi => 'Añadir';

  @override
  String get esportaPDF => 'Exportar Reporte PDF';

  @override
  String get reportDi => 'Reporte de';

  @override
  String get totaleManutenzioni => 'Total Mantenimientos:';

  @override
  String get totaleRifornimenti => 'Total Repostajes:';

  @override
  String get litriConsumati => 'Litros Consumidos';

  @override
  String get costoTotaleGestione => 'Coste Total de Gestión';

  @override
  String get generatoDa => 'Generado por myScooter';

  @override
  String get pag => 'Pág.';

  @override
  String get onboardingTitle1 => 'Tu Garaje Virtual';

  @override
  String get onboardingDesc1 =>
      'Gestiona todas tus Vespas y scooters en una sola app, siempre a mano.';

  @override
  String get onboardingTitle2 => 'Rastrea tus Repostajes';

  @override
  String get onboardingDesc2 =>
      'Registra los repostajes y monitoriza los consumos. Calcula automáticamente litros, costes y medias.';

  @override
  String get onboardingTitle3 => 'Tus Documentos';

  @override
  String get onboardingDesc3 =>
      'Guarda el permiso de circulación, seguro y otros documentos. ¡Recibe notificaciones automáticas antes de los vencimientos!';

  @override
  String get salta => 'Saltar';

  @override
  String get avanti => 'Siguiente';

  @override
  String get inizia => 'Empezar';

  @override
  String get profiloTitle => 'Perfil';

  @override
  String get utenteOspite => 'Usuario Invitado';

  @override
  String get datiLocali =>
      'Tus datos están guardados solo en este dispositivo.';

  @override
  String get avvisoSovrascrittura =>
      'Atención: Si accedes con una cuenta en la Nube existente, los datos locales serán reemplazados.';

  @override
  String get accediGoogle => 'Entrar con Google';

  @override
  String get accediApple => 'Entrar con Apple';

  @override
  String get esci => 'Cerrar sesión';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get themeLabel => 'Tema de la App';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get accediEmail => 'Entrar con Email';

  @override
  String get registrati => 'Regístrate';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get confermaPassword => 'Confirmar Contraseña';

  @override
  String get mailVerificaInviata =>
      'Te hemos enviado un email de verificación. Revisa tu bandeja de entrada.';

  @override
  String get mailNonVerificata =>
      'Email no verificado. Haz clic aquí para reenviar el enlace.';

  @override
  String get modificaProfilo => 'Editar Perfil';

  @override
  String get nomeLabel => 'Nombre';

  @override
  String get cognomeLabel => 'Apellido';

  @override
  String get selezionaFotoProfilo => 'Elige una foto de perfil';

  @override
  String get attenzioneSovrascritturaTitolo =>
      'Advertencia sobre Datos Locales';

  @override
  String get attenzioneSovrascritturaMessaggio =>
      'Estás a punto de acceder a una cuenta en la Nube. Si ya contiene datos, los datos guardados en este dispositivo (Usuario Invitado) serán SOBRESCRITOS y perdidos definitivamente. ¿Deseas continuar?';

  @override
  String get procedi => 'Proceder';

  @override
  String get annulla => 'Cancelar';

  @override
  String get loginSuccess => 'Inicio de sesión exitoso';

  @override
  String get loginError => 'Acceso fallido o cancelado';

  @override
  String get cloudUser => 'Usuario Cloud';

  @override
  String get logoutSuccess => 'Sesión terminada';

  @override
  String get emailValida => 'Introduce un email válido';

  @override
  String get passwordCorta => 'Mínimo 6 caracteres';

  @override
  String get passwordNonCoincidono => 'Las contraseñas no coinciden';

  @override
  String get nonHaiAccount => '¿No tienes cuenta? Regístrate';

  @override
  String get haiGiaAccount => '¿Ya tienes cuenta? Entra';

  @override
  String get profiloAggiornato => '¡Perfil actualizado con éxito!';

  @override
  String get erroreSalvataggio => 'Error al guardar';

  @override
  String get languageLabel => 'Idioma';
}
