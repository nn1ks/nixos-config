let
  kiyo = builtins.readFile ../data/ssh-key-kiyo.pub;
  aiko = builtins.readFile ../data/ssh-key-aiko.pub;
  yuto = builtins.readFile ../data/ssh-key-yuto.pub;
  mika = builtins.readFile ../data/ssh-key-mika.pub;
in {
  "lemmy-admin-password.age".publicKeys = [ mika ];
  "vaultwarden-admin-token.age".publicKeys = [ mika ];
  "searx-secret-key.age".publicKeys = [ mika ];
  "coturn-auth-secret.age".publicKeys = [ mika ];
  "mautrix-whatsapp-as-token.age".publicKeys = [ mika ];
  "mautrix-whatsapp-hs-token.age".publicKeys = [ mika ];
  "grafana-smtp-user.age".publicKeys = [ mika ];
  "grafana-smtp-password.age".publicKeys = [ mika ];
}
