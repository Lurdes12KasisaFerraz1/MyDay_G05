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
