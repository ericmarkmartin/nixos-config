{ pkgs, lib, ... }: {
    environment.systemPackages = with pkgs; [
        git curl wget
    ];

    # allow running non-Nix binaries (e.g. uv-installed Pythons)
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc.lib  # libstdc++, libgcc_s
        zlib
        openssl
        libffi
        ncurses
        bzip2
        xz
        sqlite
        readline
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "claude-code"
    ];
}
