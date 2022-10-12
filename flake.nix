{
  description = "Enarx kernel";

  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.nixpkgs.url = github:profianinc/nixpkgs;

  outputs = {
    flake-utils,
    nixpkgs,
    ...
  }:
    with flake-utils.lib.system;
      flake-utils.lib.eachSystem [
        aarch64-linux
        x86_64-linux
      ] (system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        expr = {
          buildLinux,
          fetchurl,
          lib,
          ...
        } @ args:
          buildLinux (args
            // rec {
              version = "6.1.0-rc7";
              modDirVersion = "6.1.0-rc7";
              extraMeta.branch = lib.versions.majorMinor version;

              src = lib.cleanSource ./.;
              kernelPatches = [];
              ignoreConfigErrors = true;

              structuredExtraConfig = with lib.kernel; {
                "64BIT" = yes;
                ACPI = yes;
                AMD_MEM_ENCRYPT = yes;
                AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT = no;
                CRYPTO = yes;
                CRYPTO_DEV_CCP = yes;
                CRYPTO_DEV_CCP_DD = module;
                CRYPTO_DEV_SP_CCP = yes;
                CRYPTO_DEV_SP_PSP = yes;
                DMADEVICES = yes;
                HIGH_RES_TIMERS = yes;
                KVM = yes;
                KVM_AMD = module;
                KVM_AMD_SEV = yes;
                MEMORY_FAILURE = yes;
                PCI = yes;
                RETPOLINE = yes;
                VIRTUALIZATION = yes;
                X86_MCE = yes;
              };
            }
            // (args.argsOverride or {}));
        linux_enarx = pkgs.callPackage expr {};
        linuxPackages_enarx = pkgs.linuxPackagesFor linux_enarx;
      in {
        packages.config = linuxPackages_enarx.kernel.configfile;
        packages.default = linuxPackages_enarx.kernel;
        packages.kernel = linuxPackages_enarx.kernel;

        nixosModules.default = {...}: {
          boot.kernelPackages = linuxPackages_enarx;
        };
      });
}
