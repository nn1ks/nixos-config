let
  kiyo = builtins.readFile ../data/ssh-key-kiyo.pub;
  aiko = builtins.readFile ../data/ssh-key-aiko.pub;
  mika = builtins.readFile ../data/ssh-key-mika.pub;
in {
  "lemmy-admin-password.age".publicKeys = [ mika ];
  "vaultwarden-admin-token.age".publicKeys = [ mika ];
  "searx-secret-key.age".publicKeys = [ mika ];
  "coturn-auth-secret.age".publicKeys = [ mika ];
  "maubot-unshared-secret.age".publicKeys = [ mika ];
  "mautrix-whatsapp-as-token.age".publicKeys = [ mika ];
  "mautrix-whatsapp-hs-token.age".publicKeys = [ mika ];
}
