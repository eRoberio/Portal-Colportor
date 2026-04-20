Ficou bom já — mas dá pra deixar com cara de projeto **profissional nível portfólio forte**, daqueles que chamam atenção de recrutador 👀

Vou te entregar uma versão refinada, com:

* melhor organização visual
* linguagem mais fluida
* pequenos ajustes técnicos
* toque mais “vendável” (sem exagero)

Pode copiar direto 👇

---

```markdown
<h1 align="center">
  📚 Portal do Colportor
</h1>

<p align="center">
  <i>Sistema web completo para gestão, engajamento e acompanhamento de colportores.</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Riverpod-141114?style=for-the-badge&logo=dart&logoColor=white" />
</p>

---

## 🌐 Demo Online

🚀 Acesse o sistema em produção:  
👉 https://colportor-portal.firebaseapp.com/

---

## 📖 Sobre o Projeto

O **Portal do Colportor** é uma aplicação **Flutter Web** desenvolvida para facilitar a gestão e o acompanhamento de colportores (estudantes e efetivos).

O sistema conecta administradores e usuários em um ambiente seguro e dinâmico, com foco em:

- 📊 Monitoramento em tempo real  
- 🧑‍💼 Gestão de usuários  
- 🔥 Engajamento diário  
- 📈 Performance e rankings  

---

## ✨ Funcionalidades

### 🔐 Autenticação & Segurança
- Login com Firebase Authentication  
- Controle de acesso por função (**RBAC**)  
- Sessão persistente  

### 🔑 Sistema de Convites
- Geração de códigos únicos pelo admin  
- Controle de novos acessos ao sistema  

### 🔄 Tempo Real
- Atualizações instantâneas com **Streams + Riverpod**  
- UI sempre sincronizada com o banco  

### 📸 Perfil do Usuário
- Upload de imagem via **ImgBB API**  
- Otimização de custos (sem Firebase Storage)  

### ✉️ Recuperação de Senha Customizada
- Interceptação de links do Firebase  
- Tela interna personalizada (sem sair do app)  

### 📖 Dashboard Motivacional
- Versículos dinâmicos via API  
- Sistema de fallback offline  

---

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Função |
|----------|--------|
| Flutter Web | Frontend |
| Riverpod | Gerência de estado |
| Firebase Auth | Autenticação |
| Cloud Firestore | Banco de dados |
| Firebase Hosting | Deploy |
| ImgBB API | Upload de imagens |
| Bíblia Digital API | Conteúdo dinâmico |

---

## 🧱 Arquitetura do Projeto

O projeto segue uma arquitetura organizada em camadas:

```

lib/
├── application/         # Regras de negócio e estado
│    ├── auth/
│    └── providers/
├── infrastructure/      # Integrações externas
│    └── repositories/
├── presentation/        # Interface (UI)
│    ├── pages/
│    └── widgets/
└── main.dart

````

---

## 🚀 Como Rodar o Projeto

### 📌 Pré-requisitos

- Flutter instalado  
- Conta no Firebase  
- Firebase CLI  

```bash
npm install -g firebase-tools
````

---

### ⚙️ Instalação

```bash
# Clone o projeto
git clone https://github.com/seu-usuario/colportor-portal.git

# Entre na pasta
cd colportor-portal

# Instale dependências
flutter pub get

# Rode o projeto
flutter run -d chrome
```

---

## 📦 Deploy (Firebase Hosting)

```bash
# Build para produção
flutter build web

# Deploy
firebase deploy --only hosting
```

---

## 📌 Diferenciais do Projeto

✔ Arquitetura limpa e escalável
✔ Uso eficiente de recursos (sem Firebase Storage)
✔ Integração com APIs externas
✔ Experiência de usuário fluida
✔ Sistema pensado para crescimento real

---

## 👨‍💻 Autor

Desenvolvido por **Robério Almeida**
💼 Desenvolvedor de Software

---

## ⭐ Contribuição

Sinta-se à vontade para abrir issues ou pull requests!

---

## 📄 Licença

Este projeto está sob a licença MIT.
