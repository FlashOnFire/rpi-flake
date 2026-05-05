alias b := build
alias d := deploy
alias c := check
alias u := update

domain := "lithium.ovh"

# Deploys to target
deploy *FLAGS:
    nh os switch .#lithium --target-host nixos@{{domain}} {{FLAGS}}

# Build flake
build *FLAGS:
    nh os build .#lithium --target-host nixos@{{domain}} {{FLAGS}}

# Nix flake check
check:
    nix flake check

# Nix flake update
update:
    nix flake update --commit-lock-file

# SSH into server
ssh:
    ssh nixos@{{domain}}
