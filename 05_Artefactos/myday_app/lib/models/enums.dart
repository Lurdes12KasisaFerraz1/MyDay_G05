enum Subject {
  mathematics('Matemática'),
  databases('Bases de Dados'),
  mobile('Prog. Móvel'),
  chemistry('Química');

  const Subject(this.label);

  final String label;
}

enum EntryVisibility {
  private('Privado'),
  friends('Só amigos'),
  public('Público');

  const EntryVisibility(this.label);

  final String label;
}

enum AttachmentType {
  photo('Foto'),
  video('Vídeo'),
  audio('Áudio'),
  location('Local');

  const AttachmentType(this.label);

  final String label;
}

enum CommunityFeed {
  following('A seguir'),
  discover('Descobrir'),
  groups('Grupos');

  const CommunityFeed(this.label);

  final String label;
}

enum VerificationChannel {
  email('email'),
  sms('SMS');

  const VerificationChannel(this.label);

  final String label;
}

enum VerificationPurpose { signup, login, passwordReset }

enum ImageCategory {
  mathematics('Matemática'),
  databases('Bases de Dados'),
  programming('Programação'),
  chemistry('Química'),
  study('Estudo');

  const ImageCategory(this.label);

  final String label;
}
