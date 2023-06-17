# Introduction

This flake provides the [Misskey](https://github.com/misskey-dev/misskey) package and a very basic module for running Misskey instances.

# Usage

An example `flake.nix`:

```nix

{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.misskey = {
    url = "github:Ninlives/misskey.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  output = { self, nixpkgs, misskey }: {
    nixosConfigurations.instance = with nixpkgs.lib; nixosSystem {
      modules = [
        misskey.nixosModules.default
        ({ ... }: {
          services.misskey.enable = true;
          environment.etc."misskey/default.yml".text = generators.toYAML { } {
            url = "https://example.tld/";
            port = 3000;
            db = {
              host = "/run/postgresql";
              db = "misskey";
              user = "misskey";
            };
            dbReplications = false;
            redis = {
              host = "127.0.0.1";
              port = 6379;
            };
            id = "aid";
            signToActivityPubGet = true;
            allowedPrivateNetworks = [
              "127.0.0.1/32"
            ];
          };

          services.nginx.enable = true;
          services.nginx.virtualHosts."example.tld" = {
            locations."/" = { 
              proxyPass = "http://127.0.0.1:3000";
              proxyWebsockets = true;
              recommendedProxySettings = true;
              extraConfig = ''
                proxy_redirect off;
              '';
            };
          };

          services.postgresql = {
            enable = true;
            ensureDatabases = [ "misskey" ];
            ensureUsers = [{
              name = "misskey";
              ensurePermissions."DATABASE misskey" = "ALL PRIVILEGES";
            }];
            identMap = ''
              misskey misskey misskey
            '';
            authentication = ''
              local misskey misskey peer map=misskey
            '';
          };

          services.redis.servers.misskey = {
            enable = true;
            port = 6379;
          };
        })
      ];
    };
  };
}

```

# Why Not Push to nixpkgs?

There are 2 reasons:

1. The `misskey` package depends on [pnpm2nix](https://github.com/Ninlives/pnpm2nix), which should be pushed to nixpkgs in a separated PR, but it is only tested with this package, i.e. it overfits with `misskey`.
2. `pnpm2nix` uses a lot of IFD, which is not allowed in nixpkgs, but I do not like generated code.

If you want to take the responsibility, feel free to reuse code in this flake.
Ping me after you finish it, so this flake can be archived.
