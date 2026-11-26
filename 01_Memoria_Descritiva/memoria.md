# Memória descritiva — MyDay

## 1. Enquadramento

Os estudantes aprendem todos os dias em contextos diferentes — aulas, biblioteca, laboratório, em casa — mas raramente registam esse percurso. Quando chega a altura de estudar para um teste ou de preparar um projeto, é difícil recuperar o que se percebeu, onde e quando.

## 2. Objetivo

O **MyDay** é uma aplicação móvel que funciona como um diário de aprendizagem. Permite registar, em poucos segundos, o que se aprendeu num dia, com texto, fotografias, vídeo ou áudio, e organizar esses registos por disciplina e por projeto.

## 3. Público-alvo

Estudantes do ensino superior que querem acompanhar o seu progresso e partilhar o que aprendem com colegas.

## 4. Funcionalidades

- Criar conta e entrar na aplicação.
- Diário com os registos de cada dia e indicação dos dias seguidos de estudo.
- Novo registo com título, texto, fotografias, vídeo, áudio, local, disciplina, projeto e etiquetas.
- Visibilidade de cada registo: privado, só amigos ou público.
- Detalhe do registo com comentários, favoritos e exportação em PDF.
- Projetos que agrupam registos e grupos de estudo.
- Comunidade com publicações de colegas e o desafio da semana.
- Perfil com estatísticas, conquistas e definições de privacidade.

## 5. Decisões de design

- **Interface escura** em tons de grafite, com o azul do logótipo reservado às ações principais (regra 60-30-10), para dar destaque ao conteúdo dos registos.
- **Fotografias reais** ligadas a cada disciplina, para tornar os registos reconhecíveis à primeira vista.
- **Tipografia** Plus Jakarta Sans, com uma escala de tamanhos consistente entre ecrãs.
- **Navegação** por barra inferior com quatro áreas (Diário, Projetos, Comunidade, Perfil) e um botão para criar registos no Diário.
- **Acessibilidade**: contraste adequado do texto, alvos de toque com pelo menos 44 px e estados de erro com mensagem que explica como corrigir.

## 6. Arquitetura

A aplicação é desenvolvida em Flutter com arquitetura MVC. A descrição técnica está em `04_Documentacao_Tecnica/`.
