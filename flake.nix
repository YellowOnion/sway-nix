{
  description = "sway-deferred-cursor";
  inputs = {
    nixpkgs.url = "nixpkgs";
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
        wlrVersion = "wlroots";
        overlay = self: super: {
          sway-unwrapped = (super.sway-unwrapped.override {wlroots = self.wlroots;}).overrideAttrs (a: {
            version = "${a.version}-deferred-cursor";
            src = sway-src;
            });
          "${wlrVersion}" = super.${wlrVersion}.overrideAttrs (a: {
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
              wlroots   = pkgs.${wlrVersion};
            };
        }))
        // {
          overlays.default = overlay;
        };
}
