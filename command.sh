//run from local; need to have flake.nix files on local 
nix run github:nix-community/nixos-anywhere -- \
  --phases kexec,disko,install \
  --skip-new-key \
  -i ~/.ssh/nixos_key \
  --copy-host-keys \
  --generate-hardware-config nixos-generate-config \
  ./hardware-configuration.nix \
  --flake .#x86_64-linux \
  --target-host root@43.130.1.178

//run on remote
nix run github:nix-community/nixos-anywhere --   --skip-new-key   -i ~/.ssh/nixos_key   --generate-hardware-config nixos-generate-config   ./hardware-configuration.nix   --flake .#x86_64-linux   --target-host root@43.130.1.178


// edit SSH configuration:
sudo nano /etc/ssh/sshd_config

// Ensure these lines are set:
PubkeyAuthentication yes
PasswordAuthentication yes (temporarily)
PermitRootLogin without-password

//Restart SSH service:
sudo systemctl restart sshd

//Fix Root SSH Access
sudo mkdir -p /root/.ssh
sudo chmod 700 /root/.ssh


