// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'My Scooter';

  @override
  String get myScooters => 'Meus Scooters';

  @override
  String get noScooterFound => 'Nenhum scooter encontrado.';

  @override
  String get addScooterPrompt => 'Toque em \"+\" para adicionar um!';

  @override
  String get delete => 'EXCLUIR';

  @override
  String get cancel => 'CANCELAR';

  @override
  String get save => 'SALVAR';

  @override
  String get deleteScooterTitle => 'Excluir Scooter';

  @override
  String deleteScooterContent(String modello) {
    return 'Tem certeza que deseja excluir o scooter $modello?\nEsta ação também excluirá todos os abastecimentos.';
  }

  @override
  String get brand => 'Marca';

  @override
  String get model => 'Modelo';

  @override
  String get displacement => 'Cilindradas';

  @override
  String get mixer => 'Misturador';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get refuelings => 'ABASTECIMENTOS';

  @override
  String get noDataPresent => 'Nenhum dado presente';

  @override
  String get sharePhoto => 'Compartilhar foto';

  @override
  String get saveToGallery => 'Salvar na galeria';

  @override
  String get scooterUpdated => 'Scooter atualizado!';

  @override
  String get refuelingSaved => 'Abastecimento salvo!';

  @override
  String get addScooter => 'Adicionar Scooter';

  @override
  String get editScooter => 'Editar Scooter';

  @override
  String get licensePlate => 'Placa';

  @override
  String get year => 'Ano';

  @override
  String get tankCapacity => 'Capacidade Tanque (L)';

  @override
  String get selectImage => 'Selecionar Imagem';

  @override
  String get camera => 'Câmera';

  @override
  String get gallery => 'Galeria';

  @override
  String get removePhoto => 'Remover Foto';

  @override
  String get missingFields => 'Preencha todos os campos obrigatórios';

  @override
  String get insertBrand => 'Insira a marca';

  @override
  String get insertModel => 'Insira o modelo';

  @override
  String get refuelingDetails => 'Detalhes do Abastecimento';

  @override
  String get date => 'Data';

  @override
  String get currentKm => 'Km Atuais';

  @override
  String get gasLiters => 'Litros de Gasolina';

  @override
  String get oilLiters => 'Litros de Óleo';

  @override
  String get none => 'Nenhum';

  @override
  String get oilPercentage => 'Porcentagem de Óleo';

  @override
  String get kmTraveled => 'Km Percorridos';

  @override
  String get averageConsumption => 'Consumo Médio';

  @override
  String get averageConsumptionCalcTitle => 'Cálculo do Consumo Médio';

  @override
  String get averageConsumptionCalcDesc =>
      'O consumo médio é calculado dividindo os quilômetros percorridos desde o último abastecimento pelos litros de gasolina inseridos neste abastecimento. Supõe-se que o tanque é enchido completamente a cada vez.';

  @override
  String get addRefueling => 'Adicionar Abastecimento';

  @override
  String get editRefueling => 'Editar Abastecimento';

  @override
  String get selectDate => 'Selecionar Data';

  @override
  String get dateTime => 'Data e Hora';

  @override
  String get oilAdded => 'Óleo adicionado?';

  @override
  String get saveRefueling => 'Salvar Abastecimento';

  @override
  String get deleteRecordTitle => 'Excluir';

  @override
  String get deleteRecordContent => 'Deseja excluir este registro?';

  @override
  String get generalInfo => 'INFORMAÇÕES GERAIS';

  @override
  String get details => 'DETALHES';

  @override
  String get autoMixer => 'Misturador Automático';

  @override
  String get autoMixerDesc =>
      'Ative se o scooter misturar o óleo automaticamente';

  @override
  String get requiredField => 'Campo obrigatório';

  @override
  String get insertNumber => 'Insira um número válido';

  @override
  String get invalidLicensePlate => 'Formato de placa inválido';

  @override
  String get invalidYear => 'Ano inválido';

  @override
  String get impostazioni => 'Configurações';

  @override
  String get aspetto => 'Aparência';

  @override
  String get lingua => 'Idioma';

  @override
  String get informazioni => 'Informações';

  @override
  String get versione => 'Versão';

  @override
  String get termini_condizioni => 'Termos e Condições';

  @override
  String get fatto => 'Concluído';

  @override
  String get legale => 'Legal';

  @override
  String get maggiori_info => 'Mais Informações';

  @override
  String get leggi_sito => 'Ler no site';

  @override
  String get info_text =>
      'Para conhecer os detalhes sobre a gestão de dados e os termos de uso, visite nosso site oficial.';

  @override
  String get info_dati =>
      'O aplicativo não coleta dados pessoais em servidores externos. Tudo é salvo localmente.';

  @override
  String get sistema => 'Sistema';

  @override
  String get chiaro => 'Claro';

  @override
  String get scuro => 'Escuro';

  @override
  String get errorSharing => 'Erro ao compartilhar';

  @override
  String get errorSaving => 'Erro ao salvar';

  @override
  String get errorLoadingRefuelings => 'Erro ao carregar abastecimentos';

  @override
  String get errorDeleting => 'Erro ao excluir';

  @override
  String get recordDeleted => 'Registro excluído com sucesso';

  @override
  String get permissionDenied => 'Permissão negada';

  @override
  String get imageSaved => 'Imagem salva na galeria!';

  @override
  String get errorUpdating => 'Erro ao atualizar';

  @override
  String get scooterAdded => 'Scooter adicionado com sucesso!';

  @override
  String get scooterDeleted => 'Scooter excluído';

  @override
  String get licensePlateShort => 'Placa';

  @override
  String shareText(String scooter) {
    return 'Olha o meu $scooter!';
  }

  @override
  String get shareSubject => 'Foto do Scooter';

  @override
  String get refuelingData => 'Dados do Abastecimento';

  @override
  String get dateAndKm => 'DATA E QUILÔMETROS';

  @override
  String get fuelAndMix => 'COMBUSTÍVEL E MISTURA';

  @override
  String get calculatedLabel => '(Calculado)';

  @override
  String get errorInitialData => 'Erro ao carregar dados iniciais.';

  @override
  String mustBeGreaterThan(String km) {
    return 'Deve ser > que o anterior ($km km)';
  }

  @override
  String get cantOpenBrowser => 'Não foi possível abrir o navegador';

  @override
  String get dati => 'DADOS';

  @override
  String get backupRestoreTitle => 'Backup e Restauração';

  @override
  String get backupSection => 'EXPORTAR BACKUP';

  @override
  String get backupDesc =>
      'Salve uma cópia segura dos seus dados. Você pode salvá-la no Google Drive, iCloud, enviar por email ou manter no telefone.';

  @override
  String get createBackupBtn => 'Criar Backup';

  @override
  String get restoreSection => 'RESTAURAR BACKUP';

  @override
  String get restoreDesc =>
      'ATENÇÃO: A restauração substituirá todos os dados atuais do aplicativo. Esta operação não pode ser desfeita.';

  @override
  String get restoreBtn => 'Escolher arquivo de backup';

  @override
  String get restoreSuccess => 'Dados restaurados com sucesso!';

  @override
  String get errorBackup => 'Erro durante o backup';

  @override
  String get errorRestore => 'Erro ao restaurar ou arquivo inválido';

  @override
  String get costoLabel => 'Custo';

  @override
  String get noteLabel => 'Notas';

  @override
  String get placeholderNote => 'Adicionar notas (ex. nome do posto)';

  @override
  String get posizioneGPSLabel => 'Localização GPS';

  @override
  String get aggiungiPosizione => 'Adicionar localização';

  @override
  String get posizioneSalvata => 'Localização salva';

  @override
  String get selezionaSullaMappa => 'Selecionar no mapa';

  @override
  String get confermaPosizione => 'Confirmar localização';

  @override
  String get erroreCostoNonValido => 'Insira um custo válido';

  @override
  String get apriInGoogleMaps => 'Abrir no Google Maps';

  @override
  String get apriInWaze => 'Abrir no Waze';

  @override
  String get distributorePin => 'Posto de Combustível';

  @override
  String get registroManutenzione => 'Registro de Manutenção';

  @override
  String get nessunaManutenzione => 'Nenhuma manutenção registrada.';

  @override
  String get aggiungiIntervento => 'Adicionar Intervenção';

  @override
  String get nuovoIntervento => 'Nova Intervenção';

  @override
  String get dettagliIntervento => 'Detalhes da Intervenção';

  @override
  String get modificaIntervento => 'Editar Intervenção';

  @override
  String get titoloIntervento => 'Título (ex. Troca de vela)';

  @override
  String get dataIntervento => 'Data';

  @override
  String get categoria => 'Categoria';

  @override
  String get specificaAltro => 'Especificar categoria';

  @override
  String get costoOpzionale => 'Custo (Opcional)';

  @override
  String get noteDettagli => 'Notas / Detalhes';

  @override
  String get fotoRicevuta => 'Foto / Recibo';

  @override
  String get selezionaFoto => 'Selecionar uma imagem';

  @override
  String get rimuoviFoto => 'Remover foto';

  @override
  String get datiMancanti => 'Dados incompletos';

  @override
  String get erroreDatiMessaggio =>
      'Insira um título e quilômetros válidos para continuar.';

  @override
  String get infoPrincipali => 'Informações Principais';

  @override
  String get dettagliAggiuntivi => 'Detalhes Adicionais';

  @override
  String get notePlaceholder => 'Adicionar notas sobre a intervenção...';

  @override
  String get cat_motore => 'Motor';

  @override
  String get cat_accensione => 'Ignição / Elétrica';

  @override
  String get cat_alimentazione => 'Alimentação';

  @override
  String get cat_olio_cambio => 'Óleo da Transmissão';

  @override
  String get cat_trasmissione => 'Transmissão / Cabos';

  @override
  String get cat_freni_gomme => 'Freios / Pneus';

  @override
  String get cat_carrozzeria => 'Carenagem / Chassi';

  @override
  String get cat_altro => 'Outro';

  @override
  String get confirmTitle => 'Confirmar';

  @override
  String get confirmDeleteMaintenance =>
      'Tem certeza que deseja excluir esta intervenção?';

  @override
  String get maintenanceSaved => 'Intervenção salva!';

  @override
  String get maintenanceDeleted => 'Intervenção excluída';

  @override
  String get backupShareSubject => 'Backup MyScooter';

  @override
  String get backupShareText => 'Backup MyScooter (Dados + Fotos)';

  @override
  String get documentiScadenze => 'Documentos e Vencimentos';

  @override
  String get nessunDocumento => 'Nenhum documento salvo';

  @override
  String get scadeIl => 'Vence em:';

  @override
  String get scaduto => 'Vencido!';

  @override
  String get inScadenza => 'Vencendo em breve';

  @override
  String get senzaScadenza => 'Sem vencimento';

  @override
  String get tipoDocumento => 'Tipo de Documento';

  @override
  String get haScadenza => 'Tem data de vencimento?';

  @override
  String get dataScadenza => 'Data de Vencimento';

  @override
  String get docLibretto => 'Documento Único';

  @override
  String get docAssicurazione => 'Seguro';

  @override
  String get docRevisione => 'Inspeção';

  @override
  String get docBollo => 'Imposto Único de Circulação';

  @override
  String get docCertificato => 'Certificado Histórico';

  @override
  String get docPatente => 'Carteira de Motorista';

  @override
  String get documentSaved => 'Documento salvo!';

  @override
  String get documentDeleted => 'Documento excluído';

  @override
  String get aggiungi => 'Adicionar';

  @override
  String get esportaPDF => 'Exportar Relatório PDF';

  @override
  String get reportDi => 'Relatório de';

  @override
  String get totaleManutenzioni => 'Total Manutenções:';

  @override
  String get totaleRifornimenti => 'Total Abastecimentos:';

  @override
  String get litriConsumati => 'Litros Consumidos';

  @override
  String get costoTotaleGestione => 'Custo Total de Gestão';

  @override
  String get generatoDa => 'Gerado pelo myScooter';

  @override
  String get pag => 'Pág.';

  @override
  String get onboardingTitle1 => 'Sua Garagem Virtual';

  @override
  String get onboardingDesc1 =>
      'Gerencie todas as suas Vespas e scooters em um único app, sempre à mão.';

  @override
  String get onboardingTitle2 => 'Monitore os Abastecimentos';

  @override
  String get onboardingDesc2 =>
      'Registre os abastecimentos e acompanhe o consumo. Calcula automaticamente litros, custos e médias.';

  @override
  String get onboardingTitle3 => 'Seu Porta-documentos';

  @override
  String get onboardingDesc3 =>
      'Salve o documento, o seguro e outros. Receba notificações automáticas antes dos vencimentos!';

  @override
  String get salta => 'Pular';

  @override
  String get avanti => 'Avançar';

  @override
  String get inizia => 'Começar';

  @override
  String get profiloTitle => 'Perfil';

  @override
  String get utenteOspite => 'Usuário Convidado';

  @override
  String get datiLocali => 'Seus dados estão salvos apenas neste dispositivo.';

  @override
  String get avvisoSovrascrittura =>
      'Atenção: Acessar com uma conta Cloud existente substituirá seus dados locais.';

  @override
  String get accediGoogle => 'Entrar com Google';

  @override
  String get accediApple => 'Entrar com Apple';

  @override
  String get esci => 'Sair da conta';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get themeLabel => 'Tema do App';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get accediEmail => 'Entrar com Email';

  @override
  String get registrati => 'Cadastre-se';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get confermaPassword => 'Confirmar Senha';

  @override
  String get mailVerificaInviata =>
      'Enviamos um email de verificação. Verifique sua caixa de entrada.';

  @override
  String get mailNonVerificata =>
      'Email ainda não verificado. Clique aqui para reenviar o link.';

  @override
  String get modificaProfilo => 'Editar Perfil';

  @override
  String get nomeLabel => 'Nome';

  @override
  String get cognomeLabel => 'Sobrenome';

  @override
  String get selezionaFotoProfilo => 'Escolha uma foto de perfil';

  @override
  String get attenzioneSovrascritturaTitolo => 'Aviso sobre Dados Locais';

  @override
  String get attenzioneSovrascritturaMessaggio =>
      'Você está prestes a acessar uma conta na Nuvem. Se ela já contiver dados, os dados guardados neste dispositivo (Usuário Convidado) serão SUBSTITUÍDOS e perdidos permanentemente. Deseja prosseguir?';

  @override
  String get procedi => 'Prosseguir';

  @override
  String get annulla => 'Cancelar';

  @override
  String get loginSuccess => 'Login efetuado com sucesso';

  @override
  String get loginError => 'Falha no login ou cancelado';

  @override
  String get cloudUser => 'Usuário Cloud';

  @override
  String get logoutSuccess => 'Sessão encerrada';

  @override
  String get emailValida => 'Insira um email válido';

  @override
  String get passwordCorta => 'Mínimo 6 caracteres';

  @override
  String get passwordNonCoincidono => 'As senhas não coincidem';

  @override
  String get nonHaiAccount => 'Não tem uma conta? Cadastre-se';

  @override
  String get haiGiaAccount => 'Já tem uma conta? Entre';

  @override
  String get profiloAggiornato => 'Perfil atualizado com sucesso!';

  @override
  String get erroreSalvataggio => 'Erro ao salvar';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get eliminaAccount => 'Elimina Account';

  @override
  String get eliminaAccountConferma =>
      'Sei sicuro di voler eliminare definitivamente il tuo account? Questa operazione cancellerà tutti i tuoi dati e le tue foto dal Cloud.';

  @override
  String get eliminaDefinitivamente => 'Elimina Definitivamente';

  @override
  String get accountEliminato => 'Account eliminato con successo';

  @override
  String get erroreRiautenticazione =>
      'Per sicurezza, devi fare prima il logout, accedere di nuovo e poi eliminare l\'account.';

  @override
  String get funzioneInArrivo =>
      'Funzione in arrivo nei prossimi aggiornamenti';

  @override
  String get notificaScadenza15Titolo => 'Prazo se aproximando';

  @override
  String notificaScadenza15Corpo(String documento) {
    return 'O documento $documento expirará em 15 dias.';
  }

  @override
  String get notificaScadenza3Titolo => 'Expirando em breve!';

  @override
  String notificaScadenza3Corpo(String documento) {
    return 'Aviso: o documento $documento expirará em 3 dias.';
  }

  @override
  String get notificaScadenza0Titolo => 'Documento Expirado';

  @override
  String notificaScadenza0Corpo(String documento) {
    return 'O documento $documento expira hoje.';
  }

  @override
  String get statistiche => 'Estatísticas';

  @override
  String get imperialConverterTitle => 'Conversor Imperial';

  @override
  String get imperialConverterDesc =>
      'Insira os valores em Milhas/Galões. Eles serão convertidos automaticamente para Km e Litros para respeitar o padrão.';

  @override
  String get milesLabel => 'Milhas';

  @override
  String get gallonsLabel => 'Galões (EUA)';

  @override
  String get apply => 'Aplicar';

  @override
  String get piaggioStandardTitle => 'O Padrão Piaggio';

  @override
  String get piaggioStandardDesc =>
      'Para respeitar a mecânica e a história das scooters clássicas europeias, o aplicativo usa exclusivamente o sistema métrico (Km, Litros e Mililitros para o óleo). Se você usa o sistema imperial, use a calculadora integrada para preencher os campos!';

  @override
  String get ok => 'OK';

  @override
  String get valuta => 'Moeda';

  @override
  String get valutaEuro => 'Euro (€)';

  @override
  String get valutaDollaro => 'Dólar (\$)';

  @override
  String get valutaSterlina => 'Libra (£)';

  @override
  String get linguaSistema => 'Sistema';

  @override
  String get linguaItaliano => 'Italiano';

  @override
  String get linguaInglese => 'Inglês';

  @override
  String get linguaSpagnolo => 'Espanhol';

  @override
  String get linguaFrancese => 'Francês';

  @override
  String get linguaTedesco => 'Alemão';

  @override
  String get linguaPortoghese => 'Português';

  @override
  String get andamentoConsumi => 'Evolução do consumo';

  @override
  String get nonDisponibile => 'N/D';

  @override
  String get documentoGenerico => 'Documento';

  @override
  String get errore => 'Erro';
}
