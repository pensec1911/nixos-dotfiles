# Laptop hardware: power management, thermals, backlight.
{ pkgs, ... }:

{
  # TLP: power saving on battery + charge limits for both batteries.
  # Charging starts below 75% and stops at 80%, which is much easier on the
  # cells. For a full charge before a trip: `sudo tlp fullcharge`.
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
      START_CHARGE_THRESH_BAT1 = 75;
      STOP_CHARGE_THRESH_BAT1 = 80;
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
    };
  };
  # TLP and power-profiles-daemon conflict; make sure the latter stays off
  services.power-profiles-daemon.enable = false;

  # Intel thermal daemon: throttles smarter than the firmware alone
  services.thermald.enable = true;

  # Backlight: brightnessctl for the XF86MonBrightness keys (bound in dwm).
  # The udev rule + video group let it write without sudo.
  environment.systemPackages = [ pkgs.brightnessctl ];
  services.udev.packages = [ pkgs.brightnessctl ];
  users.users.user.extraGroups = [ "video" ];
}
