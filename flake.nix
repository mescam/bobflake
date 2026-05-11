{
  description = "Nix flake for IBM Bob Shell — AI-powered terminal assistant";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      version = "1.0.3";
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          bobshell = pkgs.stdenv.mkDerivation {
            pname = "bobshell";
            inherit version;

            src = pkgs.fetchurl {
              url = "https://s3.us-south.cloud-object-storage.appdomain.cloud/bob-shell/bobshell-${version}.tgz";
              hash = "sha256-nABXSY5S4wHJd4Hbi4Kr/WfDQnP42qJw27a+Y58kOk8=";
            };

            nativeBuildInputs = [ pkgs.makeWrapper ];
            buildInputs = [ pkgs.nodejs ];

            unpackPhase = ''
              mkdir -p source
              tar xzf $src -C source --strip-components=1
            '';

            dontBuild = true;

            installPhase = ''
              mkdir -p $out/lib/bobshell $out/bin
              cp -r source/* $out/lib/bobshell/

              makeWrapper ${pkgs.nodejs}/bin/node $out/bin/bob \
                --add-flags "$out/lib/bobshell/bundle/bob.js"
            '';

            meta = with pkgs.lib; {
              description = "IBM Bob Shell — AI-powered terminal assistant";
              homepage = "https://bob.ibm.com";
              license = licenses.unfree;
              platforms = supportedSystems;
              mainProgram = "bob";
            };
          };
        in
        {
          default = bobshell;
          bobshell = bobshell;
        }
      );

      checks = forAllSystems (system: {
        default = self.packages.${system}.default;
      });

      overlays.default = final: prev: {
        bobshell = self.packages.${prev.stdenv.hostPlatform.system}.default;
      };
    };
}
