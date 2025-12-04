deploy:
    nix-shell -p nixos-rebuild-ng --run "nixos-rebuild-ng --target-host nixos@lithium.ovh switch --sudo --flake . --ask-sudo-password"

deploy-local:
    nix-shell -p nixos-rebuild-ng --run "nixos-rebuild-ng --target-host nixos@192.168.1.199 switch --sudo --flake . --ask-sudo-password"

build:
    nix build .#nixosConfigurations.lithium.config.system.build.toplevel

nom-build:
    nix-shell -p nix-output-monitor --run "nom build .#nixosConfigurations.lithium.config.system.build.toplevel"

check:
    nix flake check

update:
    nix flake update

fmt:
    nix fmt

dry-run:
    nix-shell -p nixos-rebuild-ng --run "nixos-rebuild-ng --target-host nixos@srv.guillaume-calderon.fr dry-activate --sudo --flake . --ask-sudo-password"

reboot:
    ssh -t nixos@lithium.ovh "sudo reboot"

ssh:
    ssh nixos@lithium.ovh
