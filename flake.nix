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
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self
            , nixpkgs
            , utils
            , sway-src
            , wlroots-src
            , flake-compat
            }:
      let
        overlay = self: super: {
          sway-unwrapped = super.sway-unwrapped.overrideAttrs (a: {
            version = "${a.version}-deferred-cursor";
            src = sway-src;
            });
          wlroots_0_16 = super.wlroots_0_16.overrideAttrs (a: {
            version = "${a.version}-deferred-cursor";
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
              sway-unwrapped = pkgs.sway-unwrapped;
              wlroots_0_16   = pkgs.wlroots_0_16;
            };
        }))
        // {
          overlays.default = overlay;
        };
}
