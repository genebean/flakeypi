{ hostname, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "24.05";

  boot = {
    kernelParams = [
      "snd_bcm2835.enable_hdmi=1"
      "fbcon=rotate:3"
    ];
    loader = {
      grub.enable = false; # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
      generic-extlinux-compatible.enable = true; # Enables the generation of /boot/extlinux/extlinux.conf
    };
  };

  console.enable = true;

  environment.systemPackages = with pkgs; [
    git
    fastfetch
    libraspberrypi
    raspberrypi-eeprom
    tree
    vim
    wget
  ];

  hardware = {
    deviceTree = {
      enable = true;
      filter = "bcm2711-rpi-4*.dtb";
    };
    pulseaudio.enable = true;
    raspberry-pi."4" = {
      apply-overlays-dtmerge.enable = true;
      fkms-3d.enable = true;
    };
  };

  networking = {
    firewall.allowedTCPPorts = [ 22 ];
    hostName = hostname;
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  };

  services = {
    openssh.enable = true;
  };

  # Added per https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi#Bluetooth
  # but that serial device isn't showing up so commenting out for now.
  #systemd.services.btattach = {
  #  before = [ "bluetooth.service" ];
  #  after = [ "dev-ttyAMA0.device" ];
  #  wantedBy = [ "multi-user.target" ];
  #  serviceConfig = {
  #    ExecStart = "${pkgs.bluez}/bin/btattach -B /dev/ttyAMA0 -P bcm -S 3000000";
  #  };
  #};

  time.timeZone = "America/New_York";

  users.users.gene = {
    hashedPassword = "$6$FH6xo/OzM9mIAXqx$GTqSEDahPGyxLiDOEY77uxaApdd3xJKOkvddV6X4wplTCxsbuoyXwuOuQjMODS7dhfRs.HwL3VQgUjmok3QM60";
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [ ];
  };
}

