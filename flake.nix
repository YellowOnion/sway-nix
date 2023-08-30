{
  description = "sway-deferred-cursor";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    utils.url = "github:numtide/flake-utils";
    sway-src = {
      url = "github:YellowOnion/sway/deferred-cursor-move";
      flake = false;
    };
    wlroots-src = {
      url = "github:YellowOnion/wlroots/deferred-cursor-move";
      flake = false;
    };
  };

  outputs = { self
            , nixpkgs
            , utils
            , sway-src
            , wlroots-src
            }:
      let
        overlay = self: super: {
          sway-unwrapped = super.sway-unwrapped.overrideAttrs (a: {
            src = sway-src;
            });
          wlroots_0_16 = super.wlroots_0_16.overrideAttrs (a: {
            src = wlroots-src;
          });
        };
      in
        (utils.lib.eachDefaultSystem (system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ overlay ];
            };
          in {
            packages = {
              default = pkgs.sway;
              sway = pkgs.sway;
            };
        }))
        // {
          overlays.default = overlay;
        };
}
