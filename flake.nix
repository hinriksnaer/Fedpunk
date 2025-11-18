{
  description = "Fedpunk - Nix-orchestrated dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations = {
      # Main configuration
      softmax = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home.nix ];
      };

      # Terminal-only configuration
      softmax-terminal = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./home.nix
          { config._module.args.terminalOnly = true; }
        ];
      };
    };
  };
}
