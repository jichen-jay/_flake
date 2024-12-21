{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, disko, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.generic = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          ./hardware-configuration.nix
          (
            { config, pkgs, ... }:
            {
              # Add function parameters here
              # Rest of your configuration...
              services.openssh = {
                enable = true;
                settings = {
                  PasswordAuthentication = false;
                  AllowTcpForwarding = true;
                  AllowStreamLocalForwarding = true;
                  PermitRootLogin = "prohibit-password";
                  X11Forwarding = false;
                };
              };
              programs.ssh.startAgent = true;

              users.users = {
                jaykchen = {
                  isNormalUser = true;
                  description = "jaykchen";
                  extraGroups = [
                    "networkmanager"
                    "wheel"
                    "podman"
                  ];
                  shell = pkgs.bash;
                  openssh.authorizedKeys.keys = [
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxv0E+eDCgj7DgjWQJD7NvvjXAj2ZMIVT0gYP5PkvIz jaykchen@nixos"
                    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCskmS2vKyKo0tt5rfgrEveKM0mfxTSoSgJ7wADFm+k78EidC0zvP2+YhC28eU6Xyn1VRimDnvN0Gf76o+A6wudb2lDDi95Nm0WH3wexlVkCVZel/eUBR8ubyHJuzX0E7hiFNjxtzXnQ9ZUvrUViirfBaOBk78Ie5nn/F62HNcG9sv3V5p5fLvbCpjDWWY0aFZePm064cSRZUgSfo0kCaeFtARKpVUGzBtFDE7FSfaL1ORK+vEsqtwkf+dfrP6Cep0b99wKXz6TK38L6AdgJHfM4a8CWNB6UoX69a81vRBMxK6hUEFW+HYQ0aOF5PdtWi4PDpe1P85mFwhH0cvHPvG0yqOAutEUSWzaGtzNTkXJnFpnN+p7fMZQ1f4NBnl4/FObQgUbPVARyqggl/VoZJ4XjBtxmiq0dDQQ1Epny2OOSzbGyn7xxjUmMnL22/LLPQfiSXMW2YMKnsQH80nERFxfcZhyYvev5edmPzdDBi6kSOlmjC/pJOXGQkfSbTsPtUN3WmGP1pWSKHV1/h2WFuBNGBubsPQtj2ThYjgfYR+8tITMMEjLeIi11+abDKjEQBD2HXwJOmV7P4DYv9TmnKqPtJURwJ0olpxAGooTDR5C16Nv/gWQ4Qa6L+WXOKztiTiv3PhU+U+DERvJiobQdTxIiFyBH0c1cOPq/fcz+n8cDw== jaykchen@gmail.com"
                  ];
                };
                root.openssh.authorizedKeys.keys = config.users.users.jaykchen.openssh.authorizedKeys.keys;
              };

              # Base configuration
              nixpkgs.config.allowUnfree = true;
              nix.settings = {
                experimental-features = [
                  "nix-command"
                  "flakes"
                ];
                max-jobs = "auto";
                trusted-users = [
                  "root"
                  "@wheel"
                  "jaykchen"
                ];
              };

              # System packages
              environment.systemPackages = with pkgs; [
                git
                tmux
                wget
                tree
                curl
                file
                btop
                podman
                podman-compose
                podman-tui
              ];

              system.stateVersion = "24.11";
            }
          )
        ];
      };
    };
}
