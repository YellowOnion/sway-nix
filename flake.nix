{
  description = "sway-deferred-cursor";
  inputs = {
    nixpkgs.url = "nixpkgs/c3aa7b8938b17aebd2deecf7be0636000d62a2b9";
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
    typed-systems = {
      url = "github:YellowOnion/nix-typed-systems";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , typed-systems
    , sway-src
    , wlroots-src
    , ...
    }:
    let
      inherit (import typed-systems) id genAttrsMapBy systems';
      systems = [ systems'.x86_64-linux systems'.aarch64-linux ];

      wlrVersion = "wlroots_0_17";
      overlay = self: super: {
        sway-untouched = super.sway-unwrapped;
        sway-unwrapped = (super.sway-unwrapped.override { wlroots = self."${wlrVersion}"; }).overrideAttrs (a: {
          version = "${a.version}-deferred-cursor";
          src = sway-src;
        });
        "${wlrVersion}" = super.${wlrVersion}.overrideAttrs (a: {
          version = "${a.version}-deferred-cursor";
          src = wlroots-src;
        });
      };
    in
    {
      packages = (genAttrsMapBy id
        (system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ overlay ];
            };
          in
          {
            default = pkgs.sway;
            sway = pkgs.sway;
            sway-untouched = pkgs.sway-untouched;
            sway-unwrapped = pkgs.sway-unwrapped;
            wlroots = pkgs.${wlrVersion};
          })
        systems
        id
      );

      overlays.default = overlay;
    };
}
