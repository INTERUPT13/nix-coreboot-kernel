{
  description =
    "builds a small [wg+network+kexec] hardened kernel to embed into coreboot(bios flash) to use as an kexec based bootloader/rescue env";

  inputs = {
    linux-src = {
      url =
        "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git";
      type = "git";
      flake = false;
      #hardcoding this for now as of an issue with the nix manualConfig
      rev = "f8e739787152143aacffc181562a29c049c2d658";
    };
  };

  outputs = { self, nixpkgs, linux-src }:
    with import nixpkgs { system = "x86_64-linux"; };
    let
      readConfig = configfile:
        import (runCommand "config.nix" { } ''
          echo "{" > "$out"
          while IFS='=' read key val; do                                                                     
            [ "x''${key#CONFIG_}" != "x$key" ] || continue                                                   
            no_firstquote="''${val#\"}";                                                                     
            echo '  "'"$key"'" = "'"''${no_firstquote%\"}"'";' >> "$out"                                     
          done < "${configfile}"                                                                             
          echo "}" >> $out                                                                                   
        '').outPath;
    in {

      packages.x86_64-linux.coreboot-kernel = linuxKernel.manualConfig rec {
        inherit stdenv lib;

        version = "5.17.0";
        modDirVersion = version;

        src = linux-src;
        kernelPatches = [ ];

        configfile = ./kernel_config.conf;
        config = readConfig configfile;

        extraMeta.branch = "5.17";

      };

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.coreboot-kernel;

    };
}
