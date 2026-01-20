# Deploys to target using domain name
deploy:
    nix-shell -p nixos-rebuild-ng --run "nixos-rebuild-ng --target-host nixos@lithium.ovh switch --sudo --flake .#lithium --ask-sudo-password"

# Deploys to target using IP adress
deploy-local:
    nix-shell -p nixos-rebuild-ng --run "nixos-rebuild-ng --target-host nixos@192.168.1.199 switch --sudo --flake .#lithium --ask-sudo-password"

# Builds the flake
build:
    nix build .#nixosConfigurations.lithium.config.system.build.toplevel

# Builds the flake and display progress using nix-output-monitor
nom-build:
    nix-shell -p nix-output-monitor --run "nom build .#nixosConfigurations.lithium.config.system.build.toplevel"

# Nix flake check
check:
    nix flake check

# Nix flake update
update:
    nix flake update --commit-lock-file

# Nix fmt
fmt:
    nix fmt

# Dry-activate deployment
dry-deploy:
    nix-shell -p nixos-rebuild-ng --run "nixos-rebuild-ng --target-host nixos@lithium.ovh dry-activate --sudo --flake . --ask-sudo-password"

# Reboots the server
reboot:
    ssh -t nixos@lithium.ovh "sudo reboot"

# SSH into the server
ssh:
    ssh nixos@lithium.ovh
